module Loofah
  #
  #  TODO
  #
  module Filters

    #
    #  TODO
    #
    class Escape < Filter
      def initialize
        @direction = :top_down
      end

      def filter(node)
        return Filter::CONTINUE if sanitize(node) == Filter::CONTINUE
        replacement_killer = Nokogiri::XML::Text.new(node.to_s, node.document)
        node.add_next_sibling replacement_killer
        node.remove
        return Filter::STOP
      end
    end

    #
    #  TODO
    #
    class Prune < Filter
      def initialize
        @direction = :top_down
      end

      def filter(node)
        return Filter::CONTINUE if sanitize(node) == Filter::CONTINUE
        node.remove
        return Filter::STOP
      end
    end

    #
    #  TODO
    #
    class Whitewash < Filter
      def initialize
        @direction = :top_down
      end

      def filter(node)
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
        Filter::STOP
      end
    end

    #
    #  TODO
    #
    class Strip < Filter
      def initialize
        @direction = :bottom_up
      end

      def filter(node)
        return Filter::CONTINUE if sanitize(node) == Filter::CONTINUE
        replacement_killer = node.before node.inner_html
        node.remove
      end
    end

    #
    #  TODO
    #
    MAP = {
      :escape => Escape,
      :prune => Prune,
      :whitewash => Whitewash,
      :strip => Strip
    }
  end
end
