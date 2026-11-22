# frozen_string_literal: true

require "helper"

class UnitHTML5Scrub < Loofah::TestCase
  include Loofah

  describe ".scrub_css" do
    describe "hex values" do
      it "handles upper case" do
        assert_equal "background:#ABC012;", Loofah::HTML5::Scrub.scrub_css("background: #ABC012")
      end
      it "handles lower case" do
        assert_equal "background:#abc012;", Loofah::HTML5::Scrub.scrub_css("background: #abc012")
      end
    end

    describe "css functions" do
      it "allows safe functions" do
        assert_equal(
          "background-color:linear-gradient(transparent 50%, #ffff66 50%);",
          Loofah::HTML5::Scrub.scrub_css("background-color: linear-gradient(transparent 50%, #ffff66 50%);"),
        )
      end

      it "disallows functions whose name only matches the safelist under Unicode case folding" do
        assert_empty(Loofah::HTML5::Scrub.scrub_css("cursor:s\u212aew(1deg)"))
      end

      it "keeps the rest of a property whose unsafe function is dropped" do
        assert_equal("margin:0;", Loofah::HTML5::Scrub.scrub_css("margin:0 clamp(1rem, 2vw, 2rem)"))
        assert_equal("border:1px solid;", Loofah::HTML5::Scrub.scrub_css("border:1px solid color(display-p3 1 0 0)"))
      end

      it "keeps the rest of a property whose quote-containing string is dropped" do
        assert_equal("font-family:, serif;", Loofah::HTML5::Scrub.scrub_css(%{font-family:"Rock 'n' Roll", serif}))
      end

      it "disallows unsafe functions" do
        assert_equal(
          "",
          Loofah::HTML5::Scrub.scrub_css("background-color: haxxor-fun(transparent 50%, #ffff66 50%);"),
        )
      end

      # see #199 for the bug we're testing here
      it "allows safe functions in shorthand css properties" do
        assert_equal(
          "background:linear-gradient(transparent 50%, #ffff66 50%);",
          Loofah::HTML5::Scrub.scrub_css("background: linear-gradient(transparent 50%, #ffff66 50%);"),
        )
      end
    end

    describe "property string values" do
      it "allows hypenated values" do
        text = "font-family:'AvenirNext-Regular';"

        assert_equal(text, Loofah::HTML5::Scrub.scrub_css(text))

        text = 'font-family:"AvenirNext-Regular";'

        assert_equal(text, Loofah::HTML5::Scrub.scrub_css(text))
      end

      it "allows embedded spaces in values" do
        text = "font-family:'Avenir Next';"

        assert_equal(text, Loofah::HTML5::Scrub.scrub_css(text))

        text = 'font-family:"Avenir Next";'

        assert_equal(text, Loofah::HTML5::Scrub.scrub_css(text))
      end

      it "does not allow values with embedded or irregular quotes" do
        assert_empty(Loofah::HTML5::Scrub.scrub_css(%q(font-family:'AvenirNext"-Regular';)))
        assert_empty(Loofah::HTML5::Scrub.scrub_css(%q(font-family:"AvenirNext'-Regular";)))

        assert_empty(Loofah::HTML5::Scrub.scrub_css("font-family:'AvenirNext-Regular;"))
        assert_empty(Loofah::HTML5::Scrub.scrub_css(%q(font-family:'AvenirNext-Regular";)))

        assert_empty(Loofah::HTML5::Scrub.scrub_css('font-family:"AvenirNext-Regular;'))
        assert_empty(Loofah::HTML5::Scrub.scrub_css(%q(font-family:"AvenirNext-Regular';)))
      end

      it "keeps whitespace around delimiters if it's already there" do
        assert_equal(
          "font:13px / 1.5 Arial , sans-serif;",
          Loofah::HTML5::Scrub.scrub_css("font: 13px / 1.5 Arial , sans-serif;"),
        )
      end

      it "does not insert spaces around delimiters if they aren't already there" do
        assert_equal(
          "font:13px/1.5 Arial, sans-serif;",
          Loofah::HTML5::Scrub.scrub_css("font: 13px/1.5 Arial, sans-serif;"),
        )
      end
    end

    describe "url()" do
      it "removes properties with a url()" do
        assert_empty(Loofah::HTML5::Scrub.scrub_css("cursor:url(http://example.com/x.png),auto"))
      end

      it "does not decode escaped parentheses into a url()" do
        {
          "cursor:url\\28 http://example.com/x.png\\29,auto" => "cursor:url\\28 http://example.com/x.png\\29,auto;",
          "cursor:url\\000028 http://example.com/x.png\\000029,auto" => "cursor:url\\000028 http://example.com/x.png\\000029,auto;",
          "cursor:url\\(http://example.com/x.png\\),auto" => "cursor:url\\(http://example.com/x.png\\),auto;",
          "list-style:url\\28 http://example.com/b.png\\29" => "list-style:url\\28 http://example.com/b.png\\29;",
          "c\\75 rsor:url\\28 http://example.com/x.png\\29,auto" => "cursor:url\\28 http://example.com/x.png\\29,auto;",
          'cursor:url\\28 "http://example.com/x.png"\\29,auto' => 'cursor:url\\28 "http://example.com/x.png"\\29,auto;',
          "cursor:url\\5c 28 http://example.com/x.png\\5c 29,auto" => "cursor:url\\5c 28 http://example.com/x.png\\5c 29,auto;",
        }.each do |input, expected|
          assert_equal(expected, Loofah::HTML5::Scrub.scrub_css(input))
        end
      end

      it "does not decode escaped comments" do
        assert_equal(
          "cursor:url\\2f\\2a\\2a\\2f\\28 http://example.com/x.png\\29,auto;",
          Loofah::HTML5::Scrub.scrub_css("cursor:url\\2f\\2a\\2a\\2f\\28 http://example.com/x.png\\29,auto"),
        )
        assert_equal(
          "cursor:var\\2f\\2a\\2a\\2f\\28 --x\\29;",
          Loofah::HTML5::Scrub.scrub_css("cursor:var\\2f\\2a\\2a\\2f\\28 --x\\29"),
        )
      end

      it "does not decode escapes into unterminated blocks or strings" do
        assert_equal("cursor:\\28\\22;", Loofah::HTML5::Scrub.scrub_css("cursor:\\28\\22"))
        assert_equal("cursor:\\22;", Loofah::HTML5::Scrub.scrub_css("cursor:\\22"))
      end

      it "removes properties whose surviving tokens join into a comment" do
        assert_empty(Loofah::HTML5::Scrub.scrub_css("cursor:url/(a)*/(http://example.com/x.png),auto"))
      end
    end

    describe "whitespace" do
      it "converts all whitespace to a single space except initial and final whitespace" do
        assert_equal("font:12px Arial;", Loofah::HTML5::Scrub.scrub_css("font: \n\t 12px \n\t Arial \n\t ;"))
      end
    end

    describe "colors" do
      it "allows basic and extended colors" do
        text = "background-color:blue;"

        assert_equal(text, Loofah::HTML5::Scrub.scrub_css(text))

        text = "background-color:brown;"

        assert_equal(text, Loofah::HTML5::Scrub.scrub_css(text))

        text = "background-color:lightblue;"

        assert_equal(text, Loofah::HTML5::Scrub.scrub_css(text))
      end

      it "does not allow non-colors" do
        text = "background-color:blurple;"

        assert_empty(Loofah::HTML5::Scrub.scrub_css(text))
      end
    end
  end

  describe ".allowed_uri?" do
    it "transcodes a string in another encoding before checking it" do
      assert(Loofah::HTML5::Scrub.allowed_uri?("http://example.com/é".encode(Encoding::ISO_8859_1)))
      assert(Loofah::HTML5::Scrub.allowed_uri?("http://example.com".encode(Encoding::UTF_16LE)))
      refute(Loofah::HTML5::Scrub.allowed_uri?("javascript:alert('é')".encode(Encoding::ISO_8859_1)))
      refute(Loofah::HTML5::Scrub.allowed_uri?("javascript:alert(1)".encode(Encoding::UTF_16LE)))
    end

    it "rejects a string with an invalid byte sequence" do
      refute(Loofah::HTML5::Scrub.allowed_uri?("\xFFjavascript&#58alert(1)".b.force_encoding(Encoding::UTF_8)))
    end

    it "rejects a string that has no UTF-8 representation" do
      refute(Loofah::HTML5::Scrub.allowed_uri?("http://example.com/\xE9".b))
    end

    it "accepts ASCII-only strings in other ASCII-compatible encodings" do
      assert(Loofah::HTML5::Scrub.allowed_uri?("http://example.com".b))
      refute(Loofah::HTML5::Scrub.allowed_uri?("javascript:alert(1)".encode(Encoding::US_ASCII)))
    end

    it "allows http URIs" do
      assert(Loofah::HTML5::Scrub.allowed_uri?("http://example.com"))
    end

    it "allows https URIs" do
      assert(Loofah::HTML5::Scrub.allowed_uri?("https://example.com"))
    end

    it "allows mailto URIs" do
      assert(Loofah::HTML5::Scrub.allowed_uri?("mailto:foo@example.com"))
    end

    it "allows relative URIs" do
      assert(Loofah::HTML5::Scrub.allowed_uri?("/path/to/file"))
      assert(Loofah::HTML5::Scrub.allowed_uri?("path/to/file"))
      assert(Loofah::HTML5::Scrub.allowed_uri?("file.html"))
      assert(Loofah::HTML5::Scrub.allowed_uri?("#anchor"))
    end

    it "disallows javascript URIs" do
      refute(Loofah::HTML5::Scrub.allowed_uri?("javascript:alert(1)"))
    end

    it "disallows javascript URIs with capital letters" do
      refute(Loofah::HTML5::Scrub.allowed_uri?("JavaScript:alert(1)"))
      refute(Loofah::HTML5::Scrub.allowed_uri?("JAVASCRIPT:alert(1)"))
    end

    it "disallows javascript URIs with HTML entities" do
      refute(Loofah::HTML5::Scrub.allowed_uri?("javascript&#58;alert(1)"))
      refute(Loofah::HTML5::Scrub.allowed_uri?("javascript&#x3a;alert(1)"))
      refute(Loofah::HTML5::Scrub.allowed_uri?("javascript&colon;alert(1)"))
      refute(Loofah::HTML5::Scrub.allowed_uri?("javascript&amp;colon;alert(1)"))
      refute(Loofah::HTML5::Scrub.allowed_uri?("javascript&co\x00lon;alert(1)"))
      refute(Loofah::HTML5::Scrub.allowed_uri?("javascript&co\tlon;alert(1)"))
      refute(Loofah::HTML5::Scrub.allowed_uri?("javascript&co\nlon;alert(1)"))
    end

    it "disallows javascript URIs with control characters" do
      refute(Loofah::HTML5::Scrub.allowed_uri?("java\x00script:alert(1)"))
      refute(Loofah::HTML5::Scrub.allowed_uri?("java\tscript:alert(1)"))
      refute(Loofah::HTML5::Scrub.allowed_uri?("java\nscript:alert(1)"))
    end

    it "allows URIs with control characters inside character references, which browsers do not rejoin" do
      assert(Loofah::HTML5::Scrub.allowed_uri?("java&#1\x0015;cript:alert(1)"))
      assert(Loofah::HTML5::Scrub.allowed_uri?("java&#x\t73;cript:alert(1)"))
    end

    it "disallows javascript URIs with entity-encoded control characters splitting the scheme" do
      refute(Loofah::HTML5::Scrub.allowed_uri?("java&#13;script:alert(1)"))
      refute(Loofah::HTML5::Scrub.allowed_uri?("java&#10;script:alert(1)"))
      refute(Loofah::HTML5::Scrub.allowed_uri?("jav&#9;ascript:alert(1)"))
      refute(Loofah::HTML5::Scrub.allowed_uri?("java&#x0d;script:alert(1)"))
      refute(Loofah::HTML5::Scrub.allowed_uri?("java&#x0a;script:alert(1)"))
      refute(Loofah::HTML5::Scrub.allowed_uri?("jav&#x09;ascript:alert(1)"))
    end

    it "disallows javascript URIs with named whitespace character references splitting the scheme" do
      refute(Loofah::HTML5::Scrub.allowed_uri?("java&Tab;script:alert(1)"))
      refute(Loofah::HTML5::Scrub.allowed_uri?("java&NewLine;script:alert(1)"))
      refute(Loofah::HTML5::Scrub.allowed_uri?("&Tab;javascript:alert(1)"))
      refute(Loofah::HTML5::Scrub.allowed_uri?("&NewLine;javascript:alert(1)"))
    end

    it "disallows javascript URIs with named whitespace character references before the scheme separator" do
      refute(Loofah::HTML5::Scrub.allowed_uri?("javascript&Tab;:alert(1)"))
      refute(Loofah::HTML5::Scrub.allowed_uri?("javascript&NewLine;:alert(1)"))
    end

    it "disallows javascript URIs combining named whitespace and named colon references" do
      refute(Loofah::HTML5::Scrub.allowed_uri?("java&Tab;script&colon;alert(1)"))
      refute(Loofah::HTML5::Scrub.allowed_uri?("java&NewLine;script&colon;alert(1)"))
    end

    it "disallows javascript URIs with double-encoded named whitespace character references" do
      refute(Loofah::HTML5::Scrub.allowed_uri?("java&amp;Tab;script:alert(1)"))
      refute(Loofah::HTML5::Scrub.allowed_uri?("java&amp;NewLine;script:alert(1)"))
    end

    it "disallows javascript URIs where stripping an embedded control character reveals a named whitespace reference" do
      refute(Loofah::HTML5::Scrub.allowed_uri?("java&Ta&#0;b;script:alert(1)"))
      refute(Loofah::HTML5::Scrub.allowed_uri?("java&New&#0;Line;script:alert(1)"))
    end

    it "allows wrong-cased named whitespace references, which browsers do not decode" do
      assert(Loofah::HTML5::Scrub.allowed_uri?("java&tab;script:alert(1)"))
      assert(Loofah::HTML5::Scrub.allowed_uri?("java&NEWLINE;script:alert(1)"))
    end

    it "does not mutate a frozen argument" do
      frozen_uri = "JAVA&Tab;SCRIPT&colon;alert(1)"

      assert_predicate(frozen_uri, :frozen?)
      refute(Loofah::HTML5::Scrub.allowed_uri?(frozen_uri))
    end

    it "disallows javascript URIs whose scheme is separated by a semicolon-less numeric character reference colon" do
      refute(Loofah::HTML5::Scrub.allowed_uri?("javascript&#58alert(1)"))
      refute(Loofah::HTML5::Scrub.allowed_uri?("javascript&#058alert(1)"))
      refute(Loofah::HTML5::Scrub.allowed_uri?("javascript&#x3a(1)"))
      refute(Loofah::HTML5::Scrub.allowed_uri?("javascript&#x03a(1)"))
      refute(Loofah::HTML5::Scrub.allowed_uri?("javascript&#X3A(1)"))
      refute(Loofah::HTML5::Scrub.allowed_uri?("vbscript&#58msgbox(1)"))
    end

    it "disallows javascript URIs whose numeric character reference colon is padded with leading zeros" do
      refute(Loofah::HTML5::Scrub.allowed_uri?("javascript&#0000000000000000000058alert(1)"))
      refute(Loofah::HTML5::Scrub.allowed_uri?("javascript&#x000000000000000003a(1)"))
      refute(Loofah::HTML5::Scrub.allowed_uri?("java&#00000000000000000009script:alert(1)"))
    end

    it "disallows javascript URIs whose scheme is split by a semicolon-less numeric character reference whitespace character" do
      refute(Loofah::HTML5::Scrub.allowed_uri?("java&#9script:alert(1)"))
      refute(Loofah::HTML5::Scrub.allowed_uri?("java&#09script:alert(1)"))
      refute(Loofah::HTML5::Scrub.allowed_uri?("java&#10script:alert(1)"))
      refute(Loofah::HTML5::Scrub.allowed_uri?("java&#13script:alert(1)"))
      refute(Loofah::HTML5::Scrub.allowed_uri?("java&#x9script:alert(1)"))
      refute(Loofah::HTML5::Scrub.allowed_uri?("java&#X09script:alert(1)"))
    end

    it "disallows javascript URIs assembled from multiple numeric character references" do
      refute(Loofah::HTML5::Scrub.allowed_uri?("jav&#97script&#58alert(1)"))
      refute(Loofah::HTML5::Scrub.allowed_uri?("javascript&#x3a&#9alert(1)"))
    end

    it "disallows javascript URIs whose semicolon-less numeric character reference colon is terminated by a stripped character" do
      refute(Loofah::HTML5::Scrub.allowed_uri?("javascript&#x3a alert(1)"))
      refute(Loofah::HTML5::Scrub.allowed_uri?("javascript&#x3a\talert(1)"))
      refute(Loofah::HTML5::Scrub.allowed_uri?("javascript&#x3a\nalert(1)"))
      refute(Loofah::HTML5::Scrub.allowed_uri?("javascript&#x3a\ralert(1)"))
      refute(Loofah::HTML5::Scrub.allowed_uri?("javascript&#x3a\falert(1)"))
      refute(Loofah::HTML5::Scrub.allowed_uri?("javascript&#x3a\x00alert(1)"))
      refute(Loofah::HTML5::Scrub.allowed_uri?("javascript&#x3a\x7falert(1)"))
      refute(Loofah::HTML5::Scrub.allowed_uri?("javascript&#x3a\u0080alert(1)"))
      refute(Loofah::HTML5::Scrub.allowed_uri?("javascript&#x3a\u00a0alert(1)"))
      refute(Loofah::HTML5::Scrub.allowed_uri?("javascript&#x3a\u0101alert(1)"))
      refute(Loofah::HTML5::Scrub.allowed_uri?("javascript&#x3a`alert`"))
      refute(Loofah::HTML5::Scrub.allowed_uri?("javascript&#X3A alert(1)"))
      refute(Loofah::HTML5::Scrub.allowed_uri?("vbscript&#x3a alert(1)"))
      refute(Loofah::HTML5::Scrub.allowed_uri?("javascript&#58 1,alert(1)"))
      refute(Loofah::HTML5::Scrub.allowed_uri?("javascript&#58\t1,alert(1)"))
      refute(Loofah::HTML5::Scrub.allowed_uri?("javascript&#58\u00a01,alert(1)"))
    end

    it "disallows javascript URIs whose semicolon-less numeric character reference colon is followed by a character reference" do
      refute(Loofah::HTML5::Scrub.allowed_uri?("javascript&#x3a&#x61;lert(1)"))
      refute(Loofah::HTML5::Scrub.allowed_uri?("javascript&#x3a&#97;lert(1)"))
      refute(Loofah::HTML5::Scrub.allowed_uri?("javascript&#58&#49;,alert(1)"))
      refute(Loofah::HTML5::Scrub.allowed_uri?("javascript&#58&#x31;,alert(1)"))
      refute(Loofah::HTML5::Scrub.allowed_uri?("javascript&#x3a&#x20;alert(1)"))
      refute(Loofah::HTML5::Scrub.allowed_uri?("javascript&#x3a&Tab;alert(1)"))
      refute(Loofah::HTML5::Scrub.allowed_uri?("javascript&#x3a&NewLine;alert(1)"))
    end

    it "disallows javascript URIs whose scheme letter is a semicolon-less numeric character reference terminated by a stripped character" do
      refute(Loofah::HTML5::Scrub.allowed_uri?("&#x6a\tavascript:alert(1)"))
      refute(Loofah::HTML5::Scrub.allowed_uri?("ja&#x76\tascript:alert(1)"))
      refute(Loofah::HTML5::Scrub.allowed_uri?("java&#x73\ncript:alert(1)"))
      refute(Loofah::HTML5::Scrub.allowed_uri?("&#x6a\ravascript:alert(1)"))
      refute(Loofah::HTML5::Scrub.allowed_uri?("&#x76\tbscript:msgbox(1)"))
    end

    it "disallows javascript URIs whose scheme letter is a semicolon-less numeric character reference followed by a character reference" do
      refute(Loofah::HTML5::Scrub.allowed_uri?("&#x6a&#x61;vascript:alert(1)"))
      refute(Loofah::HTML5::Scrub.allowed_uri?("java&#x73&#99;ript:alert(1)"))
    end

    it "allows URIs whose numeric character references do not decode to a scheme colon" do
      assert(Loofah::HTML5::Scrub.allowed_uri?("javascript&#581alert(1)"))
      assert(Loofah::HTML5::Scrub.allowed_uri?("javascript&#x3aalert(1)"))
    end

    it "checks the mediatype of data URIs whose scheme is separated by a numeric character reference" do
      refute(Loofah::HTML5::Scrub.allowed_uri?("data&#58text/html,<script>alert(1)</script>"))
      assert(Loofah::HTML5::Scrub.allowed_uri?("data&#x3aimage/png;base64,iVBORw0KGgo"))
    end

    it "checks the mediatype of data URIs whose mediatype is assembled by a numeric character reference" do
      refute(Loofah::HTML5::Scrub.allowed_uri?("data:text&#x2fhtml,<script>alert(1)</script>"))
      assert(Loofah::HTML5::Scrub.allowed_uri?("data:image&#x2fpng;base64,iVBORw0KGgo"))
    end

    it "checks the mediatype of data URIs whose mediatype is assembled by a named solidus character reference" do
      refute(Loofah::HTML5::Scrub.allowed_uri?("data:text&sol;html,<script>alert(1)</script>"))
      refute(Loofah::HTML5::Scrub.allowed_uri?("data:text&sol;html;base64,PHNjcmlwdD5hbGVydCgxKTwvc2NyaXB0Pg=="))
      assert(Loofah::HTML5::Scrub.allowed_uri?("data:image&sol;png;base64,iVBORw0KGgo"))
    end

    it "checks the mediatype of data URIs whose scheme and mediatype are both assembled by named references" do
      refute(Loofah::HTML5::Scrub.allowed_uri?("data&colon;text&sol;html,<script>alert(1)</script>"))
      assert(Loofah::HTML5::Scrub.allowed_uri?("data&colon;image&sol;png;base64,iVBORw0KGgo"))
    end

    it "checks the mediatype of data URIs with a double-encoded named solidus character reference" do
      refute(Loofah::HTML5::Scrub.allowed_uri?("data:text&amp;sol;html,<script>alert(1)</script>"))
    end

    it "checks the mediatype of data URIs where stripping an embedded control character reveals a named solidus reference" do
      refute(Loofah::HTML5::Scrub.allowed_uri?("data:text&s&#0;ol;html,<script>alert(1)</script>"))
    end

    it "checks the mediatype of data URIs where removing a named whitespace reference reveals a named solidus reference" do
      refute(Loofah::HTML5::Scrub.allowed_uri?("data:text&s&Tab;ol;html,<script>alert(1)</script>"))
      refute(Loofah::HTML5::Scrub.allowed_uri?("data:text&s&NewLine;ol;html,<script>alert(1)</script>"))
    end

    it "allows wrong-cased named solidus references, which browsers do not decode" do
      assert(Loofah::HTML5::Scrub.allowed_uri?("data:text&SOL;html,<script>alert(1)</script>"))
    end

    it "disallows vbscript URIs" do
      refute(Loofah::HTML5::Scrub.allowed_uri?("vbscript:msgbox(1)"))
    end

    it "allows data URIs with safe mediatypes" do
      assert(Loofah::HTML5::Scrub.allowed_uri?("data:image/gif;base64,R0lGODlh"))
      assert(Loofah::HTML5::Scrub.allowed_uri?("data:image/png;base64,iVBORw0KGgo"))
      assert(Loofah::HTML5::Scrub.allowed_uri?("data:image/jpeg;base64,/9j/4AAQ"))
      assert(Loofah::HTML5::Scrub.allowed_uri?("data:text/plain,hello"))
      assert(Loofah::HTML5::Scrub.allowed_uri?("data:text/css,.foo{}"))
    end

    it "disallows data URIs with unsafe mediatypes" do
      refute(Loofah::HTML5::Scrub.allowed_uri?("data:text/html,<script>alert(1)</script>"))
      refute(Loofah::HTML5::Scrub.allowed_uri?("data:text/html;base64,PHNjcmlwdD5hbGVydCgxKTwvc2NyaXB0Pg=="))
      refute(Loofah::HTML5::Scrub.allowed_uri?("data:image/svg+xml,<svg onload=alert(1)>"))
      refute(Loofah::HTML5::Scrub.allowed_uri?("data:foo"))
    end

    it "disallows data URIs with a literal &#x70 in the mediatype" do
      refute(Loofah::HTML5::Scrub.allowed_uri?("data:&#x70text/html,<script>alert(1)</script>"))
      refute(Loofah::HTML5::Scrub.allowed_uri?("data:image/png&#x70,payload"))
    end

    it "treats a data URI with a malformed mediatype as text/plain" do
      assert(Loofah::HTML5::Scrub.allowed_uri?("data::text/html,<script>alert(1)</script>"))
      assert(Loofah::HTML5::Scrub.allowed_uri?("data:image/png:text/html,<script>alert(1)</script>"))
    end

    it "allows data URIs with an omitted mediatype, which defaults to text/plain" do
      assert(Loofah::HTML5::Scrub.allowed_uri?("data:,hello"))
      assert(Loofah::HTML5::Scrub.allowed_uri?("data:;base64,aGVsbG8="))
      assert(Loofah::HTML5::Scrub.allowed_uri?("data:;charset=utf-8,hello"))
    end

    it "disallows data URIs with no mediatype and no data" do
      refute(Loofah::HTML5::Scrub.allowed_uri?("data:"))
    end
  end

  describe ".data_uri_mediatype" do
    it "returns the mediatype of a valid data URI" do
      assert_equal("image/png", Loofah::HTML5::Scrub.send(:data_uri_mediatype, "data:image/png,x"))
      assert_equal("text/html", Loofah::HTML5::Scrub.send(:data_uri_mediatype, "data:text/html,x"))
      assert_equal("image/svg+xml", Loofah::HTML5::Scrub.send(:data_uri_mediatype, "data:image/svg+xml,x"))
    end

    it "returns the type/subtype without parameters" do
      assert_equal("text/plain", Loofah::HTML5::Scrub.send(:data_uri_mediatype, "data:text/plain;charset=utf-8,x"))
    end

    it "ignores the base64 flag" do
      assert_equal("image/png", Loofah::HTML5::Scrub.send(:data_uri_mediatype, "data:image/png;base64,x"))
      assert_equal("text/plain", Loofah::HTML5::Scrub.send(:data_uri_mediatype, "data:text/plain;charset=utf-8;base64,x"))
    end

    it "defaults an omitted mediatype to text/plain" do
      assert_equal("text/plain", Loofah::HTML5::Scrub.send(:data_uri_mediatype, "data:,x"))
      assert_equal("text/plain", Loofah::HTML5::Scrub.send(:data_uri_mediatype, "data:;base64,x"))
      assert_equal("text/plain", Loofah::HTML5::Scrub.send(:data_uri_mediatype, "data:;charset=utf-8,x"))
    end

    it "falls back to text/plain for a malformed mediatype" do
      assert_equal("text/plain", Loofah::HTML5::Scrub.send(:data_uri_mediatype, "data::text/html,x"))
      assert_equal("text/plain", Loofah::HTML5::Scrub.send(:data_uri_mediatype, "data:image/png:text/html,x"))
      assert_equal("text/plain", Loofah::HTML5::Scrub.send(:data_uri_mediatype, "data:foo,x"))
      assert_equal("text/plain", Loofah::HTML5::Scrub.send(:data_uri_mediatype, "data:image/,x"))
      assert_equal("text/plain", Loofah::HTML5::Scrub.send(:data_uri_mediatype, "data:/plain,x"))
    end

    it "does not treat a partial entity match as a separator" do
      assert_equal("image/png&#x3a0", Loofah::HTML5::Scrub.send(:data_uri_mediatype, "data:image/png&#x3a0,payload"))
      assert_equal("text/plain", Loofah::HTML5::Scrub.send(:data_uri_mediatype, "data:image/pngΠ,payload"))
    end

    it "strips whitespace around the mediatype" do
      assert_equal("text/plain", Loofah::HTML5::Scrub.send(:data_uri_mediatype, "data: text/plain ,x"))
    end

    it "splits on the first comma" do
      assert_equal("text/plain", Loofah::HTML5::Scrub.send(:data_uri_mediatype, "data:text/plain,a,b,c"))
    end

    it "returns nil when the required comma is absent" do
      assert_nil(Loofah::HTML5::Scrub.send(:data_uri_mediatype, "data:"))
      assert_nil(Loofah::HTML5::Scrub.send(:data_uri_mediatype, "data:image/png"))
      assert_nil(Loofah::HTML5::Scrub.send(:data_uri_mediatype, "data:text/plain"))
    end
  end

  describe ".prefixed_attribute_name" do
    it "qualifies a namespaced attribute with its prefix" do
      node = Loofah.html4_fragment(%(<svg><use xlink:href="#p"></use></svg>)).at_css("use")

      assert_equal(["xlink:href"], node.attribute_nodes.map { |a| Loofah::HTML5::Scrub.prefixed_attribute_name(a) })
    end

    it "uses the bare name when there is no namespace" do
      node = Loofah.html4_fragment(%(<a href="#p"></a>)).at_css("a")

      assert_equal(["href"], node.attribute_nodes.map { |a| Loofah::HTML5::Scrub.prefixed_attribute_name(a) })
    end
  end

  describe ".scrub_attribute_value" do
    it "reports that a removed uri attribute needs no further scrubbing" do
      node = Loofah.html4_fragment(%(<a href="javascript:alert(1)"></a>)).at_css("a")

      assert(Loofah::HTML5::Scrub.scrub_attribute_value(node, node.attribute_nodes.first))
      assert_empty(node.attribute_nodes)
    end

    it "reports that a permitted uri attribute still needs scrubbing" do
      node = Loofah.html4_fragment(%(<a href="http://example.com/"></a>)).at_css("a")

      refute(Loofah::HTML5::Scrub.scrub_attribute_value(node, node.attribute_nodes.first))
      assert_equal("http://example.com/", node["href"])
    end

    it "removes an svg href that is not a local reference" do
      node = Loofah.html4_fragment(%(<svg><use href="http://bad.com/x"></use></svg>)).at_css("use")

      refute(Loofah::HTML5::Scrub.scrub_attribute_value(node, node.attribute_nodes.first))
      assert_empty(node.attribute_nodes)
    end

    it "keeps an svg href that is a local reference" do
      node = Loofah.html4_fragment(%(<svg><use href="#p"></use></svg>)).at_css("use")

      refute(Loofah::HTML5::Scrub.scrub_attribute_value(node, node.attribute_nodes.first))
      assert_equal("#p", node["href"])
    end

    [:html4_fragment, :html5_fragment].each do |parse|
      ["href", "xlink:href"].each do |attr_name|
        it "removes a font-face-uri #{attr_name} that is not a local reference (#{parse})" do
          skip("html5 not supported") if parse == :html5_fragment && !Loofah.html5_support?
          node = Loofah.send(parse, %(<svg><font-face-uri #{attr_name}="http://bad.com/x"></font-face-uri></svg>)).at_css("font-face-uri")

          refute(Loofah::HTML5::Scrub.scrub_attribute_value(node, node.attribute_nodes.first))
          assert_empty(node.attribute_nodes)
        end

        it "keeps a font-face-uri #{attr_name} that is a local reference (#{parse})" do
          skip("html5 not supported") if parse == :html5_fragment && !Loofah.html5_support?
          node = Loofah.send(parse, %(<svg><font-face-uri #{attr_name}="#p"></font-face-uri></svg>)).at_css("font-face-uri")

          refute(Loofah::HTML5::Scrub.scrub_attribute_value(node, node.attribute_nodes.first))
          assert_equal(["#p"], node.attribute_nodes.map(&:value))
        end
      end
    end
  end

  describe ".scrub_attributes" do
    it "keeps scrubbing the remaining attributes after removing one" do
      fragment = Loofah.html4_fragment(%(<svg><use href="http://bad.com/x" fill="url(http://bad.com/) #fff"></use></svg>))

      assert_equal(%(<svg><use fill="#fff"></use></svg>), fragment.scrub!(:strip).to_s)
    end

    it "keeps scrubbing the remaining attributes after a uri attribute is removed" do
      fragment = Loofah.html4_fragment(%(<svg><use href="javascript:alert(1)" fill="url(http://bad.com/) #fff"></use></svg>))

      assert_equal(%(<svg><use fill="#fff"></use></svg>), fragment.scrub!(:strip).to_s)
    end
  end
end
