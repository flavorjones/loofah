module Loofah
  #
  #  Methods that are mixed into Loofah::HTML::Document and Loofah::HTML::DocumentFragment.
  #
  module ScrubberInstanceMethods

    #
    #  Clean up the HTML. See Loofah for full usage.
    #
    def scrub!(method)
      case method
      when :escape, :prune, :whitewash
        __sanitize_roots.children.each do |node|
          Scrubber.traverse_conditionally_top_down(node, method.to_sym)
        end
      when :strip
        __sanitize_roots.children.each do |node|
          Scrubber.traverse_conditionally_bottom_up(node, method.to_sym)
        end
      else
        if  Scrubber.filters[method]
          __sanitize_roots.children.each do |node|
            Scrubber.traverse_conditionally_top_down(node, Scrubber.filters[method])
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
    CONTINUE = false
    STOP     = true

    class NoSuchFilter < RuntimeError ; end
    class FilterAlreadyDefined < RuntimeError ; end

    class << self

      def define_filter(name, options={}, &block)
        raise(Scrubber::FilterAlreadyDefined, "filter '#{name}' is already defined") if filters.has_key?(name.to_sym)
        filters[name.to_sym] = block
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
            return false
          end
        when Nokogiri::XML::Node::TEXT_NODE, Nokogiri::XML::Node::CDATA_SECTION_NODE
          return false
        end
        true
      end

      def escape(node)
        return false unless sanitize(node)
        replacement_killer = Nokogiri::XML::Text.new(node.to_s, node.document)
        node.add_next_sibling replacement_killer
        node.remove
        return true
      end

      def prune(node)
        return false unless sanitize(node)
        node.remove
        return true
      end

      def strip(node)
        return false unless sanitize(node)
        replacement_killer = node.before node.inner_html
        node.remove
        return true
      end

      def whitewash(node)
        case node.type
        when Nokogiri::XML::Node::ELEMENT_NODE
          if HTML5::HashedWhiteList::ALLOWED_ELEMENTS[node.name]
            node.attributes.each { |attr| node.remove_attribute(attr.first) }
            return false if node.namespaces.empty?
          end
        when Nokogiri::XML::Node::TEXT_NODE, Nokogiri::XML::Node::CDATA_SECTION_NODE
          return false
        end
        node.remove
        return true
      end

      def traverse_conditionally_top_down(node, method)
        if method.is_a?(Proc)
          return if method.call(node)
        else
          return if send(method, node)
        end
        node.children.each {|j| traverse_conditionally_top_down(j, method)}
      end

      def traverse_conditionally_bottom_up(node, method)
        node.children.each {|j| traverse_conditionally_bottom_up(j, method)}
        return if send(method, node)
      end

    end

  end
end
