require File.expand_path(File.join(File.dirname(__FILE__), 'helper'))

class TestAdHoc < Test::Unit::TestCase

  def test_empty_string_with_escape
    assert_equal "", Loofah.scrub_fragment("", :escape).to_xml
  end

  def test_empty_string_with_prune
    assert_equal Loofah.scrub_document("", :prune).text, ""
  end

  def test_xml_document_scrub
    xml = Loofah.xml_document <<-EOXML
    <root>
      <employee deceased='true'>Abraham Lincoln</employee>
      <employee deceased='false'>Abe Vigoda</employee>
    </root>
    EOXML
    bring_out_your_dead = Loofah::Scrubber.new do |node|
      if node.name == "employee" and node["deceased"] == "true"
        node.remove
        Loofah::Scrubber::STOP # don't bother with the rest of the subtree
      end
    end
    assert_equal 2, xml.css("employee").length
    
    xml.scrub!(bring_out_your_dead)

    employees = xml.css "employee"
    assert_equal 1, employees.length
    assert_equal "Abe Vigoda", employees.first.inner_text
  end

  def test_xml_fragment_scrub
    xml = Loofah.xml_fragment <<-EOXML
      <employee deceased='true'>Abraham Lincoln</employee>
      <employee deceased='false'>Abe Vigoda</employee>
    EOXML
    bring_out_your_dead = Loofah::Scrubber.new do |node|
      if node.name == "employee" and node["deceased"] == "true"
        node.remove
        Loofah::Scrubber::STOP # don't bother with the rest of the subtree
      end
    end
    assert_equal 2, xml.css("employee").length
    
    xml.scrub!(bring_out_your_dead)

    employees = xml.css "employee"
    assert_equal 1, employees.length
    assert_equal "Abe Vigoda", employees.first.inner_text
  end

  def test_html_fragment_to_s_should_not_include_head_tags
    html = Loofah.fragment "<style>foo</style><div>bar</div>"
    assert_equal "<div>bar</div>", html.to_s
  end

  def test_html_fragment_text_should_not_include_head_tags
    html = Loofah.fragment "<style>foo</style><div>bar</div>"
    assert_equal "bar", html.text
  end

  def test_html_document_text_should_not_include_head_tags
    html = Loofah.document "<style>foo</style><div>bar</div>"
    assert_equal "bar", html.text
  end

  context "Node#scrub!" do
    context "within a document" do
      should "only scrub subtree" do
        xml = Loofah.document <<-EOHTML
         <html><body>
           <div class='scrub'>
             <script>I should be removed</script>
           </div>
           <div class='noscrub'>
             <script>I should remain</script>
           </div>
         </body></html>
        EOHTML
        node = xml.at_css "div.scrub"
        node.scrub!(:prune)
        assert_contains         xml.to_s, /I should remain/
        assert_does_not_contain xml.to_s, /I should be removed/
      end
    end

    context "within a fragment" do
      should "only scrub subtree" do
        xml = Loofah.fragment <<-EOHTML
          <div class='scrub'>
            <script>I should be removed</script>
          </div>
          <div class='noscrub'>
            <script>I should remain</script>
          </div>
        EOHTML
        node = xml.at_css "div.scrub"
        node.scrub!(:prune)
        assert_contains         xml.to_s, /I should remain/
        assert_does_not_contain xml.to_s, /I should be removed/
      end
    end
  end

  context "NodeSet#scrub!" do
    context "within a document" do
      should "only scrub subtrees" do
        xml = Loofah.document <<-EOHTML
          <html><body>
            <div class='scrub'>
              <script>I should be removed</script>
            </div>
            <div class='noscrub'>
              <script>I should remain</script>
            </div>
            <div class='scrub'>
              <script>I should also be removed</script>
            </div>
          </body></html>
        EOHTML
        node_set = xml.css "div.scrub"
        assert_equal 2, node_set.length
        node_set.scrub!(:prune)
        assert_contains         xml.to_s, /I should remain/
        assert_does_not_contain xml.to_s, /I should be removed/
        assert_does_not_contain xml.to_s, /I should also be removed/
      end
    end

    context "within a fragment" do
      should "only scrub subtrees" do
        xml = Loofah.fragment <<-EOHTML
          <div class='scrub'>
            <script>I should be removed</script>
          </div>
          <div class='noscrub'>
            <script>I should remain</script>
          </div>
          <div class='scrub'>
            <script>I should also be removed</script>
          </div>
        EOHTML
        node_set = xml.css "div.scrub"
        assert_equal 2, node_set.length
        node_set.scrub!(:prune)
        assert_contains         xml.to_s, /I should remain/
        assert_does_not_contain xml.to_s, /I should be removed/
        assert_does_not_contain xml.to_s, /I should also be removed/
      end
    end
  end

  def test_removal_of_illegal_tag
    html = <<-HTML
      following this there should be no jim tag
      <jim>jim</jim>
      was there?
    HTML
    sane = Nokogiri::HTML(Loofah.scrub_fragment(html, :escape).to_xml)
    assert sane.xpath("//jim").empty?
  end

  def test_removal_of_illegal_attribute
    html = "<p class=bar foo=bar abbr=bar />"
    sane = Nokogiri::HTML(Loofah.scrub_fragment(html, :escape).to_xml)
    node = sane.xpath("//p").first
    assert node.attributes['class']
    assert node.attributes['abbr']
    assert_nil node.attributes['foo']
  end

  def test_removal_of_illegal_url_in_href
    html = <<-HTML
      <a href='jimbo://jim.jim/'>this link should have its href removed because of illegal url</a>
      <a href='http://jim.jim/'>this link should be fine</a>
    HTML
    sane = Nokogiri::HTML(Loofah.scrub_fragment(html, :escape).to_xml)
    nodes = sane.xpath("//a")
    assert_nil nodes.first.attributes['href']
    assert nodes.last.attributes['href']
  end

  def test_css_sanitization
    html = "<p style='background-color: url(\"http://foo.com/\") ; background-color: #000 ;' />"
    sane = Nokogiri::HTML(Loofah.scrub_fragment(html, :escape).to_xml)
    assert_match(/#000/, sane.inner_html)
    assert_no_match(/foo\.com/, sane.inner_html)
  end

  def test_fragment_with_no_tags
    assert_equal "This fragment has no tags.", Loofah.scrub_fragment("This fragment has no tags.", :escape).to_xml
  end

  def test_fragment_in_p_tag
    assert_equal "<p>This fragment is in a p.</p>", Loofah.scrub_fragment("<p>This fragment is in a p.</p>", :escape).to_xml
  end

  def test_fragment_in_p_tag_plus_stuff
    assert_equal "<p>This fragment is in a p.</p>foo<strong>bar</strong>", Loofah.scrub_fragment("<p>This fragment is in a p.</p>foo<strong>bar</strong>", :escape).to_xml
  end

  def test_fragment_with_text_nodes_leading_and_trailing
    assert_equal "text<p>fragment</p>text", Loofah.scrub_fragment("text<p>fragment</p>text", :escape).to_xml
  end

  def test_whitewash_on_fragment
    html = "safe<frameset rows=\"*\"><frame src=\"http://example.com\"></frameset> <b>description</b>"
    whitewashed = Loofah.scrub_document(html, :whitewash).xpath("/html/body/*").to_s
    assert_equal "<p>safe</p><b>description</b>", whitewashed.gsub("\n","")
  end

  MSWORD_HTML = <<-EOHTML
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"><meta name="ProgId" content="Word.Document"><meta name="Generator" content="Microsoft Word 11"><meta name="Originator" content="Microsoft Word 11"><link rel="File-List" href="file:///C:%5CDOCUME%7E1%5CNICOLE%7E1%5CLOCALS%7E1%5CTemp%5Cmsohtml1%5C01%5Cclip_filelist.xml"><!--[if gte mso 9]><xml>
<w:WordDocument>
 <w:View>Normal</w:View>
 <w:Zoom>0</w:Zoom>
 <w:PunctuationKerning/>
 <w:ValidateAgainstSchemas/>
 <w:SaveIfXMLInvalid>false</w:SaveIfXMLInvalid>
 <w:IgnoreMixedContent>false</w:IgnoreMixedContent>
 <w:AlwaysShowPlaceholderText>false</w:AlwaysShowPlaceholderText>
 <w:Compatibility>
  <w:BreakWrappedTables/>
  <w:SnapToGridInCell/>
  <w:WrapTextWithPunct/>
  <w:UseAsianBreakRules/>
  <w:DontGrowAutofit/>
 </w:Compatibility>
 <w:BrowserLevel>MicrosoftInternetExplorer4</w:BrowserLevel>
</w:WordDocument>
</xml><![endif]--><!--[if gte mso 9]><xml>
<w:LatentStyles DefLockedState="false" LatentStyleCount="156">
</w:LatentStyles>
</xml><![endif]--><style>
<!--
/* Style Definitions */
p.MsoNormal, li.MsoNormal, div.MsoNormal
{mso-style-parent:"";
margin:0in;
margin-bottom:.0001pt;
mso-pagination:widow-orphan;
font-size:12.0pt;
font-family:"Times New Roman";
mso-fareast-font-family:"Times New Roman";}
@page Section1
{size:8.5in 11.0in;
margin:1.0in 1.25in 1.0in 1.25in;
mso-header-margin:.5in;
mso-footer-margin:.5in;
mso-paper-source:0;}
div.Section1
{page:Section1;}
-->
</style><!--[if gte mso 10]>
<style>
/* Style Definitions */
table.MsoNormalTable
{mso-style-name:"Table Normal";
mso-tstyle-rowband-size:0;
mso-tstyle-colband-size:0;
mso-style-noshow:yes;
mso-style-parent:"";
mso-padding-alt:0in 5.4pt 0in 5.4pt;
mso-para-margin:0in;
mso-para-margin-bottom:.0001pt;
mso-pagination:widow-orphan;
font-size:10.0pt;
font-family:"Times New Roman";
mso-ansi-language:#0400;
mso-fareast-language:#0400;
mso-bidi-language:#0400;}
</style>
<![endif]-->

<p class="MsoNormal">Foo <b style="">BOLD<o:p></o:p></b></p>
  EOHTML

  def test_fragment_whitewash_on_microsofty_markup
    whitewashed = Loofah.fragment(MSWORD_HTML).scrub!(:whitewash)
    assert_equal "<p>Foo <b>BOLD</b></p>", whitewashed.to_s
  end

  def test_document_whitewash_on_microsofty_markup
    whitewashed = Loofah.document(MSWORD_HTML).scrub!(:whitewash)
    assert_contains whitewashed.to_s, %r(<p>Foo <b>BOLD</b></p>)
    assert_equal "<p>Foo <b>BOLD</b></p>", whitewashed.xpath("/html/body/*").to_s
  end

  def test_return_empty_string_when_nothing_left
    assert_equal "", Loofah.scrub_document('<script>test</script>', :prune).text
  end

  def test_removal_of_all_tags
    html = <<-HTML
      What's up <strong>doc</strong>?
    HTML
    stripped = Loofah.scrub_document(html, :prune).text
    assert_equal %Q(What\'s up doc?).strip, stripped.strip
  end

  def test_dont_remove_whitespace
    html = "Foo\nBar"
    assert_equal html, Loofah.scrub_document(html, :prune).text
  end

  def test_dont_remove_whitespace_between_tags
    html = "<p>Foo</p>\n<p>Bar</p>"
    assert_equal "Foo\nBar", Loofah.scrub_document(html, :prune).text
  end

  def test_removal_of_entities
    html = "<p>this is &lt; that &quot;&amp;&quot; the other &gt; boo&apos;ya</p>"
    assert_equal 'this is < that "&" the other > boo\'ya', Loofah.scrub_document(html, :prune).text
  end
end
