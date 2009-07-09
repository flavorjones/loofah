#
#  these tests taken from the HTML5 sanitization project and modified for use with Dryopteris
#  see the original here: http://code.google.com/p/html5lib/source/browse/ruby/test/test_sanitizer.rb
#
#  license text at the bottom of this file
#
require File.expand_path(File.join(File.dirname(__FILE__), '..', 'helper'))

class HTML5TestDeprecatedSanitizer < Test::Unit::TestCase
  include Dryopteris

  def sanitize_html stream
    Dryopteris.sanitize(stream)
  end

  def sanitize_doc stream
    Dryopteris.sanitize_document(stream)
  end

  def check_sanitization(input, htmloutput, xhtmloutput, rexmloutput)
    #  libxml uses double-quotes, so let's swappo-boppo our quotes before comparing.
    assert_equal htmloutput, sanitize_html(input).gsub(/"/,"'"), input

    doc = sanitize_doc(input).gsub(/"/,"'")
    assert doc.include?(htmloutput), "#{input}:\n#{doc}\nshould include:\n#{htmloutput}"
  end

  HTML5::WhiteList::ALLOWED_ELEMENTS.each do |tag_name|
    define_method "test_should_allow_#{tag_name}_tag" do
      input       = "<#{tag_name} title='1'>foo <bad>bar</bad> baz</#{tag_name}>"
      htmloutput  = "<#{tag_name.downcase} title='1'>foo &lt;bad&gt;bar&lt;/bad&gt; baz</#{tag_name.downcase}>"
      xhtmloutput = "<#{tag_name} title='1'>foo &lt;bad&gt;bar&lt;/bad&gt; baz</#{tag_name}>"
      rexmloutput = xhtmloutput

##
##  these special cases are HTML5-tokenizer-dependent.
##  libxml2 cleans up HTML differently, and I trust that.
##
#       if %w[caption colgroup optgroup option tbody td tfoot th thead tr].include?(tag_name)
#         htmloutput = "foo &lt;bad&gt;bar&lt;/bad&gt; baz"
#         xhtmloutput = htmloutput
#       elsif tag_name == 'col'
#         htmloutput = "foo &lt;bad&gt;bar&lt;/bad&gt; baz"
#         xhtmloutput = htmloutput
#         rexmloutput = "<col title='1' />"
#       elsif tag_name == 'table'
#         htmloutput = "foo &lt;bad&gt;bar&lt;/bad&gt;baz<table title='1'> </table>"
#         xhtmloutput = htmloutput
#       elsif tag_name == 'image'
#         htmloutput = "<image title='1'/>foo &lt;bad&gt;bar&lt;/bad&gt; baz"
#         xhtmloutput = htmloutput
#         rexmloutput = "<image title='1'>foo &lt;bad&gt;bar&lt;/bad&gt; baz</image>"
      if HTML5::WhiteList::VOID_ELEMENTS.include?(tag_name)
        if Nokogiri::LIBXML_VERSION <= "2.6.16"
          htmloutput = "<#{tag_name} title='1'/><p>foo &lt;bad&gt;bar&lt;/bad&gt; baz</p>"
        else
          htmloutput = "<#{tag_name} title='1'/>foo &lt;bad&gt;bar&lt;/bad&gt; baz"
        end
        xhtmloutput = htmloutput
#        htmloutput += '<br/>' if tag_name == 'br'
        rexmloutput =  "<#{tag_name} title='1' />"
      end
      check_sanitization(input, htmloutput, xhtmloutput, rexmloutput)
    end
  end

##
##  libxml2 downcases tag names as it parses, so this is unnecessary.
##
#   HTML5::WhiteList::ALLOWED_ELEMENTS.each do |tag_name|
#     define_method "test_should_forbid_#{tag_name.upcase}_tag" do
#       input = "<#{tag_name.upcase} title='1'>foo <bad>bar</bad> baz</#{tag_name.upcase}>"
#       output = "&lt;#{tag_name.upcase} title=\"1\"&gt;foo &lt;bad&gt;bar&lt;/bad&gt; baz&lt;/#{tag_name.upcase}&gt;"
#       check_sanitization(input, output, output, output)
#     end
#   end

  HTML5::WhiteList::ALLOWED_ATTRIBUTES.each do |attribute_name|
    next if attribute_name == 'style'
    next if attribute_name =~ /:/ && Nokogiri::LIBXML_VERSION <= '2.6.16'
    define_method "test_should_allow_#{attribute_name}_attribute" do
      input = "<p #{attribute_name}='foo'>foo <bad>bar</bad> baz</p>"
      output = "<p #{attribute_name}='foo'>foo &lt;bad&gt;bar&lt;/bad&gt; baz</p>"
      htmloutput = "<p #{attribute_name.downcase}='foo'>foo &lt;bad&gt;bar&lt;/bad&gt; baz</p>"
      check_sanitization(input, htmloutput, output, output)
    end
  end

##
##  libxml2 downcases attributes as it parses, so this is unnecessary.
##
#   HTML5::WhiteList::ALLOWED_ATTRIBUTES.each do |attribute_name|
#     define_method "test_should_forbid_#{attribute_name.upcase}_attribute" do
#       input = "<p #{attribute_name.upcase}='display: none;'>foo <bad>bar</bad> baz</p>"
#       output =  "<p>foo &lt;bad&gt;bar&lt;/bad&gt; baz</p>"
#       check_sanitization(input, output, output, output)
#     end
#   end

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

  if false # TODO. should we even care about this? libxml2 punt.
    def test_should_handle_astral_plane_characters
      input = "<p>&#x1d4b5; &#x1d538;</p>"
      output = "<p>\360\235\222\265 \360\235\224\270</p>"
      check_sanitization(input, output, output, output)
      
      input = "<p><tspan>\360\235\224\270</tspan> a</p>"
      output = "<p><tspan>\360\235\224\270</tspan> a</p>"
      check_sanitization(input, output, output, output)
    end
  end

# This affects only NS4. Is it worth fixing?
#  def test_javascript_includes
#    input = %(<div size="&{alert('XSS')}">foo</div>)
#    output = "<div>foo</div>"
#    check_sanitization(input, output, output, output)
#  end

  #html5_test_files('sanitizer').each do |filename|
  #  JSON::parse(open(filename).read).each do |test|
  #    define_method "test_#{test['name']}" do
  #      check_sanitization(
  #        test['input'],
  #        test['output'],
  #        test['xhtml'] || test['output'],
  #        test['rexml'] || test['output']
  #      )
  #    end
  #  end
  #end
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
