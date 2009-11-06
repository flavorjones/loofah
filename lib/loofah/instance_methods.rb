module Loofah
  #
  #  Methods that are mixed into Loofah::HTML::Document and Loofah::HTML::DocumentFragment.
  #
  module InstanceMethods

    #
    #  Clean up the HTML. See Loofah for full usage.
    #
    def scrub!(scrubber)
      scrubber = Scrubbers::MAP[scrubber].new if Scrubbers::MAP[scrubber]
      raise Loofah::ScrubberNotFound, "not a Scrubber or a scrubber name: #{scrubber.inspect}" unless scrubber.is_a?(Loofah::Scrubber)
      sanitize_roots.children.each { |node| scrubber.traverse(node) }
      self
    end

    #
    #  Returns a plain-text version of the markup contained by the fragment or document
    #
    def text
      sanitize_roots.children.inner_text
    end
    alias :inner_text :text
    alias :to_str     :text
  end
end
