# frozen_string_literal: true
module Loofah
  #
  #  Mixes +scrub!+ into Document, DocumentFragment, Node and NodeSet.
  #
  #  Traverse the document or fragment, invoking the +scrubber+ on each node.
  #
  #  +scrubber+ must either be one of the symbols representing the built-in scrubbers (see
  #  Scrubbers), or a Scrubber instance.
  #
  #    span2div = Loofah::Scrubber.new do |node|
  #      node.name = "div" if node.name == "span"
  #    end
  #    Loofah.html4_fragment("<span>foo</span><p>bar</p>").scrub!(span2div).to_s
  #    # => "<div>foo</div><p>bar</p>"
  #
  #  or
  #
  #    unsafe_html = "ohai! <div>div is safe</div> <script>but script is not</script>"
  #    Loofah.html4_fragment(unsafe_html).scrub!(:strip).to_s
  #    # => "ohai! <div>div is safe</div> "
  #
  #  Note that this method is called implicitly from the shortcuts Loofah.scrub_html4_fragment et
  #  al.
  #
  #  Please see Scrubber for more information on implementation and traversal, and README.rdoc for
  #  more example usage.
  #
  module ScrubBehavior
    module Node # :nodoc:
      def scrub!(scrubber)
        #
        #  yes. this should be three separate methods. but nokogiri decorates (or not) based on
        #  whether the module name has already been included. and since documents get decorated just
        #  like their constituent nodes, we need to jam all the logic into a single module.
        #
        scrubber = ScrubBehavior.resolve_scrubber(scrubber)
        case self
        when Nokogiri::XML::Document
          scrubber.traverse(root) if root
        when Nokogiri::XML::DocumentFragment
          children.scrub! scrubber
        else
          scrubber.traverse(self)
        end
        self
      end
    end

    module NodeSet # :nodoc:
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

  #
  #  Overrides +text+ in HTML4::Document and HTML4::DocumentFragment, and mixes in +to_text+.
  #
  module TextBehavior
    #
    #  Returns a plain-text version of the markup contained by the document, with HTML entities
    #  encoded.
    #
    #  This method is significantly faster than #to_text, but isn't clever about whitespace around
    #  block elements.
    #
    #    Loofah.html4_document("<h1>Title</h1><div>Content</div>").text
    #    # => "TitleContent"
    #
    #  By default, the returned text will have HTML entities escaped. If you want unescaped
    #  entities, and you understand that the result is unsafe to render in a browser, then you can
    #  pass an argument as shown:
    #
    #    frag = Loofah.html4_fragment("&lt;script&gt;alert('EVIL');&lt;/script&gt;")
    #    # ok for browser:
    #    frag.text                                 # => "&lt;script&gt;alert('EVIL');&lt;/script&gt;"
    #    # decidedly not ok for browser:
    #    frag.text(:encode_special_chars => false) # => "<script>alert('EVIL');</script>"
    #
    def text(options = {})
      result = if serialize_root
        serialize_root.children.reject(&:comment?).map(&:inner_text).join("")
      else
        ""
      end
      if options[:encode_special_chars] == false
        result # possibly dangerous if rendered in a browser
      else
        encode_special_chars result
      end
    end

    alias :inner_text :text
    alias :to_str :text

    #
    #  Returns a plain-text version of the markup contained by the fragment, with HTML entities
    #  encoded.
    #
    #  This method is slower than #text, but is clever about whitespace around block elements and
    #  line break elements.
    #
    #    Loofah.html4_document("<h1>Title</h1><div>Content<br>Next line</div>").to_text
    #    # => "\nTitle\n\nContent\nNext line\n"
    #
    def to_text(options = {})
      Loofah.remove_extraneous_whitespace self.dup.scrub!(:newline_block_elements).text(options)
    end
  end

  module DocumentDecorator # :nodoc:
    def initialize(*args, &block)
      super
      self.decorators(Nokogiri::XML::Node) << ScrubBehavior::Node
      self.decorators(Nokogiri::XML::NodeSet) << ScrubBehavior::NodeSet
    end
  end

  module HtmlDocumentBehavior # :nodoc:
    module ClassMethods
      def parse(*args, &block)
        remove_comments_before_html_element(super)
      end

      private

      # remove comments that exist outside of the HTML element.
      #
      # these comments are allowed by the HTML spec:
      #
      #    https://www.w3.org/TR/html401/struct/global.html#h-7.1
      #
      # but are not scrubbed by Loofah because these nodes don't meet
      # the contract that scrubbers expect of a node (e.g., it can be
      # replaced, sibling and children nodes can be created).
      def remove_comments_before_html_element(doc)
        doc.children.each do |child|
          child.unlink if child.comment?
        end
        doc
      end
    end

    def self.included(base)
      base.extend(ClassMethods)
    end

    def serialize_root
      at_xpath("/html/body")
    end
  end

  module HtmlFragmentBehavior # :nodoc:
    module ClassMethods
      def parse(tags, encoding = nil)
        doc = document_klass.new

        encoding ||= tags.respond_to?(:encoding) ? tags.encoding.name : "UTF-8"
        doc.encoding = encoding

        new(doc, tags)
      end

      def document_klass
        @document_klass ||= if (self == Loofah::HTML5::DocumentFragment)
          Loofah::HTML5::Document
        elsif (self == Loofah::HTML4::DocumentFragment)
          Loofah::HTML4::Document
        else
          raise ArgumentError, "unexpected class: #{self}"
        end
      end
    end

    def self.included(base)
      base.extend(ClassMethods)
    end

    def to_s
      serialize_root.children.to_s
    end

    alias :serialize :to_s

    def serialize_root
      at_xpath("./body") || self
    end
  end
end

