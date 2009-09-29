require File.expand_path(File.join(File.dirname(__FILE__), 'helper'))

class TestRailsReplacements < Test::Unit::TestCase

  HTML_STRING = "<div>omgwtfbbq</div>"

  context "when calling strip_tags" do
    should "invoke Loofah.scrub_fragment(:prune).text" do
      mock_doc = mock
      Loofah.expects(:fragment).with(HTML_STRING).returns(mock_doc)
      mock_doc.expects(:scrub!).with(:prune).returns(mock_doc)
      mock_doc.expects(:text)

      Loofah::Rails.strip_tags HTML_STRING
    end
  end

  context "when calling sanitize" do
    should "invoke Loofah.scrub_fragment(:escape).to_s" do
      mock_doc = mock
      Loofah.expects(:fragment).with(HTML_STRING).returns(mock_doc)
      mock_doc.expects(:scrub!).with(:escape).returns(mock_doc)
      mock_doc.expects(:to_s)

      Loofah::Rails.sanitize HTML_STRING
    end
  end

end
