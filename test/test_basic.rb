require File.expand_path(File.join(File.dirname(__FILE__), 'helper'))

if defined? Nokogiri::VERSION_INFO
  puts "=> running with Nokogiri #{Nokogiri::VERSION_INFO.inspect}"
else
  puts "=> running with Nokogiri #{Nokogiri::VERSION} / libxml #{Nokogiri::LIBXML_PARSER_VERSION}"
end

class TestBasic < Test::Unit::TestCase

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

  def test_nil
    assert_nil Dryopteris.sanitize(nil)
  end
  
  def test_empty_string
    assert_equal "", Dryopteris.sanitize("")
  end

  def test_removal_of_illegal_tag
    html = <<-HTML
      following this there should be no jim tag
      <jim>jim</jim>
      was there?
    HTML
    sane = Nokogiri::HTML(Dryopteris.sanitize(html))
    assert sane.xpath("//jim").empty?
  end
  
  def test_removal_of_illegal_attribute
    html = "<p class=bar foo=bar abbr=bar />"
    sane = Nokogiri::HTML(Dryopteris.sanitize(html))
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
    sane = Nokogiri::HTML(Dryopteris.sanitize(html))
    nodes = sane.xpath("//a")
    assert_nil nodes.first.attributes['href']
    assert nodes.last.attributes['href']
  end
  
  def test_css_sanitization
    html = "<p style='background-color: url(\"http://foo.com/\") ; background-color: #000 ;' />"
    sane = Nokogiri::HTML(Dryopteris.sanitize(html))
    assert_match(/#000/, sane.inner_html)
    assert_no_match(/foo\.com/, sane.inner_html)
  end

  def test_fragment_with_no_tags
    assert_equal "This fragment has no tags.", Dryopteris.sanitize("This fragment has no tags.")
  end

  def test_fragment_in_p_tag
    assert_equal "<p>This fragment is in a p.</p>", Dryopteris.sanitize("<p>This fragment is in a p.</p>")
  end

  def test_fragment_in_a_nontrivial_p_tag
    assert_equal "  \n<p>This fragment is in a p.</p>", Dryopteris.sanitize("  \n<p foo='bar'>This fragment is in a p.</p>")
  end

  def test_fragment_in_p_tag_plus_stuff
    assert_equal "<p>This fragment is in a p.</p>foo<strong>bar</strong>", Dryopteris.sanitize("<p>This fragment is in a p.</p>foo<strong>bar</strong>")
  end

  def test_fragment_with_text_nodes_leading_and_trailing
    assert_equal "text<p>fragment</p>text", Dryopteris.sanitize("text<p>fragment</p>text")
  end
  
  def test_whitewash_on_fragment
    html = "safe<frameset rows=\"*\"><frame src=\"http://example.com\"></frameset> <b>description</b>"
    whitewashed = Dryopteris.whitewash_document(html)
    assert_equal "<p>safe</p><b>description</b>", whitewashed
  end

  def test_whitewash_fragment_on_microsofty_markup
    whitewashed = Dryopteris.whitewash(MSWORD_HTML.chomp)
    assert_equal "<p>Foo <b>BOLD</b></p>", whitewashed
  end

  def test_whitewash_on_microsofty_markup
    whitewashed = Dryopteris.whitewash_document(MSWORD_HTML)
    assert_equal "<p>Foo <b>BOLD</b></p>", whitewashed
  end

end
