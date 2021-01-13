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
      assert_equal "background-color:linear-gradient(transparent 50%, #ffff66 50%);",
                   Loofah::HTML5::Scrub.scrub_css("background-color: linear-gradient(transparent 50%, #ffff66 50%);")
    end

    it "disallows unsafe functions" do
      assert_equal "", Loofah::HTML5::Scrub.scrub_css("background-color: haxxor-fun(transparent 50%, #ffff66 50%);")
    end

    # see #199 for the bug we're testing here
    it "allows safe functions in shorthand css properties" do
      assert_equal "background:linear-gradient(transparent 50%, #ffff66 50%);",
                   Loofah::HTML5::Scrub.scrub_css("background: linear-gradient(transparent 50%, #ffff66 50%);")
    end
  end
end
