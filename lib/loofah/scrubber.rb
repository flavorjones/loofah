module Loofah

  #
  #  A RuntimeError raised when Loofah could not find an appropriate filter.
  #
  class FilterNotFound < RuntimeError ; end

  #
  #  Methods that are mixed into Loofah::HTML::Document and Loofah::HTML::DocumentFragment.
  #
  module ScrubberInstanceMethods

    #
    #  Clean up the HTML. See Loofah for full usage.
    #
    def scrub!(filter)
      if filter.is_a?(Loofah::Filter)
        __sanitize_roots.children.each do |node|
          if filter.direction == :top_down
            filter.traverse_conditionally_top_down(node)
          else
            filter.traverse_conditionally_bottom_up(node)
          end
        end
      else
        filter = filter.to_sym
        case filter
        when :escape, :prune, :whitewash
          __sanitize_roots.children.each do |node|
            Scrubber.traverse_conditionally_top_down(node, filter)
          end
        when :strip
          __sanitize_roots.children.each do |node|
            Scrubber.traverse_conditionally_bottom_up(node, filter)
          end
        else
          raise Loofah::FilterNotFound, "unknown sanitize filter '#{filter}'"
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
    CONTINUE = Object.new.freeze
    STOP     = Object.new.freeze

    attr_accessor :direction, :block

    def initialize(options = {}, &block)
      direction = options[:direction] || :top_down
      unless [:top_down, :bottom_up].include?(direction)
        raise ArgumentError, "direction #{direction} must be one of :top_down or :bottom_up" 
      end
      @direction, @block = direction, block
    end

    def traverse_conditionally_top_down(node)
      if block
        return if block.call(node) == STOP
      else
        return if filter(node) == STOP
      end
      node.children.each {|j| traverse_conditionally_top_down(j)}
    end

    def traverse_conditionally_bottom_up(node)
      node.children.each {|j| traverse_conditionally_bottom_up(j)}
      if block
        block.call(node)
      else
        filter(node)
      end
    end
  end

  module Scrubber

    class << self

      def sanitize(node)
        case node.type
        when Nokogiri::XML::Node::ELEMENT_NODE
          if HTML5::HashedWhiteList::ALLOWED_ELEMENTS[node.name]
            HTML5::Scrub.scrub_attributes node
            return Filter::CONTINUE
          end
        when Nokogiri::XML::Node::TEXT_NODE, Nokogiri::XML::Node::CDATA_SECTION_NODE
          return Filter::CONTINUE
        end
        Filter::STOP
      end

      def escape(node)
        return Filter::CONTINUE if sanitize(node) == Filter::CONTINUE
        replacement_killer = Nokogiri::XML::Text.new(node.to_s, node.document)
        node.add_next_sibling replacement_killer
        node.remove
        return Filter::STOP
      end

      def prune(node)
        return Filter::CONTINUE if sanitize(node) == Filter::CONTINUE
        node.remove
        return Filter::STOP
      end

      def strip(node)
        return Filter::CONTINUE if sanitize(node) == Filter::CONTINUE
        replacement_killer = node.before node.inner_html
        node.remove
      end

      def whitewash(node)
        case node.type
        when Nokogiri::XML::Node::ELEMENT_NODE
          if HTML5::HashedWhiteList::ALLOWED_ELEMENTS[node.name]
            node.attributes.each { |attr| node.remove_attribute(attr.first) }
            return Filter::CONTINUE if node.namespaces.empty?
          end
        when Nokogiri::XML::Node::TEXT_NODE, Nokogiri::XML::Node::CDATA_SECTION_NODE
          return Filter::CONTINUE
        end
        node.remove
        return Filter::STOP
      end

      def traverse_conditionally_top_down(node, filter)
        if filter.is_a?(Proc)
          return if filter.call(node) == Filter::STOP
        elsif filter
          return if send(filter, node) == Filter::STOP
        else
          return if filter(node) == Filter::STOP
        end
        node.children.each {|j| traverse_conditionally_top_down(j, filter)}
      end

      def traverse_conditionally_bottom_up(node, filter)
        node.children.each {|j| traverse_conditionally_bottom_up(j, filter)}
        if filter.is_a?(Proc)
          filter.call(node)
        elsif filter
          send(filter, node)
        else
          filter(node)
        end
      end

    end

  end
end
