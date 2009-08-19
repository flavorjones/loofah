require "#{File.dirname(__FILE__)}/test_helper"

class TestFoo < Test::Unit::TestCase
  
  HTML_TEXT = "<div>omgwtfbbq</div>"
  SANITIZED_TEXT = "omgwtfbbq"

  def test_sanitization
    assert ActiveRecord::Base.xss_foliated?, "AR::Base is not xss_foliated"
    assert Post.xss_foliated?, "Post is not xss_foliated"
    post = Post.new
    post.body = HTML_TEXT
    assert_equal HTML_TEXT, post.body, "setup failed"
    post.valid?
    assert_equal SANITIZED_TEXT, post.body, "sanitization failed"
  end

end

