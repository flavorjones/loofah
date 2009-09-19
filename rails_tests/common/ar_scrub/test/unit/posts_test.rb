require File.join(File.dirname(__FILE__), "../test_helper")

class PostsTest < ActiveSupport::TestCase
  def test_loofah_scrubbing
    post = Post.new :title => "<script>yo dawg</script>", :body => "<script>omgwtfbbq</script>"
    post.save!
    assert_equal "<script>yo dawg</script>", post.title
    assert_equal "omgwtfbbq", post.body
  end
end
