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

    it "disallows javascript URIs with control characters in HTML entities" do
      refute(Loofah::HTML5::Scrub.allowed_uri?("java&#1\x0015;cript:alert(1)"))
      refute(Loofah::HTML5::Scrub.allowed_uri?("java&#x\t73;cript:alert(1)"))
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
  end
end
