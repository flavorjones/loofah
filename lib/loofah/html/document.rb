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
      #  By default, the returned text will have HTML entities
      #  escaped. If you want unescaped entities, and you understand
      #  that the result is unsafe to render in a browser, then you
      #  can pass an argument as shown:
      #
      #    frag = Loofah.fragment("&lt;script&gt;alert('EVIL');&lt;/script&gt;")
      #    # ok for browser:
      #    frag.text                                 # => "&lt;script&gt;alert('EVIL');&lt;/script&gt;"
      #    # decidedly not ok for browser:
      #    frag.text(:encode_special_chars => false) # => "<script>alert('EVIL');</script>"
      #
      def text(options={})
        result = xpath("/html/body").inner_text
        if options[:encode_special_chars] == false
          result # possibly dangerous if rendered in a browser
        else
          encode_special_chars result
        end
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
      def to_text(options={})
        Loofah::Helpers.remove_extraneous_whitespace self.dup.scrub!(:newline_block_elements).text(options)
      end
    end
  end
end
