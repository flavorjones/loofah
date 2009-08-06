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
# Loofah subclasses Nokogiri::HTML::Document and ::DocumentFragment,
# so as soon as you parse your document, you get all the markup
# fixer-uppery and excellent API that Nokogiri gives you.
#
#   doc = Loofah.fragment(unsafe_html)
#   doc.is_a? Nokogiri::HTML::DocumentFragment # => true
#
# Loofah adds a #scrub! method, which can clean up your HTML in a few different ways:
#
#   doc.scrub!(:yank)        # replaces unknown/unsafe tags with their inner text
#   doc.scrub!(:prune)       # removes  unknown/unsafe tags and their children
#   doc.scrub!(:whitewash)   # removes  unknown/unsafe/namespaced tags and their children,
#                               # and strips all attributes (good for MS Word HTML)
#   doc.scrub!(:escape)      # escapes  unknown/unsafe tags, like this: &lt;script&gt;
#
# The above methods simply modify the document in-place. It's not serialized as a string yet!
#
# Loofah also overrides #to_s to give you your html back:
#
#   unsafe_html = "hi! <div>div is safe</div> <script>but script is not</script>"
#
#   doc = Loofah.fragment(unsafe_html).scrub!(:yank)
#   doc.to_s    # => "hi! <div>div is safe</div> "
#
# and #text to give you the plain text version
#
#   doc.text    # => "hi! div is safe "
#
#
# == Usage
#
# Let's say you run a web site, and you allow people to post HTML snippets.
#
# Let's also say some script-kiddie from Norland posts this to your site, in an effort to swipe some credit cards:
#
#     <SCRIPT SRC=http://ha.ckers.org/xss.js></SCRIPT>
#
# Oooh, that could be bad. Here's how to fix it:
#
#     safe_html_snippet = Loofah.sanitize(dangerous_html_snippet)
#
# Yeah, it's that easy.
#
# In this example, <tt>safe\_html\_snippet</tt> will have all of its <b>broken markup fixed</b> by libxml2, and it will also be completely <b>sanitized of harmful tags and attributes</b>. That's twice as clean!
#
#
# == Sanitization Usage
#
# You're still here? Ok, let me tell you a little something about the two different methods of sanitizing the Loofah offers.
#
# === Fragments
#
# The first method is for _html fragments_, which are small snippets of markup such as those used in forum posts, emails and homework assignments.
#
# Usage is the same as above:
#
#     safe_html_snippet = Loofah.sanitize(dangerous_html_snippet)
#
# Generally speaking, unless you expect to have &lt;html&gt; and &lt;body&gt; tags in your HTML, this is the sanitizing method to use.
#
# The only real limitation on this method is that the snippet must be a string object. (Support for IO objects was sacrificed at the altar of fixer-uppery-ness. If you need to sanitize data that's coming from an IO object, either socket or file, check out the next section on __Documents__).
#
# === Documents
#
# Sometimes you need to sanitize an entire HTML document. (Well, maybe not _you_, but other people, certainly.)
#
#     safe_html_document = Loofah.sanitize_document(dangerous_html_document)
#
# The returned string will contain exactly one (1) well-formed HTML document, with all broken HTML fixed and all harmful tags and attributes removed.
#
# Coolness: <tt>dangerous\_html\_document</tt> can be a string OR an IO object (a file, or a socket, or ...). Which makes it particularly easy to sanitize large numbers of docs.
#
# == Whitewashing Usage
#
# === Whitewashing Fragments
#
# Other times, you may want to remove all styling, attributes and invalid HTML tags. I like to call this "whitewashing", since it's putting a new layer of paint on top of the HTML input to make it look nice.
#
# One use case for this feature is to clean up HTML that was cut-and-pasted from Microsoft(tm) Word into a WYSIWYG editor/textarea. Microsoft's editor is famous for injecting all kinds of cruft into its HTML output. Who needs that? Certainly not me.
#
#     whitewashed_html = Loofah.whitewash(ugly_microsoft_html_snippet)
#
# Please note that whitewashing implicitly also sanitizes your HTML, as it uses the same HTML tag whitelist as <tt>sanitize()</tt>. It's implementation is:
#
#  1. unless the tag is on the whitelist, remove it from the document
#  2. if the tag has an XML namespace on it, remove it from the document
#  2. remove all attributes from the node
#
# === Whitewashing Documents
#
# Also note the existence of <tt>whitewash\_document</tt>, which is analogous to <tt>sanitize\_document</tt>.
#
module Loofah
  # The version of Loofah you are using
  VERSION = '0.2.0'

  # The minimum required version of Nokogiri
  NOKOGIRI_VERSION = '1.3.3'

  class << self
    # Shortcut for Loofah::HTML::Document.parse
    def document(*args, &block)
      Loofah::HTML::Document.parse(*args, &block)
    end

    # Shortcut for Loofah::HTML::DocumentFragment.parse
    def fragment(*args, &block)
      Loofah::HTML::DocumentFragment.parse(*args, &block)
    end
  end
end

if Nokogiri::VERSION < Loofah::NOKOGIRI_VERSION
  raise RuntimeError, "Loofah requires Nokogiri #{Loofah::NOKOGIRI_VERSION} or later (currently #{Nokogiri::VERSION})"
end
