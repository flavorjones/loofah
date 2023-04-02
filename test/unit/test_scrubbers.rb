require "helper"

class UnitTestScrubbers < Loofah::TestCase
  [
    Loofah::HTML4::Document,
    Loofah::HTML4::DocumentFragment,
    Loofah::HTML5::Document,
    Loofah::HTML5::DocumentFragment,
  ].each do |klass|
    context klass do
      context "bad scrub method" do
        it "raise a ScrubberNotFound exception" do
          doc = klass.parse "<p>foo</p>"
          assert_raises(Loofah::ScrubberNotFound) { doc.scrub! :frippery }
        end
      end
    end
  end
end
