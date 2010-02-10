module Loofah
  #
  #  Mixes +scrub!+ into Document, DocumentFragment, Node and NodeSet.
  #
  #  Traverse the document or fragment, invoking the +scrubber+ on
  #  each node.
  #
  #  +scrubber+ must either be one of the symbols representing the
  #  built-in scrubbers (see Scrubbers), or a Scrubber instance.
  #
  #    span2div = Loofah::Scrubber.new do |node|
  #      node.name = "div" if node.name == "span"
  #    end
  #    Loofah.fragment("<span>foo</span><p>bar</p>").scrub!(span2div).to_s
  #    # => "<div>foo</div><p>bar</p>"
  #
  #  or
  #
  #    unsafe_html = "ohai! <div>div is safe</div> <script>but script is not</script>"
  #    Loofah.fragment(unsafe_html).scrub!(:strip).to_s
  #    # => "ohai! <div>div is safe</div> "
  #
  #  Note that this method is called implicitly from
  #  Loofah.scrub_fragment and Loofah.scrub_document.
  #
  #  Please see Scrubber for more information on implementation and traversal, and
  #  README.rdoc for more example usage.
  #
  module ScrubBehavior
    # see Loofah::ScrubBehavior
    module Node
      def scrub!(scrubber)
        #
        #  yes. this should be three separate methods. but nokogiri
        #  decorates (or not) based on whether the module name has
        #  already been included. and since documents get decorated
        #  just like their constituent nodes, we need to jam all the
        #  logic into a single module.
        #
        scrubber = ScrubBehavior.resolve_scrubber(scrubber)
        case self
        when Nokogiri::XML::Document
          scrubber.traverse(root) if root
        when Nokogiri::XML::DocumentFragment
          children.each { |node| node.scrub!(scrubber) } # TODO: children.scrub! once Nokogiri 1.4.2 is out
        else
          scrubber.traverse(self)
        end
        self
      end
    end

    # see Loofah::ScrubBehavior
    module NodeSet
      def scrub!(scrubber)
        each { |node| node.scrub!(scrubber) }
        self
      end
    end

    def ScrubBehavior.resolve_scrubber(scrubber) # :nodoc:
      scrubber = Scrubbers::MAP[scrubber].new if Scrubbers::MAP[scrubber]
      unless scrubber.is_a?(Loofah::Scrubber)
        raise Loofah::ScrubberNotFound, "not a Scrubber or a scrubber name: #{scrubber.inspect}"
      end
      scrubber
    end
  end

  module DocumentDecorator # :nodoc:
    def self.extended(base)
      base.decorators(Nokogiri::XML::Node) << ScrubBehavior::Node
      base.decorators(Nokogiri::XML::NodeSet) << ScrubBehavior::NodeSet
    end

    def initialize(*args, &block)
      super
      self.decorators(Nokogiri::XML::Node) << ScrubBehavior::Node
      self.decorators(Nokogiri::XML::NodeSet) << ScrubBehavior::NodeSet
    end
  end
end
