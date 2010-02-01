module Loofah
  module HTML # :nodoc:
    #
    #  Subclass of Nokogiri::HTML::DocumentFragment.
    #
    #  See Loofah::ScrubBehavior for additional methods.
    #
    class DocumentFragment < Nokogiri::HTML::DocumentFragment
      class << self
        #
        #  Overridden Nokogiri::HTML::DocumentFragment
        #  constructor. Applications should use Loofah.fragment to
        #  parse a fragment.
        #
        def parse tags
          self.new(Loofah::HTML::Document.new, tags)
        end
      end

      #
      #  Returns the HTML markup contained by the fragment
      #
      def to_s
        serialize_roots.children.to_s
      end
      alias :serialize :to_s

      #
      #  Returns a plain-text version of the markup contained by the fragment
      #
      def text
        serialize_roots.children.inner_text
      end
      alias :inner_text :text
      alias :to_str     :text

      private

      def serialize_roots # :nodoc:
        xpath("./body").first || self
      end
    end
  end
end
