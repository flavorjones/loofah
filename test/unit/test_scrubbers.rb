require File.expand_path(File.join(File.dirname(__FILE__), '..', 'helper'))

class TestScrubbers < Test::Unit::TestCase
  [ Loofah::HTML::Document, Loofah::HTML::DocumentFragment ].each do |klass|
    context klass do
      context "bad scrub method" do
        should "raise a ScrubberNotFound exception" do
          doc = klass.parse "<p>foo</p>"
          assert_raises(Loofah::ScrubberNotFound) { doc.scrub! :frippery }
        end
      end
    end
  end
end
