# frozen_string_literal: true

#
#  these tests taken from the HTML5 sanitization project and modified for use with Loofah
#  see the original here: http://code.google.com/p/html5lib/source/browse/ruby/test/test_sanitizer.rb
#
#  license text at the bottom of this file
#
require "helper"

class Html5TestSanitizer < Loofah::TestCase
  include Loofah

  def sanitize_html4(stream)
    Loofah.html4_fragment(stream).scrub!(:escape).to_html
  end

  def sanitize_html5(stream)
    Loofah.html5_fragment(stream).scrub!(:escape).to_html
  end

  # shotgun approach - if any of the possible answers match, we win
  def check_sanitization(input, *possible_answers)
    # libxml uses double-quotes, so let's swappo-boppo our quotes before comparing.
    sane = sanitize_html4(input).tr('"', "'")
    possible_output = possible_answers.compact.map do |possible_answer|
      possible_answer.tr('"', "'")
    end

    assert_includes(possible_output, sane, caller(1..1).first)

    if Loofah.html5_support?
      # now do libgumbo
      sane = sanitize_html5(input).tr('"', "'")
      possible_output = possible_answers.compact.map do |possible_answer|
        possible_answer.tr('"', "'")
      end

      assert_includes(possible_output, sane, caller(1..1).first)
    end
  end

  def assert_completes_in_reasonable_time(&block)
    t0 = Time.now
    yield

    assert_in_delta(t0, Time.now, 0.1) # arbitrary seconds
  end

  ALLOWED_ELEMENTS_PARENT = {
    "caption" => "table",
    "col" => "table",
    "colgroup" => "table",
    "li" => "ul",
    "tbody" => "table",
    "td" => "table",
    "tfoot" => "table",
    "th" => "table",
    "thead" => "table",
    "tr" => "table",
  }
  HTML5::SafeList::ALLOWED_ELEMENTS.each do |tag_name|
    define_method "test_should_allow_#{tag_name}_tag" do
      parent = ALLOWED_ELEMENTS_PARENT[tag_name]
      if parent
        input = "<#{parent}><#{tag_name} title='1'>foo</#{tag_name}></#{parent}>"
        naive_output = "<#{parent}><#{tag_name.downcase} title='1'>foo</#{tag_name.downcase}></#{parent}>"
      else
        input = "<#{tag_name} title='1'>foo</#{tag_name}>"
        naive_output = "<#{tag_name.downcase} title='1'>foo</#{tag_name.downcase}>"
      end

      outputs = []

      # libgumbo
      case tag_name
      when "col"
        outputs << "foo<table><colgroup><col title='1'></colgroup></table>" # libgumbo
      when "table"
        outputs << "foo<table title='1'></table>" # libgumbo
      when "tr"
        outputs << "foo<table><tbody><tr title='1'></tr></tbody></table>" # libgumbo
      when "th", "td"
        outputs << "<table><tbody><tr><#{tag_name} title='1'>foo</#{tag_name}></tr></tbody></table>" # libgumbo
      when "colgroup", "tbody", "tfoot", "thead"
        outputs << "foo<table><#{tag_name} title='1'></#{tag_name}></table>" # libgumbo
      when "br"
        outputs << "<br title='1'>foo<br>"
      end

      # libxml
      case tag_name
      when "col"
        outputs << "<table>\n<col title='1'>foo</table>" # libxml
      end

      # nekohtml
      case tag_name
      when "col"
        outputs << "<table><colgroup><col title='1'>foo</colgroup></table>"
      when "table"
        outputs << "<table title='1'>foo</table>"
      when "tr"
        outputs << "<table><tbody><tr title='1'>foo</tr></tbody></table>"
      when "th", "td"
        outputs << "<table><tbody><tr><#{tag_name} title='1'>foo</#{tag_name}></tr></tbody></table>"
      when "colgroup", "tbody", "tfoot", "thead"
        outputs << "<table><#{tag_name} title='1'>foo</#{tag_name}></table>"
      when "br"
        outputs << "<br title='1'>foo<br>"
      end

      # common
      if outputs.length < 3
        if HTML5::SafeList::VOID_ELEMENTS.include?(tag_name) || tag_name == "wbr"
          outputs << "<#{tag_name} title='1'>foo"
        end
        unless HTML5::SafeList::VOID_ELEMENTS.include?(tag_name)
          outputs << naive_output
        end
      end

      check_sanitization(input, *outputs)
    end
  end

  HTML5::SafeList::VOID_ELEMENTS.each do |tag_name|
    define_method "test_void_#{tag_name}_is_in_allowed_list" do
      assert_includes(HTML5::SafeList::ALLOWED_ELEMENTS, tag_name)
    end
  end

  ##
  ##  libxml2 downcases elements, so this is moot.
  ##
  # HTML5::SafeList::ALLOWED_ELEMENTS.each do |tag_name|
  #   define_method "test_should_forbid_#{tag_name.upcase}_tag" do
  #     input = "<#{tag_name.upcase} title='1'>foo <bad>bar</bad> baz</#{tag_name.upcase}>"
  #     output = "&lt;#{tag_name.upcase} title=\"1\"&gt;foo &lt;bad&gt;bar&lt;/bad&gt; baz&lt;/#{tag_name.upcase}&gt;"
  #     check_sanitization(input, output)
  #   end
  # end

  HTML5::SafeList::ALLOWED_ATTRIBUTES.each do |attribute_name|
    next if attribute_name == "style"

    define_method "test_should_allow_#{attribute_name}_attribute" do
      input = "<p #{attribute_name}='foo'>foo <bad>bar</bad> baz</p>"
      if [
        "checked",
        "compact",
        "disabled",
        "ismap",
        "multiple",
        "nohref",
        "noshade",
        "nowrap",
        "readonly",
        "selected",
      ].include?(attribute_name)
        htmloutput = "<p #{attribute_name.downcase}>foo &lt;bad&gt;bar&lt;/bad&gt; baz</p>"
        html5output = "<p #{attribute_name.downcase}='foo'>foo &lt;bad&gt;bar&lt;/bad&gt; baz</p>"
      else
        htmloutput = "<p #{attribute_name.downcase}='foo'>foo &lt;bad&gt;bar&lt;/bad&gt; baz</p>"
        html5output = nil
      end
      check_sanitization(input, htmloutput, html5output)
    end
  end

  def test_should_allow_data_attributes
    input = "<p data-foo='foo'>foo <bad>bar</bad> baz</p>"
    output = "<p data-foo='foo'>foo &lt;bad&gt;bar&lt;/bad&gt; baz</p>"

    check_sanitization(input, output)
  end

  def test_should_allow_multi_word_data_attributes
    input = "<p data-foo-bar-id='11'>foo <bad>bar</bad> baz</p>"
    output = "<p data-foo-bar-id='11'>foo &lt;bad&gt;bar&lt;/bad&gt; baz</p>"

    check_sanitization(input, output)
  end

  def test_should_allow_empty_data_attributes
    input = '<p data-foo data-bar="">foo <bad>bar</bad> baz</p>'

    check_sanitization(
      input,
      "<p data-foo data-bar=''>foo &lt;bad&gt;bar&lt;/bad&gt; baz</p>",
      "<p data-foo='' data-bar=''>foo &lt;bad&gt;bar&lt;/bad&gt; baz</p>",
      "<p data-bar='' data-foo=''>foo &lt;bad&gt;bar&lt;/bad&gt; baz</p>", # nekohtml
    )
  end

  def test_should_allow_contenteditable
    input = '<p contenteditable="false">Hi!</p>'
    output = '<p contenteditable="false">Hi!</p>'

    check_sanitization(input, output)
  end

  def test_boolean_attributes
    input = "<video controls download></video>"
    expected_html5 = "<video controls=''></video>"
    output_html5 = sanitize_html5(input).tr('"', "'")

    assert_equal(expected_html5, output_html5)
  end

  ##
  ##  libxml2 downcases attributes, so this is moot.
  ##
  # HTML5::SafeList::ALLOWED_ATTRIBUTES.each do |attribute_name|
  #   define_method "test_should_forbid_#{attribute_name.upcase}_attribute" do
  #     input = "<p #{attribute_name.upcase}='display: none;'>foo <bad>bar</bad> baz</p>"
  #     output =  "<p>foo &lt;bad&gt;bar&lt;/bad&gt; baz</p>"
  #     check_sanitization(input, output)
  #   end
  # end

  HTML5::SafeList::ALLOWED_PROTOCOLS.each do |protocol|
    define_method "test_should_allow_#{protocol}_uris" do
      input = %(<a href="#{protocol}">foo</a>)
      output = "<a href='#{protocol}'>foo</a>"
      check_sanitization(input, output)
    end
  end

  HTML5::SafeList::ALLOWED_PROTOCOLS.each do |protocol|
    define_method "test_should_allow_uppercase_#{protocol}_uris" do
      input = %(<a href="#{protocol.upcase}">foo</a>)
      output = "<a href='#{protocol.upcase}'>foo</a>"
      check_sanitization(input, output)
    end
  end

  ["image/gif", "image/jpeg", "image/png", "text/css", "text/plain"].each do |data_uri_type|
    define_method "test_should_allow_data_#{data_uri_type}_uris" do
      input = %(<a href="data:#{data_uri_type}">foo</a>)
      output = "<a href='data:#{data_uri_type}'>foo</a>"
      check_sanitization(input, output)

      input = %(<a href="data:#{data_uri_type};base64,R0lGODlhAQABA">foo</a>)
      output = "<a href='data:#{data_uri_type};base64,R0lGODlhAQABA'>foo</a>"
      check_sanitization(input, output)
    end

    define_method "test_should_allow_uppercase_data_#{data_uri_type}_uris" do
      input = %(<a href="DATA:#{data_uri_type.upcase}">foo</a>)
      output = "<a href='DATA:#{data_uri_type.upcase}'>foo</a>"
      check_sanitization(input, output)
    end
  end

  def test_should_disallow_other_uri_mediatypes
    input = %(<a href="data:foo">foo</a>)
    output = "<a>foo</a>"
    check_sanitization(input, output)

    input = %(<a href="data:image/xxx">foo</a>)
    output = "<a>foo</a>"
    check_sanitization(input, output)

    input = %(<a href="data:image/xxx;base64,R0lGODlhAQABA">foo</a>)
    output = "<a>foo</a>"

    check_sanitization(input, output)

    input = %(<a href="data:text/html;base64,R0lGODlhAQABA">foo</a>)
    output = "<a>foo</a>"
    check_sanitization(input, output)

    # https://hackerone.com/bugs?report_id=1694173
    # https://github.com/w3c/svgwg/issues/266
    input = %(<svg><use href="data:image/svg+xml;base64,PHN2ZyBpZD0neCcgeG1s"/></svg>)
    output = "<svg><use></use></svg>"

    check_sanitization(input, output)
  end

  HTML5::SafeList::SVG_ALLOW_LOCAL_HREF.each do |tag_name|
    next unless HTML5::SafeList::ALLOWED_ELEMENTS.include?(tag_name)

    tag_name_dc = tag_name.downcase

    define_method "test_#{tag_name}_should_allow_local_href" do
      input = %(<#{tag_name} xlink:href="#foo"/>)
      output = "<#{tag_name_dc} xlink:href='#foo'></#{tag_name_dc}>"
      xhtmloutput = "<#{tag_name} xlink:href='#foo'></#{tag_name}>"
      check_sanitization(input, output, xhtmloutput, xhtmloutput)
    end

    define_method "test_#{tag_name}_should_allow_local_href_with_newline" do
      input = %(<#{tag_name} xlink:href="\n#foo"/>)

      check_sanitization(
        input,
        "<#{tag_name_dc} xlink:href='\n#foo'></#{tag_name_dc}>",
        "<#{tag_name_dc} xlink:href='&#10;#foo'></#{tag_name_dc}>", # nekohtml
      )
    end

    define_method "test_#{tag_name}_should_forbid_nonlocal_href" do
      input = %(<#{tag_name} xlink:href="http://bad.com/foo"/>)
      output = "<#{tag_name_dc}></#{tag_name_dc}>"
      xhtmloutput = "<#{tag_name}></#{tag_name}>"
      check_sanitization(input, output, xhtmloutput, xhtmloutput)
    end

    define_method "test_#{tag_name}_should_forbid_nonlocal_href_with_newline" do
      input = %(<#{tag_name} xlink:href="\nhttp://bad.com/foo"/>)
      output = "<#{tag_name_dc}></#{tag_name_dc}>"
      xhtmloutput = "<#{tag_name}></#{tag_name}>"
      check_sanitization(input, output, xhtmloutput, xhtmloutput)
    end
  end

  def test_figure_element_is_valid
    fragment = Loofah.scrub_html4_fragment("<span>hello</span> <figure>asd</figure>", :prune)

    assert(fragment.at_css("figure"), "<figure> tag was scrubbed")
  end

  ##
  ##  as tenderlove says, "care < 0"
  ##
  # def test_should_handle_astral_plane_characters
  #   input = "<p>&#x1d4b5; &#x1d538;</p>"
  #   output = "<p>\360\235\222\265 \360\235\224\270</p>"
  #   check_sanitization(input, output)

  #   input = "<p><tspan>\360\235\224\270</tspan> a</p>"
  #   output = "<p><tspan>\360\235\224\270</tspan> a</p>"
  #   check_sanitization(input, output)
  # end

  # This affects only NS4. Is it worth fixing?
  #  def test_javascript_includes
  #    input = %(<div size="&{alert('XSS')}">foo</div>)
  #    output = "<div>foo</div>"
  #    check_sanitization(input, output)
  #  end

  ##
  ##  these tests primarily test the parser logic, not the sanitizer
  ##  logic. i call bullshit. we're not writing a test suite for
  ##  libxml2 here, so let's rely on the unit tests above to take care
  ##  of our valid elements and attributes.
  ##
  require "json"
  Dir[File.join(File.dirname(__FILE__), "..", "assets", "testdata_sanitizer_tests1.dat")].each do |filename|
    JSON.parse(File.read(filename)).each do |test|
      it "testdata sanitizer #{test["name"]}" do
        test.delete("name")
        input = test.delete("input")
        outputs = test.keys.sort.map { |k| test[k] }
        check_sanitization(input, *outputs)
      end
    end
  end

  ## added because we don't have any coverage above on SVG_ATTR_VAL_ALLOWS_REF
  HTML5::SafeList::SVG_ATTR_VAL_ALLOWS_REF.each do |attr_name|
    define_method "test_allow_uri_refs_in_svg_attribute_#{attr_name}" do
      input = "<rect #{attr_name}='url(#foo)' />"
      output = "<rect #{attr_name}='url(#foo)'></rect>"
      check_sanitization(input, output)
    end

    define_method "test_disallow_absolute_uri_refs_in_svg_attribute_#{attr_name}" do
      input = "<rect #{attr_name}='yellow url(http://bad.com/) #fff \"blue\"' />"
      check_sanitization(
        input,
        "<rect #{attr_name}='yellow #fff \"blue\"'></rect>", # libxml
        "<rect #{attr_name}='yellow #fff &quot;blue&quot;'></rect>", # libgumbo
        "<rect #{attr_name}='yellow #fff %22blue%22'></rect>", # nekohtml
      )
    end
  end

  def test_css_list_style
    html = '<ul style="list-style: none"></ul>'
    sane = Nokogiri::HTML(Loofah.scrub_html4_fragment(html, :escape).to_xml)

    assert_match(/list-style/, sane.inner_html)
  end

  def test_css_negative_value_sanitization
    html = "<span style=\"letter-spacing:-0.03em;\">"
    sane = Nokogiri::HTML(Loofah.scrub_html4_fragment(html, :escape).to_xml)

    assert_match(/-0.03em/, sane.inner_html)
  end

  def test_css_negative_value_sanitization_shorthand_css_properties
    html = "<span style=\"margin-left:-0.05em;\">"
    sane = Nokogiri::HTML(Loofah.scrub_html4_fragment(html, :escape).to_xml)

    assert_match(/-0.05em/, sane.inner_html)
  end

  def test_css_high_precision_value_shorthand_css_properties
    html = "<span style=\"margin-left:0.3333333334em;\">"
    sane = Nokogiri::HTML(Loofah.scrub_html4_fragment(html, :escape).to_xml)

    assert_match(/0.3333333334em/, sane.inner_html)
  end

  def test_css_rem_value
    html = "<span style=\"margin-top:10rem;\">"
    sane = Nokogiri::HTML(Loofah.scrub_html4_fragment(html, :escape).to_xml)

    assert_match(/10rem/, sane.inner_html)
  end

  def test_css_ch_value
    html = "<div style=\"width:60ch;\">"
    sane = Nokogiri::HTML(Loofah.scrub_html4_fragment(html, :escape).to_xml)

    assert_match(/60ch/, sane.inner_html)
  end

  def test_css_vw_value
    html = "<div style=\"font-size: calc(16px + 1vw);\"></body>"
    sane = Nokogiri::HTML(Loofah.scrub_html4_fragment(html, :escape).to_xml)

    assert_match(/1vw/, sane.inner_html)
  end

  def test_css_vh_value
    html = "<div style=\"height: 100vh;\"></body>"
    sane = Nokogiri::HTML(Loofah.scrub_html4_fragment(html, :escape).to_xml)

    assert_match(/100vh/, sane.inner_html)
  end

  def test_css_q_value
    html = "<div style=\"height: 10Q;\"></body>"
    sane = Nokogiri::HTML(Loofah.scrub_html4_fragment(html, :escape).to_xml)

    assert_match(/10Q/, sane.inner_html)
  end

  def test_css_lh_value
    html = "<p style=\"line-height: 2lh;\"></body>"
    sane = Nokogiri::HTML(Loofah.scrub_html4_fragment(html, :escape).to_xml)

    assert_match(/2lh/, sane.inner_html)
  end

  def test_css_vmin_value
    html = "<div style=\"width: 42vmin;\"></body>"
    sane = Nokogiri::HTML(Loofah.scrub_html4_fragment(html, :escape).to_xml)

    assert_match(/42vmin/, sane.inner_html)
  end

  def test_css_vmax_value
    html = "<div style=\"width: 42vmax;\"></body>"
    sane = Nokogiri::HTML(Loofah.scrub_html4_fragment(html, :escape).to_xml)

    assert_match(/42vmax/, sane.inner_html)
  end

  def test_css_function_sanitization_leaves_safelisted_functions_calc
    html = "<span style=\"width:calc(5%)\">"
    sane = Nokogiri::HTML(Loofah.scrub_html4_fragment(html, :strip).to_html)

    assert_match(/calc\(5%\)/, sane.inner_html)

    html = "<span style=\"width: calc(5%)\">"
    sane = Nokogiri::HTML(Loofah.scrub_html4_fragment(html, :strip).to_html)

    assert_match(/calc\(5%\)/, sane.inner_html)
  end

  def test_css_function_sanitization_leaves_safelisted_functions_rgb
    html = '<span style="color: rgb(255, 0, 0)">'
    sane = Nokogiri::HTML(Loofah.scrub_html4_fragment(html, :strip).to_html)

    assert_match(/rgb\(255, 0, 0\)/, sane.inner_html)
  end

  def test_css_function_sanitization_leaves_safelisted_list_style_type
    html = "<ol style='list-style-type:lower-greek;'></ol>"
    sane = Nokogiri::HTML(Loofah.scrub_html4_fragment(html, :strip).to_html)

    assert_match(/list-style-type:lower-greek/, sane.inner_html)
  end

  def test_css_function_sanitization_strips_style_attributes_with_unsafe_functions
    html = "<span style=\"width:url(data-evil-url)\">"
    sane = Nokogiri::HTML(Loofah.scrub_html4_fragment(html, :strip).to_html)

    assert_match(%r/<span><\/span>/, sane.inner_html)

    html = "<span style=\"width: url(data-evil-url)\">"
    sane = Nokogiri::HTML(Loofah.scrub_html4_fragment(html, :strip).to_html)

    assert_match(%r/<span><\/span>/, sane.inner_html)
  end

  def test_css_max_width
    html = '<div style="max-width: 100%;"></div>'
    sane = Nokogiri::HTML(Loofah.scrub_html4_fragment(html, :escape).to_xml)

    assert_match(/max-width/, sane.inner_html)
  end

  def test_css_page_break_after
    html = '<div style="page-break-after:always;"></div>'
    sane = Nokogiri::HTML(Loofah.scrub_html4_fragment(html, :escape).to_xml)

    assert_match(/page-break-after:always/, sane.inner_html)
  end

  def test_css_page_break_before
    html = '<div style="page-break-before:always;"></div>'
    sane = Nokogiri::HTML(Loofah.scrub_html4_fragment(html, :escape).to_xml)

    assert_match(/page-break-before:always/, sane.inner_html)
  end

  def test_css_page_break_inside
    html = '<div style="page-break-inside:auto;"></div>'
    sane = Nokogiri::HTML(Loofah.scrub_html4_fragment(html, :escape).to_xml)

    assert_match(/page-break-inside:auto/, sane.inner_html)
  end

  def test_css_align_content
    html = '<div style="align-content:flex-start;"></div>'
    sane = Nokogiri::HTML(Loofah.scrub_html4_fragment(html, :escape).to_xml)

    assert_match(/align-content:flex-start/, sane.inner_html)
  end

  def test_css_align_items
    html = '<div style="align-items:stretch;"></div>'
    sane = Nokogiri::HTML(Loofah.scrub_html4_fragment(html, :escape).to_xml)

    assert_match(/align-items:stretch/, sane.inner_html)
  end

  def test_css_align_self
    html = '<div style="align-self:auto;"></div>'
    sane = Nokogiri::HTML(Loofah.scrub_html4_fragment(html, :escape).to_xml)

    assert_match(/align-self:auto/, sane.inner_html)
  end

  def test_css_flex
    html = '<div style="flex:none;"></div>'
    sane = Nokogiri::HTML(Loofah.scrub_html4_fragment(html, :escape).to_xml)

    assert_match(/flex:none/, sane.inner_html)
  end

  def test_css_flex_basis
    html = '<div style="flex-basis:auto;"></div>'
    sane = Nokogiri::HTML(Loofah.scrub_html4_fragment(html, :escape).to_xml)

    assert_match(/flex-basis:auto/, sane.inner_html)
  end

  def test_css_flex_direction
    html = '<div style="flex-direction:row;"></div>'
    sane = Nokogiri::HTML(Loofah.scrub_html4_fragment(html, :escape).to_xml)

    assert_match(/flex-direction:row/, sane.inner_html)
  end

  def test_css_flex_flow
    html = '<div style="flex-flow:column wrap;"></div>'
    sane = Nokogiri::HTML(Loofah.scrub_html4_fragment(html, :escape).to_xml)

    assert_match(/flex-flow:column wrap/, sane.inner_html)
  end

  def test_css_flex_grow
    html = '<div style="flex-grow:4;"></div>'
    sane = Nokogiri::HTML(Loofah.scrub_html4_fragment(html, :escape).to_xml)

    assert_match(/flex-grow:4/, sane.inner_html)
  end

  def test_css_flex_shrink
    html = '<div style="flex-shrink:3;"></div>'
    sane = Nokogiri::HTML(Loofah.scrub_html4_fragment(html, :escape).to_xml)

    assert_match(/flex-shrink:3/, sane.inner_html)
  end

  def test_css_flex_wrap
    html = '<div style="flex-wrap:wrap;"></div>'
    sane = Nokogiri::HTML(Loofah.scrub_html4_fragment(html, :escape).to_xml)

    assert_match(/flex-wrap:wrap/, sane.inner_html)
  end

  def test_css_justify_content
    html = '<div style="justify-content:flex-start;"></div>'
    sane = Nokogiri::HTML(Loofah.scrub_html4_fragment(html, :escape).to_xml)

    assert_match(/justify-content:flex-start/, sane.inner_html)
  end

  def test_css_order
    html = '<div style="order:5;"></div>'
    sane = Nokogiri::HTML(Loofah.scrub_html4_fragment(html, :escape).to_xml)

    assert_match(/order:5/, sane.inner_html)
  end

  def test_upper_case_css_property
    html = "<div style=\"COLOR: BLUE; NOTAPROPERTY: RED;\">asdf</div>"
    sane = Nokogiri::HTML(Loofah.scrub_html4_fragment(html, :strip).to_xml)

    assert_match(/COLOR:\s*BLUE/i, sane.at_css("div")["style"])
    refute_match(/NOTAPROPERTY/i, sane.at_css("div")["style"])
  end

  def test_many_properties_some_allowed
    html = "<div style=\"background: bold notaproperty center alsonotaproperty 10px;\">asdf</div>"
    sane = Nokogiri::HTML(Loofah.scrub_html4_fragment(html, :strip).to_xml)

    assert_match(/bold\s+center\s+10px/, sane.at_css("div")["style"])
  end

  def test_many_properties_non_allowed
    html = "<div style=\"background: notaproperty alsonotaproperty;\">asdf</div>"
    sane = Nokogiri::HTML(Loofah.scrub_html4_fragment(html, :strip).to_xml)

    assert_nil(sane.at_css("div")["style"])
  end

  def test_svg_properties
    html = "<line style='stroke-width: 10px;'></line>"
    sane = Nokogiri::HTML(Loofah.scrub_html4_fragment(html, :strip).to_xml)

    assert_match(/stroke-width:\s*10px/, sane.at_css("line")["style"])
  end
end

# <html5_license>
#
# Copyright (c) 2006-2008 The Authors
#
# Contributors:
# James Graham - jg307@cam.ac.uk
# Anne van Kesteren - annevankesteren@gmail.com
# Lachlan Hunt - lachlan.hunt@lachy.id.au
# Matt McDonald - kanashii@kanashii.ca
# Sam Ruby - rubys@intertwingly.net
# Ian Hickson (Google) - ian@hixie.ch
# Thomas Broyer - t.broyer@ltgt.net
# Jacques Distler - distler@golem.ph.utexas.edu
# Henri Sivonen - hsivonen@iki.fi
# The Mozilla Foundation (contributions from Henri Sivonen since 2008)
#
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation files
# (the "Software"), to deal in the Software without restriction,
# including without limitation the rights to use, copy, modify, merge,
# publish, distribute, sublicense, and/or sell copies of the Software,
# and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
# BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
# ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#
# </html5_license>
