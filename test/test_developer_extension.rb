require File.expand_path(File.join(File.dirname(__FILE__), 'helper'))

class TestDeveloperExtension < Test::Unit::TestCase
  context "define_filter" do
    context "returning CONTINUE" do
      setup do
        @count = 0
        Loofah::Scrubber.define_filter(:count) do |node|
          @count += 1
          Loofah::Scrubber::CONTINUE
        end
      end

      should "operate properly on a fragment" do
        Loofah.scrub_fragment("<span>hello</span><span>goodbye</span>", :count)
        assert_equal 4, @count # span, text, span, text
      end

      should "operate properly on a document" do
        Loofah.scrub_document("<html><head><link></link></head><body><span>hello</span><span>goodbye</span></body></html>", :count)
        assert_equal 5, @count # link, span, text, span, text
      end
    end

    context "returning STOP" do
      setup do
        @count = 0
        Loofah::Scrubber.define_filter(:count) do |node|
          @count += 1
          Loofah::Scrubber::STOP
        end
      end

      should "operate properly on a fragment" do
        Loofah.scrub_fragment("<span>hello</span><span>goodbye</span>", :count)
        assert_equal 2, @count # span, text, span, text
      end

      should "operate properly on a document" do
        Loofah.scrub_document("<html><head><link></link></head><body><span>hello</span><span>goodbye</span></body></html>", :count)
        assert_equal 3, @count # link, span, span
      end
    end
  end

  context "undefine_filter" do
    setup do
      Loofah::Scrubber.define_filter(:quux) { |node| Loofah::Scrubber::CONTINUE }
    end

    should "remove the named filter" do
      assert_nothing_raised { Loofah.scrub_fragment("<div>hello</div>", :quux) }
      Loofah::Scrubber.undefine_filter(:quux)
      assert_raises(Loofah::Scrubber::NoSuchFilter) { Loofah.scrub_fragment("<div>hello</div>", :quux) }
    end
  end
end
