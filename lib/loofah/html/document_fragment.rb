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
      #  Returns a plain-text version of the markup contained by the
      #  fragment, with HTML entities encoded.
      #
      #  This method is significantly faster than #to_text, but isn't
      #  clever about whitespace around block elements.
      #
      #    Loofah.fragment("<h1>Title</h1><div>Content</div>").text
      #    # => "TitleContent"
      #
      def text
        encode_special_chars serialize_roots.children.inner_text
      end
      alias :inner_text :text
      alias :to_str     :text

      #
      #  Returns a plain-text version of the markup contained by the
      #  fragment, with HTML entities encoded.
      #
      #  This method is slower than #to_text, but is clever about
      #  whitespace around block elements.
      #
      #    Loofah.fragment("<h1>Title</h1><div>Content</div>").to_text
      #    # => "\nTitle\n\nContent\n"
      #
      def to_text
        doc = self.dup
        Loofah::Helpers.remove_extraneous_whitespace doc.scrub!(:newline_block_elements).text
      end

      private

      def serialize_roots # :nodoc:
        at_xpath("./body") || self
      end
    end
  end
end
