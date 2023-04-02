require "helper"

class UnitTestScrubber < Loofah::TestCase
  FRAGMENT = "<span>hello</span><span>goodbye</span>"
  FRAGMENT_NODE_COUNT = 4 # span, text, span, text
  FRAGMENT_NODE_STOP_TOP_DOWN = 2 # span, span
  DOCUMENT = "<html><head><link></link></head><body><span>hello</span><span>goodbye</span></body></html>"
  DOCUMENT_NODE_COUNT = 8 # html, head, link, body, span, text, span, text
  DOCUMENT_NODE_STOP_TOP_DOWN = 1 # html

  context "receiving a block" do
    before do
      @count = 0
    end

    context "returning CONTINUE" do
      before do
        @scrubber = Loofah::Scrubber.new do |node|
          @count += 1
          Loofah::Scrubber::CONTINUE
        end
      end

      it "operates properly" do
        Loofah.scrub_html4_fragment(FRAGMENT, @scrubber)
        assert_equal FRAGMENT_NODE_COUNT, @count
      end

      it "operates properly" do
        Loofah.scrub_html4_document(DOCUMENT, @scrubber)
        assert_equal DOCUMENT_NODE_COUNT, @count
      end

      it "operates properly" do
        Loofah.scrub_html5_fragment(FRAGMENT, @scrubber)
        assert_equal FRAGMENT_NODE_COUNT, @count
      end if Loofah.html5_support?

      it "operates properly" do
        Loofah.scrub_html5_document(DOCUMENT, @scrubber)
        assert_equal DOCUMENT_NODE_COUNT, @count
      end if Loofah.html5_support?
    end

    context "returning STOP" do
      before do
        @scrubber = Loofah::Scrubber.new do |node|
          @count += 1
          Loofah::Scrubber::STOP
        end
      end

      it "operates as top-down" do
        Loofah.scrub_html4_fragment(FRAGMENT, @scrubber)
        assert_equal FRAGMENT_NODE_STOP_TOP_DOWN, @count
      end

      it "operates as top-down" do
        Loofah.scrub_html4_document(DOCUMENT, @scrubber)
        assert_equal DOCUMENT_NODE_STOP_TOP_DOWN, @count
      end

      it "operates as top-down" do
        Loofah.scrub_html5_fragment(FRAGMENT, @scrubber)
        assert_equal FRAGMENT_NODE_STOP_TOP_DOWN, @count
      end if Loofah.html5_support?

      it "operates as top-down" do
        Loofah.scrub_html5_document(DOCUMENT, @scrubber)
        assert_equal DOCUMENT_NODE_STOP_TOP_DOWN, @count
      end if Loofah.html5_support?
    end

    context "returning neither CONTINUE nor STOP" do
      before do
        @scrubber = Loofah::Scrubber.new do |node|
          @count += 1
        end
      end

      it "acts as if CONTINUE was returned" do
        Loofah.scrub_html4_fragment(FRAGMENT, @scrubber)
        assert_equal FRAGMENT_NODE_COUNT, @count
      end

      it "acts as if CONTINUE was returned" do
        Loofah.scrub_html4_document(DOCUMENT, @scrubber)
        assert_equal DOCUMENT_NODE_COUNT, @count
      end

      it "acts as if CONTINUE was returned" do
        Loofah.scrub_html5_fragment(FRAGMENT, @scrubber)
        assert_equal FRAGMENT_NODE_COUNT, @count
      end if Loofah.html5_support?

      it "acts as if CONTINUE was returned" do
        Loofah.scrub_html5_document(DOCUMENT, @scrubber)
        assert_equal DOCUMENT_NODE_COUNT, @count
      end if Loofah.html5_support?
    end

    context "not specifying direction" do
      before do
        @scrubber = Loofah::Scrubber.new() do |node|
          @count += 1
          Loofah::Scrubber::STOP
        end
      end

      it "operates as top-down" do
        Loofah.scrub_html4_fragment(FRAGMENT, @scrubber)
        assert_equal FRAGMENT_NODE_STOP_TOP_DOWN, @count
      end

      it "operates as top-down" do
        Loofah.scrub_html4_document(DOCUMENT, @scrubber)
        assert_equal DOCUMENT_NODE_STOP_TOP_DOWN, @count
      end

      it "operates as top-down" do
        Loofah.scrub_html5_fragment(FRAGMENT, @scrubber)
        assert_equal FRAGMENT_NODE_STOP_TOP_DOWN, @count
      end if Loofah.html5_support?

      it "operates as top-down" do
        Loofah.scrub_html5_document(DOCUMENT, @scrubber)
        assert_equal DOCUMENT_NODE_STOP_TOP_DOWN, @count
      end if Loofah.html5_support?
    end

    context "specifying top-down direction" do
      before do
        @scrubber = Loofah::Scrubber.new(:direction => :top_down) do |node|
          @count += 1
          Loofah::Scrubber::STOP
        end
      end

      it "operates as top-down" do
        Loofah.scrub_html4_fragment(FRAGMENT, @scrubber)
        assert_equal FRAGMENT_NODE_STOP_TOP_DOWN, @count
      end

      it "operates as top-down" do
        Loofah.scrub_html4_document(DOCUMENT, @scrubber)
        assert_equal DOCUMENT_NODE_STOP_TOP_DOWN, @count
      end

      it "operates as top-down" do
        Loofah.scrub_html5_fragment(FRAGMENT, @scrubber)
        assert_equal FRAGMENT_NODE_STOP_TOP_DOWN, @count
      end if Loofah.html5_support?

      it "operates as top-down" do
        Loofah.scrub_html5_document(DOCUMENT, @scrubber)
        assert_equal DOCUMENT_NODE_STOP_TOP_DOWN, @count
      end if Loofah.html5_support?
    end

    context "specifying bottom-up direction" do
      before do
        @scrubber = Loofah::Scrubber.new(:direction => :bottom_up) do |node|
          @count += 1
        end
      end

      it "operates as bottom-up" do
        Loofah.scrub_html4_fragment(FRAGMENT, @scrubber)
        assert_equal FRAGMENT_NODE_COUNT, @count
      end

      it "operates as bottom-up" do
        Loofah.scrub_html4_document(DOCUMENT, @scrubber)
        assert_equal DOCUMENT_NODE_COUNT, @count
      end

      it "operates as bottom-up" do
        Loofah.scrub_html5_fragment(FRAGMENT, @scrubber)
        assert_equal FRAGMENT_NODE_COUNT, @count
      end if Loofah.html5_support?

      it "operates as bottom-up" do
        Loofah.scrub_html5_document(DOCUMENT, @scrubber)
        assert_equal DOCUMENT_NODE_COUNT, @count
      end if Loofah.html5_support?
    end

    context "invalid direction" do
      it "raise an exception" do
        assert_raises(ArgumentError) {
          Loofah::Scrubber.new(:direction => :quux) { }
        }
      end
    end

    context "given a block taking zero arguments" do
      before do
        @scrubber = Loofah::Scrubber.new do
          @count += 1
        end
      end

      it "works anyway, shrug" do
        Loofah.scrub_html4_fragment(FRAGMENT, @scrubber)
        assert_equal FRAGMENT_NODE_COUNT, @count
      end

      it "works anyway, shrug" do
        Loofah.scrub_html4_document(DOCUMENT, @scrubber)
        assert_equal DOCUMENT_NODE_COUNT, @count
      end

      it "works anyway, shrug" do
        Loofah.scrub_html5_fragment(FRAGMENT, @scrubber)
        assert_equal FRAGMENT_NODE_COUNT, @count
      end if Loofah.html5_support?

      it "works anyway, shrug" do
        Loofah.scrub_html5_document(DOCUMENT, @scrubber)
        assert_equal DOCUMENT_NODE_COUNT, @count
      end if Loofah.html5_support?
    end
  end

  context "defining a new Scrubber class" do
    before do
      @klass = Class.new(Loofah::Scrubber) do
        attr_accessor :count

        def initialize(direction = nil)
          @direction = direction
          @count = 0
        end

        def scrub(node)
          @count += 1
          Loofah::Scrubber::STOP
        end
      end
    end

    context "when not specifying direction" do
      before do
        @scrubber = @klass.new
        assert_nil @scrubber.direction
      end

      it "operates as top-down" do
        Loofah.scrub_html4_fragment(FRAGMENT, @scrubber)
        assert_equal FRAGMENT_NODE_STOP_TOP_DOWN, @scrubber.count
      end

      it "operates as top-down" do
        Loofah.scrub_html4_document(DOCUMENT, @scrubber)
        assert_equal DOCUMENT_NODE_STOP_TOP_DOWN, @scrubber.count
      end

      it "operates as top-down" do
        Loofah.scrub_html5_fragment(FRAGMENT, @scrubber)
        assert_equal FRAGMENT_NODE_STOP_TOP_DOWN, @scrubber.count
      end if Loofah.html5_support?

      it "operates as top-down" do
        Loofah.scrub_html5_document(DOCUMENT, @scrubber)
        assert_equal DOCUMENT_NODE_STOP_TOP_DOWN, @scrubber.count
      end if Loofah.html5_support?
    end

    context "when direction is specified as top_down" do
      before do
        @scrubber = @klass.new(:top_down)
        assert_equal :top_down, @scrubber.direction
      end

      it "operates as top-down" do
        Loofah.scrub_html4_fragment(FRAGMENT, @scrubber)
        assert_equal FRAGMENT_NODE_STOP_TOP_DOWN, @scrubber.count
      end

      it "operates as top-down" do
        Loofah.scrub_html4_document(DOCUMENT, @scrubber)
        assert_equal DOCUMENT_NODE_STOP_TOP_DOWN, @scrubber.count
      end

      it "operates as top-down" do
        Loofah.scrub_html5_fragment(FRAGMENT, @scrubber)
        assert_equal FRAGMENT_NODE_STOP_TOP_DOWN, @scrubber.count
      end if Loofah.html5_support?

      it "operates as top-down" do
        Loofah.scrub_html5_document(DOCUMENT, @scrubber)
        assert_equal DOCUMENT_NODE_STOP_TOP_DOWN, @scrubber.count
      end if Loofah.html5_support?
    end

    context "when direction is specified as bottom_up" do
      before do
        @scrubber = @klass.new(:bottom_up)
        assert_equal :bottom_up, @scrubber.direction
      end

      it "operates as bottom-up" do
        Loofah.scrub_html4_fragment(FRAGMENT, @scrubber)
        assert_equal FRAGMENT_NODE_COUNT, @scrubber.count
      end

      it "operates as bottom-up" do
        Loofah.scrub_html4_document(DOCUMENT, @scrubber)
        assert_equal DOCUMENT_NODE_COUNT, @scrubber.count
      end

      it "operates as bottom-up" do
        Loofah.scrub_html5_fragment(FRAGMENT, @scrubber)
        assert_equal FRAGMENT_NODE_COUNT, @scrubber.count
      end if Loofah.html5_support?

      it "operates as bottom-up" do
        Loofah.scrub_html5_document(DOCUMENT, @scrubber)
        assert_equal DOCUMENT_NODE_COUNT, @scrubber.count
      end if Loofah.html5_support?
    end
  end

  context "creating a new Scrubber class with no scrub method" do
    before do
      @klass = Class.new(Loofah::Scrubber) do
        def initialize; end
      end
      @scrubber = @klass.new
    end

    it "raises an exception" do
      assert_raises(Loofah::ScrubberNotFound) {
        Loofah.scrub_html4_fragment(FRAGMENT, @scrubber)
      }

      assert_raises(Loofah::ScrubberNotFound) {
        Loofah.scrub_html4_document(DOCUMENT, @scrubber)
      }

      assert_raises(Loofah::ScrubberNotFound) {
        Loofah.scrub_html5_fragment(FRAGMENT, @scrubber)
      } if Loofah.html5_support?

      assert_raises(Loofah::ScrubberNotFound) {
        Loofah.scrub_html5_document(DOCUMENT, @scrubber)
      } if Loofah.html5_support?
    end
  end
end
