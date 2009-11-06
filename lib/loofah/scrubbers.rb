module Loofah
  #
  #  TODO
  #
  module Scrubbers

    #
    #  TODO
    #
    class Escape < Scrubber
      def initialize
        @direction = :top_down
      end

      def scrub(node)
        return Scrubber::CONTINUE if sanitize(node) == Scrubber::CONTINUE
        replacement_killer = Nokogiri::XML::Text.new(node.to_s, node.document)
        node.add_next_sibling replacement_killer
        node.remove
        return Scrubber::STOP
      end
    end

    #
    #  TODO
    #
    class Prune < Scrubber
      def initialize
        @direction = :top_down
      end

      def scrub(node)
        return Scrubber::CONTINUE if sanitize(node) == Scrubber::CONTINUE
        node.remove
        return Scrubber::STOP
      end
    end

    #
    #  TODO
    #
    class Whitewash < Scrubber
      def initialize
        @direction = :top_down
      end

      def scrub(node)
        case node.type
        when Nokogiri::XML::Node::ELEMENT_NODE
          if HTML5::HashedWhiteList::ALLOWED_ELEMENTS[node.name]
            node.attributes.each { |attr| node.remove_attribute(attr.first) }
            return Scrubber::CONTINUE if node.namespaces.empty?
          end
        when Nokogiri::XML::Node::TEXT_NODE, Nokogiri::XML::Node::CDATA_SECTION_NODE
          return Scrubber::CONTINUE
        end
        node.remove
        Scrubber::STOP
      end
    end

    #
    #  TODO
    #
    class Strip < Scrubber
      def initialize
        @direction = :bottom_up
      end

      def scrub(node)
        return Scrubber::CONTINUE if sanitize(node) == Scrubber::CONTINUE
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
