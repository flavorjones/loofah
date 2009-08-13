require File.expand_path(File.join(File.dirname(__FILE__), 'helper'))

require 'loofah/xss_foliate'

class TestXssFoliate < Test::Unit::TestCase

  HTML_STRING = "<div>omgwtfbbq</div>"
  PLAIN_TEXT = "vanilla text"
  INTEGER_VALUE = "1234"

  context "with a Post model" do
    setup do
      ActsAsFu.build_model(:posts) do
        string :plain_text
        string :html_string
        integer :not_a_string

        Post.send(:include, Loofah::XssFoliate)
        Post.xss_foliate
      end
    end

    context "on all fields" do
      setup do
        @post = Post.new :html_string => HTML_STRING, :plain_text => PLAIN_TEXT, :not_a_string => INTEGER_VALUE
      end

      should "scrub all fields" do
        Loofah.expects(:scrub_fragment).with(HTML_STRING, :strip).once
        Loofah.expects(:scrub_fragment).with(PLAIN_TEXT, :strip).once
        Loofah.expects(:scrub_fragment).with(INTEGER_VALUE, :strip).never
        assert @post.valid?
      end
    end

    context "omitting one field" do
      setup do
        Post.xss_foliate :except => [:plain_text]
        @post = Post.new :html_string => HTML_STRING, :plain_text => PLAIN_TEXT, :not_a_string => INTEGER_VALUE
      end

      should "not scrub omitted field" do
        Loofah.expects(:scrub_fragment).with(HTML_STRING, :strip).once
        Loofah.expects(:scrub_fragment).with(PLAIN_TEXT, :strip).never
        Loofah.expects(:scrub_fragment).with(INTEGER_VALUE, :strip).never
        assert @post.valid?
      end
    end

    [:strip, :escape].each do |method|
      context "declaring one field to be scrubbed with #{method}" do
        setup do
          Post.xss_foliate method => [:plain_text]
          @post = Post.new :html_string => HTML_STRING, :plain_text => PLAIN_TEXT, :not_a_string => INTEGER_VALUE
        end

        should "not that field appropriately" do
          Loofah.expects(:scrub_fragment).with(HTML_STRING, :strip).once
          Loofah.expects(:scrub_fragment).with(PLAIN_TEXT, method).once
          Loofah.expects(:scrub_fragment).with(INTEGER_VALUE, :strip).never
          assert @post.valid?
        end
      end
    end

    context "declaring one field to be scrubbed with html5lib_sanitize" do
      setup do
        Post.xss_foliate :html5lib_sanitize => [:plain_text]
        @post = Post.new :html_string => HTML_STRING, :plain_text => PLAIN_TEXT, :not_a_string => INTEGER_VALUE
      end

      should "not that field appropriately" do
        Loofah.expects(:scrub_fragment).with(HTML_STRING, :strip).once
        Loofah.expects(:scrub_fragment).with(PLAIN_TEXT, :escape).once
        Loofah.expects(:scrub_fragment).with(INTEGER_VALUE, :strip).never
        assert @post.valid?
      end
    end

    context "invalid model data" do
      setup do
        Post.xss_foliate
        Post.validates_presence_of :html_string
        @post = Post.new :html_string => " <br> "
      end

      should "not be valid after sanitizing" do
        Loofah.expects(:scrub_fragment).with(" <br> ", :strip).once
        assert ! @post.valid?
      end
    end

  end
end
