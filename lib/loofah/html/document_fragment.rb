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
        result = serialize_roots.children.inner_text
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
      #    Loofah.fragment("<h1>Title</h1><div>Content</div>").to_text
      #    # => "\nTitle\n\nContent\n"
      #
      def to_text(options={})
        Loofah::Helpers.remove_extraneous_whitespace self.dup.scrub!(:newline_block_elements).text(options)
      end

      private

      def serialize_roots # :nodoc:
        at_xpath("./body") || self
      end
    end
  end
end
