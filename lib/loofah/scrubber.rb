module Loofah
  #
  #  Methods that are mixed into Loofah::HTML::Document and Loofah::HTML::DocumentFragment.
  #
  module ScrubberInstanceMethods

    #
    #  Clean up the HTML. See Loofah for full usage.
    #
    def scrub!(method)
      method = method.to_sym
      case method
      when :escape, :prune, :whitewash
        __sanitize_roots.children.each do |node|
          Scrubber.traverse_conditionally_top_down(node, method)
        end
      when :strip
        __sanitize_roots.children.each do |node|
          Scrubber.traverse_conditionally_bottom_up(node, method)
        end
      else
        if Scrubber.filters[method]
          direction = Scrubber.filters[method].options[:direction] || :top_down
          __sanitize_roots.children.each do |node|
            if direction == :top_down
              Scrubber.traverse_conditionally_top_down(node, Scrubber.filters[method].block)
            else
              Scrubber.traverse_conditionally_bottom_up(node, Scrubber.filters[method].block)
            end
          end
        else
          raise Scrubber::NoSuchFilter, "unknown sanitize filter '#{method}'"
        end
      end
      self
    end

    #
    #  Returns a plain-text version of the markup contained by the fragment or document
    #
    def text
      __sanitize_roots.children.inner_text
    end
    alias :inner_text :text
    alias :to_str     :text
  end

  module Scrubber
    CONTINUE = :continue
    STOP     = :stop

    class NoSuchFilter < RuntimeError ; end
    class FilterAlreadyDefined < RuntimeError ; end

    # TODO: this is the class we should expose. not a method call. TDD FTW!
    class Filter
      attr_accessor :options, :block
      def initialize(options, &block)
        if options[:direction] && ! [:top_down, :bottom_up].include?(options[:direction])
          raise ArgumentError, "direction #{options[:direction]} must be one of :top_down or :bottom_up" 
        end
        @options, @block = options, block
      end
    end

    class << self

      def define_filter(name, options={}, &block)
        name = name.to_sym
        raise(Scrubber::FilterAlreadyDefined, "filter '#{name}' is already defined") if filters.has_key?(name)
        filters[name] = Filter.new(options, &block)
      end

      def undefine_filter(name)
        filters.delete(name.to_sym)
      end

      def filters
        @@filters ||= {}
      end

      def sanitize(node)
        case node.type
        when Nokogiri::XML::Node::ELEMENT_NODE
          if HTML5::HashedWhiteList::ALLOWED_ELEMENTS[node.name]
            HTML5::Scrub.scrub_attributes node
            return CONTINUE
          end
        when Nokogiri::XML::Node::TEXT_NODE, Nokogiri::XML::Node::CDATA_SECTION_NODE
          return CONTINUE
        end
        STOP
      end

      def escape(node)
        return CONTINUE if sanitize(node) == CONTINUE
        replacement_killer = Nokogiri::XML::Text.new(node.to_s, node.document)
        node.add_next_sibling replacement_killer
        node.remove
        return STOP
      end

      def prune(node)
        return CONTINUE if sanitize(node) == CONTINUE
        node.remove
        return STOP
      end

      def strip(node)
        return CONTINUE if sanitize(node) == CONTINUE
        replacement_killer = node.before node.inner_html
        node.remove
      end

      def whitewash(node)
        case node.type
        when Nokogiri::XML::Node::ELEMENT_NODE
          if HTML5::HashedWhiteList::ALLOWED_ELEMENTS[node.name]
            node.attributes.each { |attr| node.remove_attribute(attr.first) }
            return CONTINUE if node.namespaces.empty?
          end
        when Nokogiri::XML::Node::TEXT_NODE, Nokogiri::XML::Node::CDATA_SECTION_NODE
          return CONTINUE
        end
        node.remove
        return STOP
      end

      def traverse_conditionally_top_down(node, method)
        if method.is_a?(Proc)
          return if method.call(node) == STOP
        else
          return if send(method, node) == STOP
        end
        node.children.each {|j| traverse_conditionally_top_down(j, method)}
      end

      def traverse_conditionally_bottom_up(node, method)
        node.children.each {|j| traverse_conditionally_bottom_up(j, method)}
        if method.is_a?(Proc)
          method.call(node)
        else
          send(method, node)
        end
      end

    end

  end
end
