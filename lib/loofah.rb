$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__))) unless $LOAD_PATH.include?(File.expand_path(File.dirname(__FILE__)))

require 'rubygems'
require 'nokogiri'

require 'loofah/html5/whitelist'
require 'loofah/html5/scrub'

require 'loofah/scrubber'

require 'loofah/html/document'
require 'loofah/html/document_fragment'

require 'loofah/deprecated'


#
# Loofah is an HTML sanitizer wrapped around Nokogiri[http://nokogiri.org], an excellent
# HTML/XML parser. If you don't know how Nokogiri[http://nokogiri.org]
# works, you might want to pause for a moment and go check it out. I'll
# wait.
#
# A Loofah::HTML::Document is a subclass of Nokogiri::HTML::Document,
# so a parsed document gives you all the markup fixer-uppery and API
# goodness of Nokogiri.
#
#   Loofah.document(unsafe_html).is_a?(Nokogiri::HTML::Document)         # => true
#   Loofah.fragment(unsafe_html).is_a?(Nokogiri::HTML::DocumentFragment) # => true
#
# Loofah adds a +scrub!+ method, which can clean up your HTML in a few
# different ways by modifying the document in-place:
#
#   doc.scrub!(:strip)       # replaces unknown/unsafe tags with their inner text
#   doc.scrub!(:prune)       # removes  unknown/unsafe tags and their children
#   doc.scrub!(:whitewash)   # removes  unknown/unsafe/namespaced tags and their children,
#                            #          and strips all node attributes
#   doc.scrub!(:escape)      # escapes  unknown/unsafe tags, like this: &lt;script&gt;
#
# Loofah overrides +to_s+ to return html:
#
#   unsafe_html = "ohai! <div>div is safe</div> <script>but script is not</script>"
#
#   doc = Loofah.fragment(unsafe_html).scrub!(:strip)
#   doc.to_s    # => "ohai! <div>div is safe</div> "
#
# and +text+ to return plain text:
#
#   doc.text    # => "ohai! div is safe "
#
# Or, if you prefer, you can use the shorthand methods +scrub_fragment+ and +scrub_document+:
#
#   Loofah.scrub_fragment(unsafe_html, :prune).to_s
#   Loofah.scrub_document(unsafe_html, :strip).text
#
# == Usage
#
# Let's say you have a Web 2.0 application, and you allow people to
# send HTML snippets to each other.
#
# Let's also say some script-kiddie from Norland sends this to your
# users, in an effort to swipe some credit cards:
#
#     <script src=http://ha.ckers.org/xss.js></script>
#
# Oooh, that could be bad. Here's how to fix it:
#
#     Loofah.scrub_fragment(dangerous_html, :escape).to_s
#
#     # => "&lt;script src=\"http://ha.ckers.org/xss.js\"&gt;&lt;/script&gt;"
#
# Loofah also makes available the sanitized markup in both HTML and
# plain-text formats without incurring the overhead of multiple
# parsings:
#
#     safe_fragment = Loofah.scrub_fragment(dangerous_html, :strip)
#     safe_fragment.to_s    # => HTML output
#     safe_fragment.text    # => plain text output
#
# And you can modify the HTML using Nokogiri's API, if you like:
#
#     stylized_fragment = Loofah.fragment(dangerous_html)
#     stylized_fragment.xpath("//a/text()").wrap("<span></span>")
#     stylized_fragment.scrub!(:strip)
#
# == Fragments vs Documents
#
# Generally speaking, unless you expect to have \&lt;html\&gt; and
# \&lt;body\&gt; tags in your HTML, you don't have a *document*, you
# have a *fragment*.
#
# For parsing fragments, you should use Loofah.fragment. Nokogiri
# won't wrap the result in +html+ and +body+ tags, and will ignore
# +head+ elements.
#
# Full HTML documents should be parsed with Loofah.document, which
# will add the DOCTYPE declaration, and properly handle +head+ and
# +body+ elements.
#
# == Strings and IO Objects as Input
#
# Loofah.document and Loofah.fragment accept any IO object in addition
# to accepting a string. That IO object could be a file, or a socket,
# or a StringIO, or anything that responds to +read+ and
# +close+. Which makes it particularly easy to sanitize mass
# quantities of docs.
#
# == Scrubbing Methods
#
# Given:
#     unsafe_html = "ohai! <div>div is safe</div> <foo>but foo is <b>not</b></foo>"
#
# === scrub!(:strip)
#
# +:strip+ removes unknown/unsafe tags, but leaves behind the pristine contents:
#
#     Loofah.fragment(unsafe_html).scrub!(:strip)
#     # or
#     Loofah.scrub_fragment(unsafe_html, :strip)
#
#     => "ohai! <div>div is safe</div> but foo is <b>not</b>"
#
# === scrub!(:prune)
#
# +:prune+ removes unknown/unsafe tags and their contents (including their subtrees):
#
#     Loofah.fragment(unsafe_html).scrub!(:prune)
#     # or
#     Loofah.scrub_fragment(unsafe_html, :prune)
#
#     => "ohai! <div>div is safe</div> "
#
# === scrub!(:escape)
#
# +:escape+ performs HTML entity escaping on the unknown/unsafe tags:
#
#     Loofah.fragment(unsafe_html).scrub!(:escape)
#     # or
#     Loofah.scrub_fragment(unsafe_html, :escape)
#
#     => "ohai! <div>div is safe</div> &lt;foo&gt;but foo is &lt;b&gt;not&lt;/b&gt;&lt;/foo&gt;"
#
# === scrub!(:whitewash)
#
# +:whitewash+ removes all comments, styling and attributes in
# addition to doing markup-fixer-uppery and pruning unsafe tags. I
# like to call this "whitewashing", since it's like putting a new
# layer of paint on top of the HTML input to make it look nice.
#
#     messy_markup = "ohai! <div id='foo' class='bar' style='margin: 10px'>div with attributes</div>"
#
#     Loofah.fragment(messy_markup).scrub!(:whitewash)
#     # or
#     Loofah.scrub_fragment(messy_markup, :whitewash)
#
#     => "ohai! <div>div with attributes</div>"
#
# One use case for this feature is to clean up HTML that was
# cut-and-pasted from Microsoft Word into a WYSIWYG editor or a rich
# text editor. Microsoft's software is famous for injecting all kinds
# of cruft into its HTML output. Who needs that? Certainly not me.
#
module Loofah
  # The version of Loofah you are using
  VERSION = '0.2.2'

  # The minimum required version of Nokogiri
  REQUIRED_NOKOGIRI_VERSION = '1.3.3'

  class << self
    # Shortcut for Loofah::HTML::Document.parse
    # This method accepts the same parameters as Nokogiri::HTML::Document.parse
    def document(*args, &block)
      Loofah::HTML::Document.parse(*args, &block)
    end

    # Shortcut for Loofah::HTML::DocumentFragment.parse
    # This method accepts the same parameters as Nokogiri::HTML::DocumentFragment.parse
    def fragment(*args, &block)
      Loofah::HTML::DocumentFragment.parse(*args, &block)
    end

    # Shortcut for Loofah.fragment(string_or_io).scrub!(method)
    def scrub_fragment(string_or_io, method)
      Loofah.fragment(string_or_io).scrub!(method)
    end

    # Shortcut for Loofah.document(string_or_io).scrub!(method)
    def scrub_document(string_or_io, method)
      Loofah.document(string_or_io).scrub!(method)
    end

  end
end

if Nokogiri::VERSION < Loofah::REQUIRED_NOKOGIRI_VERSION
  raise RuntimeError, "Loofah requires Nokogiri #{Loofah::REQUIRED_NOKOGIRI_VERSION} or later (currently #{Nokogiri::VERSION})"
end

if defined? Rails.configuration # rails 2.1 and later
  Rails.configuration.after_initialize do
    require 'loofah/active_record'
  end
elsif defined? ActiveRecord::Base # rails 2.0
  require 'loofah/active_record'
end
