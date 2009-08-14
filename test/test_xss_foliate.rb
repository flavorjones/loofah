require File.expand_path(File.join(File.dirname(__FILE__), 'helper'))

require 'loofah/xss_foliate'

class TestXssFoliate < Test::Unit::TestCase

  HTML_STRING = "<div>omgwtfbbq</div>"
  PLAIN_TEXT = "vanilla text"
  INTEGER_VALUE = "1234"
  WHITESPACEY = " <br> "

  def new_post(overrides={})
    Post.new({:html_string => HTML_STRING, :plain_text => PLAIN_TEXT, :not_a_string => INTEGER_VALUE}.merge(overrides))
  end

  def fork_success?
    Process.fork do
      begin
        yield
      rescue
        puts "ERROR: fork_success?() caught exception '#{$!}', returning false"
        exit 1
      end
      exit 0
    end
    Process.wait
    $?.exitstatus == 0
  end

  context "with a Post model" do
    setup do
      ActsAsFu.build_model(:posts) do
        string :plain_text
        string :html_string
        integer :not_a_string
      end
    end

    context "#xss_foliate" do
      context "when passed invalid option" do
        should "raise ArgumentError" do
          assert_raise(ArgumentError) { Post.xss_foliate :quux => [:foo] }
        end
      end

      context "when passed a non-array" do
        should "handle it silently" do
          assert_nothing_raised(ArgumentError) { Post.xss_foliate :prune => :plain_text }
          Loofah.expects(:scrub_fragment).with(HTML_STRING, :strip).once
          Loofah.expects(:scrub_fragment).with(PLAIN_TEXT, :prune).once
          assert new_post.valid?
        end
      end

      context "when passed an array" do
        should "do the right thing" do
          assert_nothing_raised(ArgumentError) {
            Post.xss_foliate :prune => [:plain_text, :html_string]
          }
          Loofah.expects(:scrub_fragment).with(HTML_STRING, :prune).once
          Loofah.expects(:scrub_fragment).with(PLAIN_TEXT, :prune).once
          assert new_post.valid?
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
          Loofah.expects(:scrub_fragment).with(HTML_STRING, :strip).once.returns(mock_doc)
          Loofah.expects(:scrub_fragment).with(PLAIN_TEXT, :strip).once.returns(mock_doc)
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
          Loofah.expects(:scrub_fragment).with(HTML_STRING, :strip).once
          Loofah.expects(:scrub_fragment).with(PLAIN_TEXT, :strip).never
          Loofah.expects(:scrub_fragment).with(INTEGER_VALUE, :strip).never
          assert new_post.valid?
        end
      end

      [:strip, :escape, :prune].each do |method|
        context "declaring one field to be scrubbed with #{method}" do
          setup do
            Post.xss_foliate method => [:plain_text]
          end

          should "not that field appropriately" do
            Loofah.expects(:scrub_fragment).with(HTML_STRING, :strip).once
            Loofah.expects(:scrub_fragment).with(PLAIN_TEXT, method).once
            Loofah.expects(:scrub_fragment).with(INTEGER_VALUE, :strip).never
            assert new_post.valid?
          end
        end
      end

      context "declaring one field to be scrubbed with html5lib_sanitize" do
        setup do
          Post.xss_foliate :html5lib_sanitize => [:plain_text]
        end

        should "not that field appropriately" do
          Loofah.expects(:scrub_fragment).with(HTML_STRING, :strip).once
          Loofah.expects(:scrub_fragment).with(PLAIN_TEXT, :escape).once
          Loofah.expects(:scrub_fragment).with(INTEGER_VALUE, :strip).never
          assert new_post.valid?
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
        Loofah.expects(:scrub_fragment).with(PLAIN_TEXT, :strip).once
        assert ! new_post(:html_string => WHITESPACEY).valid?
      end
    end

    context "verifying that forking in a should works as expected" do
      should "return nonzero exit code" do
        assert ! fork_success? { assert false }
      end

      should "return zero exit code" do
        assert fork_success? { assert true }
      end
    end

    context "any model after not calling xss_foliate in ActiveRecord::Base" do
      should "not scrub any text fields" do
        assert fork_success? {
          ActsAsFu.build_model(:comments) do
            string :body
          end
          
          comment = Comment.new(:body => HTML_STRING)
          comment.valid?
          assert_equal "<div>omgwtfbbq</div>", comment.body
        }
      end
    end

    context "any model after calling xss_foliate in ActiveRecord::Base" do
      should "scrub all text fields" do
#        assert fork_success? {
          ActiveRecord::Base.xss_foliate

          ActsAsFu.build_model(:comments) do
            string :body
          end
          
          comment = Comment.new(:body => HTML_STRING)
          Loofah.expects(:scrub_fragment).with(HTML_STRING, :strip).once
          comment.valid?
#          assert_equal "omgwtfbbq", comment.body
#        }
      end
    end

  end
end
