require "helper"

class UnitTestHelpers < Loofah::TestCase

  HTML_STRING = "<div>omgwtfbbq</div>"

  context "#strip_tags" do
    it "invoke Loofah.fragment.text" do
      mock_doc = Object.new
      mock(Loofah).fragment(HTML_STRING) { mock_doc }
      mock(mock_doc).text

      Loofah::Helpers.strip_tags HTML_STRING
    end
  end

  context "#sanitize" do
    it "invoke Loofah.scrub_fragment(:strip).to_s" do
      mock_doc = Object.new
      mock(Loofah).fragment(HTML_STRING) { mock_doc }
      mock(mock_doc).scrub!(:strip) { mock_doc }
      mock(mock_doc).to_s

      Loofah::Helpers.sanitize HTML_STRING
    end
  end
end
