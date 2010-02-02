require File.expand_path(File.join(File.dirname(__FILE__), '..', 'helper'))

class TestScrubber < Test::Unit::TestCase

  FRAGMENT = "<span>hello</span><span>goodbye</span>"
  FRAGMENT_NODE_COUNT         = 4 # span, text, span, text
  FRAGMENT_NODE_STOP_TOP_DOWN = 2 # span, span
  DOCUMENT = "<html><head><link></link></head><body><span>hello</span><span>goodbye</span></body></html>"
  DOCUMENT_NODE_COUNT         = 8 # html, head, link, body, span, text, span, text
  DOCUMENT_NODE_STOP_TOP_DOWN = 1 # html

  context "receiving a block" do
    setup do
      @count = 0
    end

    context "returning CONTINUE" do
      setup do
        @scrubber = Loofah::Scrubber.new do |node|
          @count += 1
          Loofah::Scrubber::CONTINUE
        end
      end

      should "operate properly on a fragment" do
        Loofah.scrub_fragment(FRAGMENT, @scrubber)
        assert_equal FRAGMENT_NODE_COUNT, @count
      end

      should "operate properly on a document" do
        Loofah.scrub_document(DOCUMENT, @scrubber)
        assert_equal DOCUMENT_NODE_COUNT, @count
      end
    end

    context "returning STOP" do
      setup do
        @scrubber = Loofah::Scrubber.new do |node|
          @count += 1
          Loofah::Scrubber::STOP
        end
      end

      should "operate as top-down on a fragment" do
        Loofah.scrub_fragment(FRAGMENT, @scrubber)
        assert_equal FRAGMENT_NODE_STOP_TOP_DOWN, @count
      end

      should "operate as top-down on a document" do
        Loofah.scrub_document(DOCUMENT, @scrubber)
        assert_equal DOCUMENT_NODE_STOP_TOP_DOWN, @count
      end
    end

    context "returning neither CONTINUE nor STOP" do
      setup do
        @scrubber = Loofah::Scrubber.new do |node|
          @count += 1
        end
      end

      should "act as if CONTINUE was returned" do
        Loofah.scrub_fragment(FRAGMENT, @scrubber)
        assert_equal FRAGMENT_NODE_COUNT, @count
      end
    end

    context "not specifying direction" do
      setup do
        @scrubber = Loofah::Scrubber.new() do |node|
          @count += 1
          Loofah::Scrubber::STOP
        end
      end

      should "operate as top-down on a fragment" do
        Loofah.scrub_fragment(FRAGMENT, @scrubber)
        assert_equal FRAGMENT_NODE_STOP_TOP_DOWN, @count
      end

      should "operate as top-down on a document" do
        Loofah.scrub_document(DOCUMENT, @scrubber)
        assert_equal DOCUMENT_NODE_STOP_TOP_DOWN, @count
      end
    end

    context "specifying top-down direction" do
      setup do
        @scrubber = Loofah::Scrubber.new(:direction => :top_down) do |node|
          @count += 1
          Loofah::Scrubber::STOP
        end
      end

      should "operate as top-down on a fragment" do
        Loofah.scrub_fragment(FRAGMENT, @scrubber)
        assert_equal FRAGMENT_NODE_STOP_TOP_DOWN, @count
      end

      should "operate as top-down on a document" do
        Loofah.scrub_document(DOCUMENT, @scrubber)
        assert_equal DOCUMENT_NODE_STOP_TOP_DOWN, @count
      end
    end

    context "specifying bottom-up direction" do
      setup do
        @scrubber = Loofah::Scrubber.new(:direction => :bottom_up) do |node|
          @count += 1
        end
      end

      should "operate as bottom-up on a fragment" do
        Loofah.scrub_fragment(FRAGMENT, @scrubber)
        assert_equal FRAGMENT_NODE_COUNT, @count
      end

      should "operate as bottom-up on a document" do
        Loofah.scrub_document(DOCUMENT, @scrubber)
        assert_equal DOCUMENT_NODE_COUNT, @count
      end
    end

    context "invalid direction" do
      should "raise an exception" do
        assert_raises(ArgumentError) {
          Loofah::Scrubber.new(:direction => :quux) { }
        }
      end
    end

    context "given a block taking zero arguments" do
      setup do
        @scrubber = Loofah::Scrubber.new do
          @count += 1
        end
      end

      should "work anyway, shrug" do
        Loofah.scrub_fragment(FRAGMENT, @scrubber)
        assert_equal FRAGMENT_NODE_COUNT, @count
      end
    end
  end

  context "defining a new Scrubber class" do
    setup do
      @klass = Class.new(Loofah::Scrubber) do
        attr_accessor :count

        def initialize(direction=nil)
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
      setup do
        @scrubber = @klass.new
        assert_nil @scrubber.direction
      end

      should "operate as top-down on a fragment" do
        Loofah.scrub_fragment(FRAGMENT, @scrubber)
        assert_equal FRAGMENT_NODE_STOP_TOP_DOWN, @scrubber.count
      end

      should "operate as top-down on a document" do
        Loofah.scrub_document(DOCUMENT, @scrubber)
        assert_equal DOCUMENT_NODE_STOP_TOP_DOWN, @scrubber.count
      end
    end

    context "when direction is specified as top_down" do
      setup do
        @scrubber = @klass.new(:top_down)
        assert_equal :top_down, @scrubber.direction
      end

      should "operate as top-down on a fragment" do
        Loofah.scrub_fragment(FRAGMENT, @scrubber)
        assert_equal FRAGMENT_NODE_STOP_TOP_DOWN, @scrubber.count
      end

      should "operate as top-down on a document" do
        Loofah.scrub_document(DOCUMENT, @scrubber)
        assert_equal DOCUMENT_NODE_STOP_TOP_DOWN, @scrubber.count
      end
    end

    context "when direction is specified as bottom_up" do
      setup do
        @scrubber = @klass.new(:bottom_up)
        assert_equal :bottom_up, @scrubber.direction
      end

      should "operate as bottom-up on a fragment" do
        Loofah.scrub_fragment(FRAGMENT, @scrubber)
        assert_equal FRAGMENT_NODE_COUNT, @scrubber.count
      end

      should "operate as bottom-up on a document" do
        Loofah.scrub_document(DOCUMENT, @scrubber)
        assert_equal DOCUMENT_NODE_COUNT, @scrubber.count
      end
    end
  end

  context "creating a new Scrubber class with no scrub method" do
    setup do
      @klass = Class.new(Loofah::Scrubber) do
        def initialize ; end
      end
      @scrubber = @klass.new
    end

    should "raise an exception" do
      assert_raises(Loofah::ScrubberNotFound) {
        Loofah.scrub_fragment(FRAGMENT, @scrubber)
      }
    end
  end
end
