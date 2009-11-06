module Loofah
  #
  #  Methods that are mixed into Loofah::HTML::Document and Loofah::HTML::DocumentFragment.
  #
  module ScrubberInstanceMethods

    #
    #  Clean up the HTML. See Loofah for full usage.
    #
    def scrub!(method)
      if method.is_a?(Loofah::Filter)
        __sanitize_roots.children.each do |node|
          if method.direction == :top_down
            Scrubber.traverse_conditionally_top_down(node, method.block)
          else
            Scrubber.traverse_conditionally_bottom_up(node, method.block)
          end
        end
      else
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

  class Filter
    attr_accessor :direction, :block

    def initialize(options = {}, &block)
      direction = options[:direction] || :top_down
      unless [:top_down, :bottom_up].include?(direction)
        raise ArgumentError, "direction #{direction} must be one of :top_down or :bottom_up" 
      end
      @direction, @block = direction, block
    end
  end

  module Scrubber
    CONTINUE = :continue
    STOP     = :stop

    class NoSuchFilter < RuntimeError ; end
    class FilterAlreadyDefined < RuntimeError ; end

    class << self

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
