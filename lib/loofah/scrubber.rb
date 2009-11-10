module Loofah
  #
  #  A RuntimeError raised when Loofah could not find an appropriate scrubber.
  #
  class ScrubberNotFound < RuntimeError ; end

  #
  #  TODO
  #
  class Scrubber
    CONTINUE = Object.new.freeze
    STOP     = Object.new.freeze

    attr_reader :direction, :block

    def initialize(options = {}, &block)
      direction = options[:direction] || :top_down
      unless [:top_down, :bottom_up].include?(direction)
        raise ArgumentError, "direction #{direction} must be one of :top_down or :bottom_up" 
      end
      @direction, @block = direction, block
    end

    def traverse(node)
      direction == :bottom_up ? traverse_conditionally_bottom_up(node) : traverse_conditionally_top_down(node)
    end

    def scrub(node)
      raise ScrubberNotFound, "No scrub method has been defined on #{self.class.to_s}"
    end

    private

    def html5lib_sanitize(node)
      case node.type
      when Nokogiri::XML::Node::ELEMENT_NODE
        if HTML5::HashedWhiteList::ALLOWED_ELEMENTS[node.name]
          HTML5::Scrub.scrub_attributes node
          return Scrubber::CONTINUE
        end
      when Nokogiri::XML::Node::TEXT_NODE, Nokogiri::XML::Node::CDATA_SECTION_NODE
        return Scrubber::CONTINUE
      end
      Scrubber::STOP
    end

    def traverse_conditionally_top_down(node)
      if block
        return if block.call(node) == STOP
      else
        return if scrub(node) == STOP
      end
      node.children.each {|j| traverse_conditionally_top_down(j)}
    end

    def traverse_conditionally_bottom_up(node)
      node.children.each {|j| traverse_conditionally_bottom_up(j)}
      if block
        block.call(node)
      else
        scrub(node)
      end
    end
  end
end
