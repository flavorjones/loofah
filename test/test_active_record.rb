require File.expand_path(File.join(File.dirname(__FILE__), 'helper'))

require 'loofah/active_record'

class TestActiveRecord < Test::Unit::TestCase

  HTML_STRING = "<div>omgwtfbbq</div>"
  PLAIN_TEXT = "vanilla text"

  context "with a Post model" do

    setup do
      ActsAsFu.build_model(:posts) do
        string :plain_text
        string :html_string
      end
    end

    context "scrubbing field as a fragment" do
      setup do
        Post.html_fragment :html_string, :scrub => :prune
        @post = Post.new :html_string => HTML_STRING, :plain_text => PLAIN_TEXT
      end

      should "scrub the specified field" do
        Loofah.expects(:scrub_fragment).with(HTML_STRING, :prune).once
        Loofah.expects(:scrub_fragment).with(PLAIN_TEXT, :prune).never
        @post.save
      end

      should "generate strings" do
        @post.save
        assert_equal String, @post.html_string.class
        assert_equal HTML_STRING, @post.html_string
      end
    end

    context "scrubbing field as a document" do
      setup do
        Post.html_document :html_string, :scrub => :strip
        @post = Post.new :html_string => HTML_STRING, :plain_text => PLAIN_TEXT
      end

      should "scrub the specified field, but not other fields" do
        Loofah.expects(:scrub_document).with(HTML_STRING, :strip).once
        Loofah.expects(:scrub_document).with(PLAIN_TEXT, :strip).never
        @post.save
      end

      should "generate strings" do
        @post.save
        assert_equal String, @post.html_string.class
      end
    end

    context "not passing any options" do
      should "raise ArgumentError" do
        assert_raises(ArgumentError) {
          Post.html_fragment :foo
        }
      end
    end

    context "not passing :scrub option" do
      should "raise ArgumentError" do
        assert_raise(ArgumentError) {
          Post.html_fragment :foo, :bar => :quux
        }
      end
    end

    context "passing a :scrub option" do
      should "not raise ArgumentError" do
        assert_nothing_raised {
          Post.html_fragment :foo, :scrub => :quux
        }
      end
    end

  end

end
