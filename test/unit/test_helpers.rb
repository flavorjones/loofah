require File.expand_path(File.join(File.dirname(__FILE__), '..', 'helper'))

class TestHelpers < Test::Unit::TestCase

  HTML_STRING = "<div>omgwtfbbq</div>"

  context "#strip_tags" do
    should "invoke Loofah.fragment.text" do
      mock_doc = mock
      Loofah.expects(:fragment).with(HTML_STRING).returns(mock_doc)
      mock_doc.expects(:text)

      Loofah::Helpers.strip_tags HTML_STRING
    end
  end

  context "#sanitize" do
    should "invoke Loofah.scrub_fragment(:strip).to_s" do
      mock_doc = mock
      Loofah.expects(:fragment).with(HTML_STRING).returns(mock_doc)
      mock_doc.expects(:scrub!).with(:strip).returns(mock_doc)
      mock_doc.expects(:to_s)

      Loofah::Helpers.sanitize HTML_STRING
    end
  end
end
