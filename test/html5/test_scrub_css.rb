# frozen_string_literal: true

require "helper"

class UnitHTML5Scrub < Loofah::TestCase
  include Loofah

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
