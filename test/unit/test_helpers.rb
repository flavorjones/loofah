require "helper"

class UnitTestHelpers < Loofah::TestCase
  HTML_STRING = "<div>omgwtfbbq</div>"

  describe "Helpers" do
    context ".strip_tags" do
      it "invokes Loofah.html4_fragment.text" do
        mock_doc = MiniTest::Mock.new
        mock_doc.expect(:text, "string_value", [])

        Loofah.stub(:html4_fragment, mock_doc) do
          Loofah::Helpers.strip_tags(HTML_STRING)
        end

        mock_doc.verify
      end
    end

    context ".sanitize" do
      it "invokes Loofah.scrub_html4_fragment(input, :strip).to_s" do
        mock_doc = MiniTest::Mock.new
        mock_doc.expect(:scrub!, mock_doc, [:strip])
        mock_doc.expect(:xpath, [], ["./form"])
        mock_doc.expect(:to_s, "string_value", [])

        Loofah.stub(:html4_fragment, mock_doc) do
          Loofah::Helpers.sanitize(HTML_STRING)
        end

        mock_doc.verify
      end
    end

    context ".sanitize_css" do
      it "invokes HTML5lib's css scrubber" do
        actual = nil
        Loofah::HTML5::Scrub.stub(:scrub_css, "scrubbed", ["foobar"]) do
          actual = Loofah::Helpers.sanitize_css("foobar")
        end

        assert_equal("scrubbed", actual)
      end
    end

    describe "ActionView" do
      describe "FullSanitizer#sanitize" do
        it "calls .strip_tags" do
          actual = nil
          Loofah::Helpers.stub(:strip_tags, "stripped", ["foobar"]) do
            actual = Loofah::Helpers::ActionView::FullSanitizer.new.sanitize("foobar")
          end

          assert_equal("stripped", actual)
        end
      end

      describe "SafeListSanitizer#sanitize" do
        it "calls .sanitize" do
          actual = nil
          Loofah::Helpers.stub(:sanitize, "sanitized", ["foobar"]) do
            actual = Loofah::Helpers::ActionView::SafeListSanitizer.new.sanitize("foobar")
          end

          assert_equal("sanitized", actual)
        end
      end

      describe "SafeListSanitizer#sanitize_css" do
        it "calls .sanitize_css" do
          actual = nil
          Loofah::Helpers.stub(:sanitize_css, "sanitized", ["foobar"]) do
            actual = Loofah::Helpers::ActionView::SafeListSanitizer.new.sanitize_css "foobar"
          end

          assert_equal("sanitized", actual)
        end
      end
    end
  end
end
