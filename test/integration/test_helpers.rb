require File.expand_path(File.join(File.dirname(__FILE__), '..', 'helper'))

class TestHelpers < Test::Unit::TestCase
  context "#strip_tags" do
    context "on safe markup" do
      should "strip out tags" do
        assert_equal "omgwtfbbq!!1!", Loofah::Helpers.strip_tags("<div>omgwtfbbq</div><span>!!1!</span>")
      end
    end

    context "on hack attack" do
      should "strip escape html entities" do
        bad_shit = "&lt;script&gt;alert('evil')&lt;/script&gt;"
        assert_equal bad_shit, Loofah::Helpers.strip_tags(bad_shit)
      end
    end
  end

  context "#sanitize" do
    context "on safe markup" do
      should "render the safe html" do
        html = "<div>omgwtfbbq</div><span>!!1!</span>"
        assert_equal html, Loofah::Helpers.sanitize(html)
      end
    end

    context "on hack attack" do
      should "strip the unsafe tags" do
        assert_equal "alert('evil')<span>w00t</span>", Loofah::Helpers.sanitize("<script>alert('evil')</script><span>w00t</span>")
      end
    end
  end
end
