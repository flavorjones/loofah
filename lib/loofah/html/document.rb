module Loofah
  module HTML # :nodoc:
    #
    #  Subclass of Nokogiri::HTML::Document.
    #
    #  See Loofah::ScrubBehavior and Loofah::DocumentDecorator for additional methods.
    #
    class Document < Nokogiri::HTML::Document
      include Loofah::ScrubBehavior::Node
      include Loofah::DocumentDecorator

      #
      #  Returns a plain-text version of the markup contained by the document,
      #  with HTML entities encoded.
      #
      #  This method is significantly faster than #to_text, but isn't
      #  clever about whitespace around block elements.
      #
      #    Loofah.document("<h1>Title</h1><div>Content</div>").text
      #    # => "TitleContent"
      #
      def text
        encode_special_chars xpath("/html/body").inner_text
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
      #    Loofah.document("<h1>Title</h1><div>Content</div>").to_text
      #    # => "\nTitle\n\nContent\n"
      #
      def to_text
        Loofah::Helpers.remove_extraneous_whitespace self.dup.scrub!(:newline_block_elements).text
      end
    end
  end
end
