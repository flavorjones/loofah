module Loofah

  module SanitizerInstanceMethods

    def sanitize!(method)
      case method
      when :escape, :prune, :whitewash
        __sanitize_roots.children.each do |node|
          Sanitizer.traverse_conditionally_top_down(node, method.to_sym)
        end
      when :yank
        __sanitize_roots.children.each do |node|
          Sanitizer.traverse_conditionally_bottom_up(node, method.to_sym)
        end
      else
        raise ArgumentError, "unknown sanitize filter '#{method}'"
      end
      self
    end

    def to_s
      __sanitize_roots.children.to_s
    end
    alias :serialize :to_s

    def inner_text
      __sanitize_roots.children.inner_text
    end
    alias :text    :inner_text
    alias :to_str  :inner_text
  end

  module Sanitizer
    class << self

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

      def yank(node)
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

      def traverse_conditionally_top_down(node, method_name)
        return if send(method_name, node)
        node.children.each {|j| traverse_conditionally_top_down(j, method_name)}
      end

      def traverse_conditionally_bottom_up(node, method_name)
        node.children.each {|j| traverse_conditionally_bottom_up(j, method_name)}
        return if send(method_name, node)
      end

    end

  end
end
