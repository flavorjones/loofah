# frozen_string_literal: true

require "cgi/escape"
require "cgi/util" if RUBY_VERSION < "3.5"
require "crass"

module Loofah
  module HTML5 # :nodoc:
    module Scrub
      CONTROL_CHARACTERS = /[`\u0000-\u0020\u007f\u0080-\u0101]/
      CSS_KEYWORDISH = /\A(#[0-9a-fA-F]+|rgb\(\d+%?,\d*%?,?\d*%?\)?|-?\d{0,3}\.?\d{0,10}(ch|cm|r?em|ex|in|lh|mm|pc|pt|px|Q|vmax|vmin|vw|vh|%|,|\))?)\z/ # rubocop:disable Layout/LineLength
      CRASS_SEMICOLON = { node: :semicolon, raw: ";" }
      CSS_IMPORTANT = "!important"
      CSS_WHITESPACE = " "
      CSS_PROPERTY_STRING_WITHOUT_EMBEDDED_QUOTES = /\A(["'])?[^"']+\1\z/
      DATA_ATTRIBUTE_NAME = /\Adata-[\w-]+\z/

      # Decimal (`&#58`) or hexadecimal (`&#x3a`) form, with or without the trailing semicolon that
      # CGI.unescapeHTML requires but browsers do not.
      NUMERIC_CHARACTER_REFERENCE = /&#(x[0-9a-f]+|[0-9]+);?/i

      # A scheme (RFC 3986) followed by a protocol separator. The separator must recognize the same
      # encoded-colon forms as PROTOCOL_SEPARATOR, otherwise a scheme split by an encoded colon (for
      # example "javascript&#58alert(1)") would not be recognized as having a scheme and would skip
      # protocol validation.
      URI_PROTOCOL_REGEX = /\A[a-z][a-z0-9+\-.]*#{SafeList::PROTOCOL_SEPARATOR}/

      # Matches a valid MIME type "essence" (type "/" subtype, no parameters), used to
      # decide whether a data: URI mediatype is well-formed; a non-match is not a valid
      # MIME type, which the data: URL processor treats as text/plain. Specs:
      #
      #   https://mimesniff.spec.whatwg.org/#valid-mime-type
      #   https://mimesniff.spec.whatwg.org/#mime-type-essence
      #   https://mimesniff.spec.whatwg.org/#http-token-code-point
      #
      # The character class below is the HTTP token set (tchar) from RFC 9110 section
      # 5.6.2, https://www.rfc-editor.org/rfc/rfc9110#name-tokens :
      #
      #   tchar = "!" / "#" / "$" / "%" / "&" / "'" / "*" / "+" / "-" / "." / "^"
      #         / "_" / "`" / "|" / "~" / DIGIT / ALPHA
      #
      # ALPHA is written a-z, not a-zA-Z, because allowed_uri? downcases the input first.
      DATA_URI_MEDIATYPE = %r{
        \A
        [a-z0-9!\#$%&'*+\-.^_`|~]+   # type:    1*tchar
        /                            # "/" is not a tchar, so it is the sole delimiter
        [a-z0-9!\#$%&'*+\-.^_`|~]+   # subtype: 1*tchar
        \z
      }x

      # HTML5 named character references for whitespace that browsers strip from
      # URIs. CGI.unescapeHTML does not decode these, so they are handled explicitly.
      WHITESPACE_CHARACTER_REFERENCES = /&(Tab|NewLine);/

      class << self
        def allowed_element?(element_name)
          ::Loofah::HTML5::SafeList::ALLOWED_ELEMENTS_WITH_LIBXML2.include?(element_name)
        end

        #  alternative implementation of the html5lib attribute scrubbing algorithm
        def scrub_attributes(node)
          node.attribute_nodes.each do |attr_node|
            attr_name = if attr_node.namespace
              "#{attr_node.namespace.prefix}:#{attr_node.node_name}"
            else
              attr_node.node_name
            end

            if DATA_ATTRIBUTE_NAME.match?(attr_name)
              next
            end

            unless SafeList::ALLOWED_ATTRIBUTES.include?(attr_name)
              attr_node.remove
              next
            end

            if SafeList::ATTR_VAL_IS_URI.include?(attr_name)
              next if scrub_uri_attribute(attr_node)
            end

            if SafeList::SVG_ATTR_VAL_ALLOWS_REF.include?(attr_name)
              scrub_attribute_that_allows_local_ref(attr_node)
            end

            next unless SafeList::SVG_ALLOW_LOCAL_HREF.include?(node.name) &&
              SafeList::SVG_HREF_ATTRIBUTES.include?(attr_name) &&
              attr_node.value =~ /^\s*[^#\s].*/m

            attr_node.remove
            next
          end

          scrub_css_attribute(node)

          node.attribute_nodes.each do |attr_node|
            if attr_node.value !~ /[^[:space:]]/ && attr_node.name !~ DATA_ATTRIBUTE_NAME
              node.remove_attribute(attr_node.name)
            end
          end

          force_correct_attribute_escaping!(node)
        end

        def scrub_css_attribute(node)
          style = node.attributes["style"]
          style.value = scrub_css(style.value) if style
        end

        def scrub_css(style)
          url_flags = [:url, :bad_url]
          style_tree = Crass.parse_properties(style)
          sanitized_tree = []

          style_tree.each do |node|
            next unless node[:node] == :property
            next if node[:children].any? do |child|
              url_flags.include?(child[:node])
            end

            name = node[:name].downcase
            next unless SafeList::ALLOWED_CSS_PROPERTIES.include?(name) ||
              SafeList::ALLOWED_SVG_PROPERTIES.include?(name) ||
              SafeList::SHORTHAND_CSS_PROPERTIES.include?(name.split("-").first)

            value = node[:children].map do |child|
              case child[:node]
              when :whitespace
                CSS_WHITESPACE
              when :string
                if CSS_PROPERTY_STRING_WITHOUT_EMBEDDED_QUOTES.match?(child[:raw])
                  Crass::Parser.stringify(child)
                end
              when :function
                if SafeList::ALLOWED_CSS_FUNCTIONS.include?(child[:name].downcase)
                  Crass::Parser.stringify(child)
                end
              when :ident
                keyword = child[:value]
                if !SafeList::SHORTHAND_CSS_PROPERTIES.include?(name.split("-").first) ||
                    SafeList::ALLOWED_CSS_KEYWORDS.include?(keyword) ||
                    (keyword =~ CSS_KEYWORDISH)
                  keyword
                end
              else
                child[:raw]
              end
            end.compact.join.strip

            next if value.empty?

            value << CSS_WHITESPACE << CSS_IMPORTANT if node[:important]
            propstring = format("%s:%s", name, value)
            sanitized_node = Crass.parse_properties(propstring).first
            sanitized_tree << sanitized_node << CRASS_SEMICOLON
          end

          Crass::Parser.stringify(sanitized_tree)
        end

        def scrub_attribute_that_allows_local_ref(attr_node)
          return unless attr_node.value

          nodes = Crass::Parser.new(attr_node.value).parse_component_values

          values = nodes.map do |node|
            case node[:node]
            when :url
              if node[:value].start_with?("#")
                node[:raw]
              end
            when :hash, :ident, :string
              node[:raw]
            end
          end.compact

          attr_node.value = values.join(" ")
        end

        # Returns true if the given URI string is safe, false otherwise. This method can be used to
        # validate URI attribute values without requiring a Nokogiri DOM node.
        def allowed_uri?(uri_string)
          # CGI.unescapeHTML decodes numeric references only when they carry a trailing semicolon, so
          # also decode the semicolon-less ones, which browsers still decode and execute. Normalizing
          # more aggressively than a browser only rejects more, which is safe. Control characters are
          # stripped both before and after decoding, since decoding can produce them. That strip must
          # precede WHITESPACE_CHARACTER_REFERENCES: removing a control character can reveal a named
          # whitespace reference.
          uri_string = decode_numeric_character_references(CGI.unescapeHTML(uri_string.gsub(CONTROL_CHARACTERS, "")))
          uri_string.gsub!(CONTROL_CHARACTERS, "")
          uri_string.gsub!(WHITESPACE_CHARACTER_REFERENCES, "")
          uri_string.gsub!("&colon;", ":")
          uri_string.downcase!
          if URI_PROTOCOL_REGEX.match?(uri_string)
            protocol = uri_string.split(SafeList::PROTOCOL_SEPARATOR)[0]
            return false unless SafeList::ALLOWED_PROTOCOLS.include?(protocol)

            if protocol == "data"
              # permit only allowed data mediatypes
              return false unless SafeList::ALLOWED_URI_DATA_MEDIATYPES.include?(data_uri_mediatype(uri_string))
            end
          end
          true
        end

        def decode_numeric_character_references(string)
          string.gsub(NUMERIC_CHARACTER_REFERENCE) do |reference|
            digits = ::Regexp.last_match(1)
            hexadecimal = digits.start_with?("x", "X")
            digits = digits[1..-1] if hexadecimal
            significant_digits = digits.sub(/\A0+/, "")

            # The largest code point is U+10FFFF: 7 decimal or 6 hexadecimal significant digits.
            # Anything longer is out of range; skip it without building a large integer from it.
            next reference if significant_digits.length > (hexadecimal ? 6 : 7)

            codepoint = significant_digits.to_i(hexadecimal ? 16 : 10)
            begin
              codepoint.chr(Encoding::UTF_8)
            rescue RangeError
              reference
            end
          end
        end

        def scrub_uri_attribute(attr_node)
          if allowed_uri?(attr_node.value)
            false
          else
            attr_node.remove
            true
          end
        end

        #
        #  libxml2 >= 2.9.2 fails to escape comments within some attributes.
        #
        #  see comments about CVE-2018-8048 within the tests for more information
        #
        def force_correct_attribute_escaping!(node)
          return unless Nokogiri::VersionInfo.instance.libxml2?

          node.attribute_nodes.each do |attr_node|
            next unless LibxmlWorkarounds::BROKEN_ESCAPING_ATTRIBUTES.include?(attr_node.name)

            tag_name = LibxmlWorkarounds::BROKEN_ESCAPING_ATTRIBUTES_QUALIFYING_TAG[attr_node.name]
            next unless tag_name.nil? || tag_name == node.name

            #
            #  this block is just like CGI.escape in Ruby 2.4, but
            #  only encodes space and double-quote, to mimic
            #  pre-2.9.2 behavior
            #
            encoding = attr_node.value.encoding
            attr_node.value = attr_node.value.gsub(/[ "]/) do |m|
              "%" + m.unpack("H2" * m.bytesize).join("%").upcase
            end.force_encoding(encoding)
          end
        end

        def cdata_needs_escaping?(node)
          # Nokogiri's HTML4 parser on JRuby doesn't flag the child of a `style` tag as cdata, but it acts that way
          node.cdata? || (Nokogiri.jruby? && node.text? && node.parent.name == "style")
        end

        def cdata_escape(node)
          escaped_text = escape_tags(node.text)
          if Nokogiri.jruby?
            node.document.create_text_node(escaped_text)
          else
            node.document.create_cdata(escaped_text)
          end
        end

        TABLE_FOR_ESCAPE_HTML__ = {
          "<" => "&lt;",
          ">" => "&gt;",
          "&" => "&amp;",
        }

        def escape_tags(string)
          # modified version of CGI.escapeHTML from ruby 3.1
          enc = string.encoding
          if enc.ascii_compatible?
            string = string.b
            string.gsub!(/[<>&]/, TABLE_FOR_ESCAPE_HTML__)
            string.force_encoding(enc)
          else
            if enc.dummy?
              origenc = enc
              enc = Encoding::Converter.asciicompat_encoding(enc)
              string = enc ? string.encode(enc) : string.b
            end
            table = Hash[TABLE_FOR_ESCAPE_HTML__.map { |pair| pair.map { |s| s.encode(enc) } }]
            string = string.gsub(/#{"[<>&]".encode(enc)}/, table)
            string.encode!(origenc) if origenc
            string
          end
        end

        private

        # Returns the mediatype of a data: URI per RFC 2397, or nil when the
        # required comma is absent. allowed_uri? entity-decodes, downcases, and
        # strips control characters before calling this. An omitted or malformed
        # mediatype resolves to "text/plain", matching the WHATWG data: URL processor.
        def data_uri_mediatype(uri_string)
          metadata, comma, _data = uri_string.delete_prefix("data:").partition(",")
          return nil if comma.empty?

          mediatype = metadata.delete_suffix(";base64").split(";", 2).first.to_s.strip
          mediatype.match?(DATA_URI_MEDIATYPE) ? mediatype : "text/plain"
        end
      end
    end
  end
end
