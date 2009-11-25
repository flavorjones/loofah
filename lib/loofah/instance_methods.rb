module Loofah
  #
  #  Mixed into documents, fragments and nodes.
  #
  module ScrubBehavior
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
    def scrub!(scrubber)
      scrubber = Scrubbers::MAP[scrubber].new if Scrubbers::MAP[scrubber]
      raise Loofah::ScrubberNotFound, "not a Scrubber or a scrubber name: #{scrubber.inspect}" unless scrubber.is_a?(Loofah::Scrubber)
      case self
      when Nokogiri::XML::Document
        scrubber.traverse(root) if root
      when Nokogiri::XML::DocumentFragment
        children.each { |node| scrubber.traverse(node) }
      else
        scrubber.traverse(self)
      end
      self
    end
  end

  #
  #  Methods that are mixed into Loofah::HTML::Document and Loofah::HTML::DocumentFragment.
  #
  module DocumentDecorator
    def initialize(*args, &block)
      super
      self.decorators(Nokogiri::XML::Node) << ScrubBehavior
    end
  end
end
