require File.join(File.dirname(__FILE__), "../test_helper")

class PostsTest < Test::Unit::TestCase
  def test_loofah_scrubbing
    post = Post.new :title => "<script>yo dawg</script>", :body => "<script>omgwtfbbq</script>"
    post.valid?
    assert_equal "yo dawg", post.title
    assert_equal "omgwtfbbq", post.body
  end

  def test_xss_foliation
    assert Post.xss_foliated?
  end
end
