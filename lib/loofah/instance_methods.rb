module Loofah
  #
  #  Methods that are mixed into Loofah::HTML::Document and Loofah::HTML::DocumentFragment.
  #
  module InstanceMethods

    #
    #  Clean up the HTML. See Loofah for full usage.
    #
    def scrub!(filter)
      filter = Filters::MAP[filter].new if Filters::MAP[filter]
      raise Loofah::FilterNotFound, "not a Filter or a filter name: #{filter.inspect}" unless filter.is_a?(Loofah::Filter)
      sanitize_roots.children.each { |node| filter.traverse(node) }
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
