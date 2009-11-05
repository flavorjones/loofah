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

      teardown do
        Loofah::Scrubber.undefine_filter(:count)
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

      teardown do
        Loofah::Scrubber.undefine_filter(:count)
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

    context "called on an existing filter name" do
      setup do
        Loofah::Scrubber.define_filter(:quux) { }
      end

      teardown do
        Loofah::Scrubber.undefine_filter(:quux)
      end

      should "raise an exception" do
        assert_raises(Loofah::Scrubber::FilterAlreadyDefined) {
          Loofah::Scrubber.define_filter(:quux) { }
        }
      end
    end

    context "given a string name" do
      setup do
        @called = false
        Loofah::Scrubber.define_filter("quux") { @called = true }
      end

      teardown do
        Loofah::Scrubber.undefine_filter(:quux)
      end

      should "work as if given a symbol" do
        Loofah.scrub_fragment("<div>hello</div>", :quux)
        assert @called
      end
    end

    context "given a block taking zero arguments" do
      setup do
        @called = false
        Loofah::Scrubber.define_filter(:quux) { @called = true }
      end

      teardown do
        Loofah::Scrubber.undefine_filter(:quux)
      end

      should "work anyway, shrug" do
        Loofah.scrub_fragment("<div>hello</div>", :quux)
        assert @called
      end
    end

    context "when passed to scrub as a string" do
      setup do
        @called = false
        Loofah::Scrubber.define_filter(:quux) { @called = true }
      end

      teardown do
        Loofah::Scrubber.undefine_filter(:quux)
      end

      should "work as if passed a symbol" do
        Loofah.scrub_fragment("<div>hello</div>", "quux")
        assert @called
      end
    end

  end

  context "undefine_filter" do
    setup do
      Loofah::Scrubber.define_filter(:quux) { |node| Loofah::Scrubber::CONTINUE }
    end

    teardown do
      Loofah::Scrubber.undefine_filter(:quux)
    end

    context "given a symbol" do
      should "remove the named filter" do
        assert_nothing_raised { Loofah.scrub_fragment("<div>hello</div>", :quux) }
        Loofah::Scrubber.undefine_filter(:quux)
        assert_raises(Loofah::Scrubber::NoSuchFilter) { Loofah.scrub_fragment("<div>hello</div>", :quux) }
      end
    end

    context "given a string" do
      should "remove the named filter" do
        assert_nothing_raised { Loofah.scrub_fragment("<div>hello</div>", :quux) }
        Loofah::Scrubber.undefine_filter("quux")
        assert_raises(Loofah::Scrubber::NoSuchFilter) { Loofah.scrub_fragment("<div>hello</div>", :quux) }
      end
    end
  end
end
