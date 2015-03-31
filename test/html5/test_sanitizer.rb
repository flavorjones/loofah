#
#  these tests taken from the HTML5 sanitization project and modified for use with Loofah
#  see the original here: http://code.google.com/p/html5lib/source/browse/ruby/test/test_sanitizer.rb
#
#  license text at the bottom of this file
#
require "helper"

class Html5TestSanitizer < Loofah::TestCase
  include Loofah

  def sanitize_xhtml stream
    Loofah.fragment(stream).scrub!(:escape).to_xhtml
  end

  def sanitize_html stream
    Loofah.fragment(stream).scrub!(:escape).to_html
  end

  def check_sanitization(input, htmloutput, xhtmloutput, rexmloutput)
    ##  libxml uses double-quotes, so let's swappo-boppo our quotes before comparing.
    sane = sanitize_html(input).gsub('"',"'")
    htmloutput.gsub!('"',"'")
    xhtmloutput.gsub!('"',"'")
    rexmloutput.gsub!('"',"'")

    ##  HTML5's parsers are shit. there's so much inconsistency with what has closing tags, etc, that
    ##  it would require a lot of manual hacking to make the tests match libxml's output.
    ##  instead, I'm taking the shotgun approach, and trying to match any of the described outputs.
    assert((htmloutput == sane) || (rexmloutput == sane) || (xhtmloutput == sane),
      %Q{given:    "#{input}"\nexpected: "#{htmloutput}"\ngot:      "#{sane}"})
  end

  (HTML5::WhiteList::ALLOWED_ELEMENTS).each do |tag_name|
    define_method "test_should_allow_#{tag_name}_tag" do
      input       = "<#{tag_name} title='1'>foo <bad>bar</bad> baz</#{tag_name}>"
      htmloutput  = "<#{tag_name.downcase} title='1'>foo &lt;bad&gt;bar&lt;/bad&gt; baz</#{tag_name.downcase}>"
      xhtmloutput = "<#{tag_name} title='1'>foo &lt;bad&gt;bar&lt;/bad&gt; baz</#{tag_name}>"
      rexmloutput = xhtmloutput

      if %w[caption colgroup optgroup option tbody td tfoot th thead tr].include?(tag_name)
        htmloutput = "foo &lt;bad&gt;bar&lt;/bad&gt; baz"
        xhtmloutput = htmloutput
      elsif tag_name == 'col'
        htmloutput = "<col title='1'>foo &lt;bad&gt;bar&lt;/bad&gt; baz"
        xhtmloutput = htmloutput
        rexmloutput = "<col title='1' />"
      elsif tag_name == 'table'
        htmloutput = "foo &lt;bad&gt;bar&lt;/bad&gt;baz<table title='1'> </table>"
        xhtmloutput = htmloutput
      elsif tag_name == 'image'
        htmloutput = "<img title='1'/>foo &lt;bad&gt;bar&lt;/bad&gt; baz"
        xhtmloutput = htmloutput
        rexmloutput = "<image title='1'>foo &lt;bad&gt;bar&lt;/bad&gt; baz</image>"
      elsif HTML5::WhiteList::VOID_ELEMENTS.include?(tag_name)
        htmloutput = "<#{tag_name} title='1'>foo &lt;bad&gt;bar&lt;/bad&gt; baz"
        xhtmloutput = htmloutput
        htmloutput += '<br/>' if tag_name == 'br'
        rexmloutput =  "<#{tag_name} title='1' />"
      end
      check_sanitization(input, htmloutput, xhtmloutput, rexmloutput)
    end
  end

  ##
  ##  libxml2 downcases elements, so this is moot.
  ##
  # HTML5::WhiteList::ALLOWED_ELEMENTS.each do |tag_name|
  #   define_method "test_should_forbid_#{tag_name.upcase}_tag" do
  #     input = "<#{tag_name.upcase} title='1'>foo <bad>bar</bad> baz</#{tag_name.upcase}>"
  #     output = "&lt;#{tag_name.upcase} title=\"1\"&gt;foo &lt;bad&gt;bar&lt;/bad&gt; baz&lt;/#{tag_name.upcase}&gt;"
  #     check_sanitization(input, output, output, output)
  #   end
  # end

  HTML5::WhiteList::ALLOWED_ATTRIBUTES.each do |attribute_name|
    next if attribute_name == 'style'
    define_method "test_should_allow_#{attribute_name}_attribute" do
        input = "<p #{attribute_name}='foo'>foo <bad>bar</bad> baz</p>"
      if %w[checked compact disabled ismap multiple nohref noshade nowrap readonly selected].include?(attribute_name)
        output = "<p #{attribute_name}>foo &lt;bad&gt;bar&lt;/bad&gt; baz</p>"
        htmloutput = "<p #{attribute_name.downcase}>foo &lt;bad&gt;bar&lt;/bad&gt; baz</p>"
      else
        output = "<p #{attribute_name}='foo'>foo &lt;bad&gt;bar&lt;/bad&gt; baz</p>"
        htmloutput = "<p #{attribute_name.downcase}='foo'>foo &lt;bad&gt;bar&lt;/bad&gt; baz</p>"
      end
      check_sanitization(input, htmloutput, output, output)
    end
  end

  def test_should_allow_data_attributes
    input = "<p data-foo='foo'>foo <bad>bar</bad> baz</p>"

    output = "<p data-foo='foo'>foo &lt;bad&gt;bar&lt;/bad&gt; baz</p>"
    htmloutput = "<p data-foo='foo'>foo &lt;bad&gt;bar&lt;/bad&gt; baz</p>"

    check_sanitization(input, htmloutput, output, output)
  end

  def test_should_allow_multi_word_data_attributes
    input = "<p data-foo-bar-id='11'>foo <bad>bar</bad> baz</p>"
    output = htmloutput = "<p data-foo-bar-id='11'>foo &lt;bad&gt;bar&lt;/bad&gt; baz</p>"

    check_sanitization(input, htmloutput, output, output)
  end

  ##
  ##  libxml2 downcases attributes, so this is moot.
  ##
  # HTML5::WhiteList::ALLOWED_ATTRIBUTES.each do |attribute_name|
  #   define_method "test_should_forbid_#{attribute_name.upcase}_attribute" do
  #     input = "<p #{attribute_name.upcase}='display: none;'>foo <bad>bar</bad> baz</p>"
  #     output =  "<p>foo &lt;bad&gt;bar&lt;/bad&gt; baz</p>"
  #     check_sanitization(input, output, output, output)
  #   end
  # end

  HTML5::WhiteList::ALLOWED_PROTOCOLS.each do |protocol|
    define_method "test_should_allow_#{protocol}_uris" do
      input = %(<a href="#{protocol}">foo</a>)
      output = "<a href='#{protocol}'>foo</a>"
      check_sanitization(input, output, output, output)
    end
  end

  HTML5::WhiteList::ALLOWED_PROTOCOLS.each do |protocol|
    define_method "test_should_allow_uppercase_#{protocol}_uris" do
      input = %(<a href="#{protocol.upcase}">foo</a>)
      output = "<a href='#{protocol.upcase}'>foo</a>"
      check_sanitization(input, output, output, output)
    end
  end

  HTML5::WhiteList::SVG_ALLOW_LOCAL_HREF.each do |tag_name|
    next unless HTML5::WhiteList::ALLOWED_ELEMENTS.include?(tag_name)
    define_method "test_#{tag_name}_should_allow_local_href" do
      input = %(<#{tag_name} xlink:href="#foo"/>)
      output = "<#{tag_name.downcase} xlink:href='#foo'></#{tag_name.downcase}>"
      xhtmloutput = "<#{tag_name} xlink:href='#foo'></#{tag_name}>"
      check_sanitization(input, output, xhtmloutput, xhtmloutput)
    end

    define_method "test_#{tag_name}_should_allow_local_href_with_newline" do
      input = %(<#{tag_name} xlink:href="\n#foo"/>)
      output = "<#{tag_name.downcase} xlink:href='\n#foo'></#{tag_name.downcase}>"
      xhtmloutput = "<#{tag_name} xlink:href='\n#foo'></#{tag_name}>"
      check_sanitization(input, output, xhtmloutput, xhtmloutput)
    end

    define_method "test_#{tag_name}_should_forbid_nonlocal_href" do
      input = %(<#{tag_name} xlink:href="http://bad.com/foo"/>)
      output = "<#{tag_name.downcase}></#{tag_name.downcase}>"
      xhtmloutput = "<#{tag_name}></#{tag_name}>"
      check_sanitization(input, output, xhtmloutput, xhtmloutput)
    end

    define_method "test_#{tag_name}_should_forbid_nonlocal_href_with_newline" do
      input = %(<#{tag_name} xlink:href="\nhttp://bad.com/foo"/>)
      output = "<#{tag_name.downcase}></#{tag_name.downcase}>"
      xhtmloutput = "<#{tag_name}></#{tag_name}>"
      check_sanitization(input, output, xhtmloutput, xhtmloutput)
    end
  end

  def test_figure_element_is_valid
    fragment = Loofah.scrub_fragment("<span>hello</span> <figure>asd</figure>", :prune)
    assert fragment.at_css("figure"), "<figure> tag was scrubbed"
  end

  ##
  ##  as tenderlove says, "care < 0"
  ##
  # def test_should_handle_astral_plane_characters
  #   input = "<p>&#x1d4b5; &#x1d538;</p>"
  #   output = "<p>\360\235\222\265 \360\235\224\270</p>"
  #   check_sanitization(input, output, output, output)

  #   input = "<p><tspan>\360\235\224\270</tspan> a</p>"
  #   output = "<p><tspan>\360\235\224\270</tspan> a</p>"
  #   check_sanitization(input, output, output, output)
  # end

# This affects only NS4. Is it worth fixing?
#  def test_javascript_includes
#    input = %(<div size="&{alert('XSS')}">foo</div>)
#    output = "<div>foo</div>"
#    check_sanitization(input, output, output, output)
#  end

  ##
  ##  these tests primarily test the parser logic, not the sanitizer
  ##  logic. i call bullshit. we're not writing a test suite for
  ##  libxml2 here, so let's rely on the unit tests above to take care
  ##  of our valid elements and attributes.
  ##
  require 'json'
  Dir[File.join(File.dirname(__FILE__), '..', 'assets', 'testdata_sanitizer_tests1.dat')].each do |filename|
    JSON::parse(open(filename).read).each do |test|
      it "testdata sanitizer #{test['name']}" do
        check_sanitization(
          test['input'],
          test['output'],
          test['xhtml'] || test['output'],
          test['rexml'] || test['output']
        )
      end
    end
  end

  ## added because we don't have any coverage above on SVG_ATTR_VAL_ALLOWS_REF
  HTML5::WhiteList::SVG_ATTR_VAL_ALLOWS_REF.each do |attr_name|
    define_method "test_should_allow_uri_refs_in_svg_attribute_#{attr_name}" do
      input = "<rect fill='url(#foo)' />"
      output = "<rect fill='url(#foo)'></rect>"
      check_sanitization(input, output, output, output)
    end

    define_method "test_absolute_uri_refs_in_svg_attribute_#{attr_name}" do
      input = "<rect fill='url(http://bad.com/) #fff' />"
      output = "<rect fill='  #fff'></rect>"
      check_sanitization(input, output, output, output)
    end
  end

  def test_css_negative_value_sanitization
    html = "<span style=\"letter-spacing:-0.03em;\">"
    sane = Nokogiri::HTML(Loofah.scrub_fragment(html, :escape).to_xml)
    assert_match %r/-0.03em/, sane.inner_html
  end

  def test_css_negative_value_sanitization_shorthand_css_properties
    html = "<span style=\"margin-left:-0.05em;\">"
    sane = Nokogiri::HTML(Loofah.scrub_fragment(html, :escape).to_xml)
    assert_match %r/-0.05em/, sane.inner_html
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
