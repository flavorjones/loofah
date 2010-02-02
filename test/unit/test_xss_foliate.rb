require File.expand_path(File.join(File.dirname(__FILE__), '..', 'helper'))

class TestXssFoliate < Test::Unit::TestCase

  HTML_STRING = "<div>omgwtfbbq</div>"
  PLAIN_TEXT = "vanilla text"
  INTEGER_VALUE = "1234"
  WHITESPACEY = " <br> "

  def new_post(overrides={})
    Post.new({:html_string => HTML_STRING, :plain_text => PLAIN_TEXT, :not_a_string => INTEGER_VALUE}.merge(overrides))
  end

  context "with a Post model" do
    setup do
      ActsAsFu.build_model(:posts) do
        string :plain_text
        string :html_string
        integer :not_a_string
      end
    end

    context "#xss_foliated?" do
      context "when xss_foliate has not been called" do
        should "return false" do
          assert ! Post.xss_foliated?
        end
      end

      context "when xss_foliate has been called with no options" do
        setup do
          Post.xss_foliate
        end

        should "return true" do
          assert Post.xss_foliated?
        end
      end

      context "when xss_foliate has been called with options" do
        setup do
          Post.xss_foliate :prune => :plain_text
        end

        should "return true" do
          assert Post.xss_foliated?
        end
      end
    end

    context "#xss_foliate" do
      context "when passed invalid option" do
        should "raise ArgumentError" do
          assert_raise(ArgumentError) { Post.xss_foliate :quux => [:foo] }
        end
      end

      context "when passed a symbol" do
        should "calls the right scrubber" do
          assert_nothing_raised(ArgumentError) { Post.xss_foliate :prune => :plain_text }
          Loofah.expects(:scrub_fragment).with(HTML_STRING, :strip).once
          Loofah.expects(:scrub_fragment).with(PLAIN_TEXT,  :prune).once
          new_post.valid?
        end
      end

      context "when passed an array of symbols" do
        should "calls the right scrubbers" do
          assert_nothing_raised(ArgumentError) {
            Post.xss_foliate :prune => [:plain_text, :html_string]
          }
          Loofah.expects(:scrub_fragment).with(HTML_STRING, :prune).once
          Loofah.expects(:scrub_fragment).with(PLAIN_TEXT,  :prune).once
          new_post.valid?
        end
      end

      context "when passed a string" do
        should "calls the right scrubber" do
          assert_nothing_raised(ArgumentError) { Post.xss_foliate :prune => 'plain_text' }
          Loofah.expects(:scrub_fragment).with(HTML_STRING, :strip).once
          Loofah.expects(:scrub_fragment).with(PLAIN_TEXT,  :prune).once
          new_post.valid?
        end
      end

      context "when passed an array of strings" do
        should "calls the right scrubbers" do
          assert_nothing_raised(ArgumentError) {
            Post.xss_foliate :prune => ['plain_text', 'html_string']
          }
          Loofah.expects(:scrub_fragment).with(HTML_STRING, :prune).once
          Loofah.expects(:scrub_fragment).with(PLAIN_TEXT,  :prune).once
          new_post.valid?
        end
      end
    end

    context "declaring scrubbed fields" do
      context "on all fields" do
        setup do
          Post.xss_foliate
        end

        should "scrub all fields" do
          mock_doc = mock
          Loofah.expects(:scrub_fragment).with(HTML_STRING,   :strip).once.returns(mock_doc)
          Loofah.expects(:scrub_fragment).with(PLAIN_TEXT,    :strip).once.returns(mock_doc)
          Loofah.expects(:scrub_fragment).with(INTEGER_VALUE, :strip).never
          mock_doc.expects(:text).twice
          assert new_post.valid?
        end
      end

      context "omitting one field" do
        setup do
          Post.xss_foliate :except => [:plain_text]
        end

        should "not scrub omitted field" do
          mock_doc = mock
          Loofah.expects(:scrub_fragment).with(HTML_STRING,   :strip).once.returns(mock_doc)
          Loofah.expects(:scrub_fragment).with(PLAIN_TEXT,    :strip).never
          Loofah.expects(:scrub_fragment).with(INTEGER_VALUE, :strip).never
          mock_doc.expects(:text).once
          new_post.valid?
        end
      end

      Loofah::Scrubbers.scrubber_symbols.each do |method|
        context "declaring one field to be scrubbed with #{method}" do
          setup do
            Post.xss_foliate method => [:plain_text]
          end

          should "scrub that field appropriately" do
            mock_doc = mock
            Loofah.expects(:scrub_fragment).with(HTML_STRING,   :strip).once
            Loofah.expects(:scrub_fragment).with(PLAIN_TEXT,    method).once.returns(mock_doc)
            Loofah.expects(:scrub_fragment).with(INTEGER_VALUE, :strip).never
            mock_doc.expects(:to_s)
            new_post.valid?
          end
        end
      end

      context "declaring one field to be scrubbed with html5lib_sanitize" do
        setup do
          Post.xss_foliate :html5lib_sanitize => [:plain_text]
        end

        should "not that field appropriately" do
          Loofah.expects(:scrub_fragment).with(HTML_STRING,   :strip) .once
          Loofah.expects(:scrub_fragment).with(PLAIN_TEXT,    :escape).once
          Loofah.expects(:scrub_fragment).with(INTEGER_VALUE, :strip) .never
          new_post.valid?
        end
      end
    end

    context "invalid model data" do
      setup do
        Post.validates_presence_of :html_string
        Post.xss_foliate
      end

      should "not be valid after sanitizing" do
        Loofah.expects(:scrub_fragment).with(WHITESPACEY, :strip).once
        Loofah.expects(:scrub_fragment).with(PLAIN_TEXT,  :strip).once
        assert ! new_post(:html_string => WHITESPACEY).valid?
      end
    end

    context "given an XSS attempt" do
      setup do
        Post.xss_foliate :strip => :html_string
      end

      should "escape html entities" do
        hackattack = "<div>&lt;script&gt;alert('evil')&lt;/script&gt;</div>"
        post = new_post :html_string => hackattack, :plain_text => hackattack
        post.valid?
        assert_equal "<div>&lt;script&gt;alert('evil')&lt;/script&gt;</div>", post.html_string
        assert_equal "&lt;script&gt;alert('evil')&lt;/script&gt;", post.plain_text
      end
    end
  end
end
