# frozen_string_literal: true

require "helper"

class UnitTestScrubbers < Loofah::TestCase
  [LOOFAH_HTML_DOCUMENT_CLASSES, LOOFAH_HTML_DOCUMENT_CLASSES].flatten.each do |klass|
    context klass do
      context "bad scrub method" do
        it "raise a ScrubberNotFound exception" do
          doc = klass.parse("<p>foo</p>")
          assert_raises(Loofah::ScrubberNotFound) { doc.scrub!(:frippery) }
        end
      end
    end
  end
end
