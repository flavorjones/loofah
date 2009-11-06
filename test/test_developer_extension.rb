require File.expand_path(File.join(File.dirname(__FILE__), 'helper'))

class TestFilter < Test::Unit::TestCase
  context "returning CONTINUE" do
    setup do
      @count = 0
      @filter = Loofah::Filter.new do |node|
        @count += 1
        Loofah::Scrubber::CONTINUE
      end
    end

    should "operate properly on a fragment" do
      Loofah.scrub_fragment("<span>hello</span><span>goodbye</span>", @filter)
      assert_equal 4, @count # span, text, span, text
    end

    should "operate properly on a document" do
      Loofah.scrub_document("<html><head><link></link></head><body><span>hello</span><span>goodbye</span></body></html>", @filter)
      assert_equal 5, @count # link, span, text, span, text
    end
  end

  context "returning STOP" do
    setup do
      @count = 0
      @filter = Loofah::Filter.new do |node|
        @count += 1
        Loofah::Scrubber::STOP
      end
    end

    should "operate as top-down on a fragment" do
      Loofah.scrub_fragment("<span>hello</span><span>goodbye</span>", @filter)
      assert_equal 2, @count # span, text, span, text
    end

    should "operate as top-down on a document" do
      Loofah.scrub_document("<html><head><link></link></head><body><span>hello</span><span>goodbye</span></body></html>", @filter)
      assert_equal 3, @count # link, span, span
    end
  end

  context "top-down direction" do
    setup do
      @count = 0
      @filter = Loofah::Filter.new(:direction => :top_down) do |node|
        @count += 1
        Loofah::Scrubber::STOP
      end
    end

    should "operate as top-down on a fragment" do
      Loofah.scrub_fragment("<span>hello</span><span>goodbye</span>", @filter)
      assert_equal 2, @count # span, text, span, text
    end

    should "operate as top-down on a document" do
      Loofah.scrub_document("<html><head><link></link></head><body><span>hello</span><span>goodbye</span></body></html>", @filter)
      assert_equal 3, @count # link, span, span
    end
  end

  context "bottom-up direction" do
    setup do
      @count = 0
      @filter = Loofah::Filter.new(:direction => :bottom_up) do |node|
        @count += 1
        Loofah::Scrubber::STOP
      end
    end

    should "operate as bottom-up on a fragment" do
      Loofah.scrub_fragment("<span>hello</span><span>goodbye</span>", @filter)
      assert_equal 4, @count # span, text, span, text
    end

    should "operate as bottom-up on a document" do
      Loofah.scrub_document("<html><head><link></link></head><body><span>hello</span><span>goodbye</span></body></html>", @filter)
      assert_equal 5, @count # link, span, span
    end
  end

  context "invalid direction" do
    should "raise an exception" do
      assert_raises(ArgumentError) {
        Loofah::Filter.new(:direction => :quux) { }
      }
    end
  end

  context "given a block taking zero arguments" do
    setup do
      @called = false
      @filter = Loofah::Filter.new { @called = true }
    end

    should "work anyway, shrug" do
      Loofah.scrub_fragment("<div>hello</div>", @filter)
      assert @called
    end
  end
end
