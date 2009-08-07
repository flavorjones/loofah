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
# Loofah is an HTML sanitizer wrapped around Nokogiri, an excellent
# HTML/XML parser. If you don't know how Nokogiri[http://nokogiri.org]
# works, you might want to pause for a moment and go check it out. I'll
# wait.
#
# A Loofah::HTML::Document is a subclass of Nokogiri::HTML::Document,
# so as soon as you parse your document, you get all the markup
# fixer-uppery and excellent API that Nokogiri gives you.
#
#   Loofah.document(unsafe_html).is_a?(Nokogiri::HTML::Document)         # => true
#   Loofah.fragment(unsafe_html).is_a?(Nokogiri::HTML::DocumentFragment) # => true
#
# Loofah adds a #scrub! method, which can clean up your HTML in a few different ways:
#
#   doc.scrub!(:strip)       # replaces unknown/unsafe tags with their inner text
#   doc.scrub!(:prune)       # removes  unknown/unsafe tags and their children
#   doc.scrub!(:whitewash)   # removes  unknown/unsafe/namespaced tags and their children,
#                            #          and strips all attributes (good for MS Word HTML)
#   doc.scrub!(:escape)      # escapes  unknown/unsafe tags, like this: &lt;script&gt;
#
# The above methods simply modify the document in-place. It's not serialized as a string yet!
#
# Loofah overrides +to_s+ to return html:
#
#   unsafe_html = "hi! <div>div is safe</div> <script>but script is not</script>"
#
#   doc = Loofah.fragment(unsafe_html).scrub!(:strip)
#   doc.to_s    # => "hi! <div>div is safe</div> "
#
# and +text+ to return plain text:
#
#   doc.text    # => "hi! div is safe "
#
# Or, if you prefer, you can use the shorthand methods:
#
#   Loofah.scrub_fragment(:prune, unsafe_html).to_s
#   Loofah.scrub_document(:strip, unsafe_html).to_s
#
# == Usage
#
# Let's say you run a web site, and you allow people to post HTML snippets.
#
# Let's also say some script-kiddie from Norland posts this to your site, in an effort to swipe some credit cards:
#
#     <script src=http://ha.ckers.org/xss.js></script>
#
# Oooh, that could be bad. Here's how to fix it:
#
#     safe_html = Loofah.fragment(dangerous_html).scrub!(:escape).to_s
#
#     # => "&lt;script src=\"http://ha.ckers.org/xss.js\"&gt;&lt;/script&gt;"
#
# That statement is more complex than the one-shot methods provided by other sanitizing libraries, but that's because Loofah gives you more flexibility. For example, you can retrieve the sanitized markup in both HTML and plain-text formats without incurring the overhead of multiple parsings:
#
#     safe_fragment = Loofah.fragment(dangerous_html).scrub!(:strip)
#     safe_fragment.to_s    # => HTML output
#     safe_fragment.text    # => plain text output
#
# And you can do your own munging using Nokogiri's API, if you like:
#
#     stylized_fragment = Loofah.fragment(dangerous_html).scrub!(:strip) \ 
#                           .xpath("//a/text()").wrap("<span></span>")
#
# === Parsing, and Fragments vs Documents
#
# Generally speaking, unless you expect to have \&lt;html\&gt; and \&lt;body\&gt; tags in your HTML, you don't have a *document*, you have a *fragment*.
#
# For parsing fragments, you should use Loofah.fragment. Nokogiri won't wrap the result in +html+ and +body+ tags, and will ignore +head+ elements.
#
# Full HTML documents should be parsed with Loofah.document.
#
# Here's a cool feature: Loofah.document and Loofah.fragment accept any IO object in addition to accepting a string. That IO object could be a file, or a socket, or a StringIO, or anything that responds to +read+ and +close+. Which makes it particularly easy to sanitize mass quantities of docs.
#
# === scrub!(:strip)
#
#     unsafe_html = "hi! <div>div is safe</div> <script>but script is not</script>"
#     Loofah.fragment(unsafe_html).scrub!(:strip)
#
#     => "hi! <div>div is safe</div> but script is not"
#
# === scrub!(:prune)
#
#     unsafe_html = "hi! <div>div is safe</div> <script>but script is not</script>"
#     Loofah.fragment(unsafe_html).scrub!(:strip)
#
#     => "hi! <div>div is safe</div> "
#
# === scrub!(:escape)
#
#     unsafe_html = "hi! <div>div is safe</div> <script>but script is not</script>"
#     Loofah.fragment(unsafe_html).scrub!(:strip)
#
#     => "hi! <div>div is safe</div> &lt;script&gt;but script is not&lt;/script&gt;"
#
# === scrub!(:whitewash)
#
#     unsafe_html = "hi! <div font='bleargh' style='margin: 10px'>div is heavily styled</div>"
#     Loofah.fragment(unsafe_html).scrub!(:whitewash)
#
#     => "hi! <div>div is heavily styled</div>"
#
# +:whitewash+ removes all comments, styling and attributes in
# addition to doing markup-fixer-uppery and pruning unsafe tags. I
# like to call this "whitewashing", since it's like putting a new
# layer of paint on top of the HTML input to make it look nice.
#
# One use case for this feature is to clean up HTML that was
# cut-and-pasted from Microsoft Word into a WYSIWYG editor or a rich
# text editor. Microsoft's software is famous for injecting all kinds
# of cruft into its HTML output. Who needs that? Certainly not me.
#
module Loofah
  # The version of Loofah you are using
  VERSION = '0.2.0'

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
