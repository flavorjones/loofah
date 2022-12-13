# Decision Summary

When encountering CDATA nodes in an HTML4 document that might be treated as PCDATA by HTML5 parsers, we decided to escape the `<`, `>`, and `&` characters in that CDATA node to prevent XSS attacks, accepting that those characters will escaped even in the valid HTML4 CDATA context of a `style` tag, because that situation seems to be a rare use case that impacts only browser style, and because once Loofah defaults to HTML5 parsing (potentially in the very near future) this drawback goes away.

<!-- regenerate TOC with `markdown-toc --maxdepth=2 -i` -->

<!-- toc -->

- [Recommendations](#recommendations)
  * [Short term](#short-term)
  * [Long term](#long-term)
- [What's Happening in these CVEs](#whats-happening-in-these-cves)
  * [The underlying behavior](#the-underlying-behavior)
  * [Side note: CDATA vs PCDATA](#side-note-cdata-vs-pcdata)
  * [2015-08-08: rails-html-sanitizer CVE-2015-7580](#2015-08-08-rails-html-sanitizer-cve-2015-7580)
  * [2017-10-10: loofah vulnerability](#2017-10-10-loofah-vulnerability)
  * [2022-04-05: `select` and `style` parents, `script` payload:](#2022-04-05-select-and-style-parents-script-payload)
  * [Today: the foreign context vulnerability](#today-the-foreign-context-vulnerability)
- [Solutions](#solutions)
  * [Potential solution 1](#potential-solution-1)
  * [Potential solution 2](#potential-solution-2)

<!-- tocstop -->

# Recommendations

## Short term

I recommend adopting [Solution 2](#potential-solution-2) below:

- revert the patch in rails-html-sanitizer v1.4.3
- apply `CGI.escapeHTML` on all CDATA nodes created by Nokogiri's HTML4 parser.

This addresses all known rails-html-sanitizer vulnerabilities related to HTML4/HTML5 parser behavior mismatches, does not introduce any additional backwards-incompatible changes in behavior, is simple enough to easily reason about, and does not suffer from the performance or stack depth problems present in [Solution 1](#potential-solution-1).


(Note that both solutions considered in this doc share one small backwards-incompatibility, which is "special characters in valid `style` tags will be entity-escaped". Unfortunately this is hard to prevent without making this patch significantly more complex, and once Loofah defaults to an HTML5 parser this behavior goes away. I am recommending we move forward with this solution despite this inconvenience.)

Action items: 

- implement this logic in Loofah and release v2.19.1
- call into Loofah from rails-html-sanitizer, bump the dependency, and cut a v1.4.x release


## Long term

### Use HTML5 sanitization

It's important to note that if we use an HTML5 parser for the sanitization pass, this entire class of problem goes away.

We should move RHS to an HTML5 parser as soon as possible.

- [Loofah using HTML5 by default](https://github.com/flavorjones/loofah/pull/239) is blocked on a Nokogiri v1.14.0 release
- [RHS behavior changes are documented here](https://github.com/rails/rails-html-sanitizer/pull/133) in the updated tests


### Avoid functional drift between Loofah and RHS

It's important to note that Loofah and RHS initially solved the same problem in two different ways. I consider this to be a huge missed opportunity.

We should adopt a policy of building features or hooks into Loofah to enable RHS to be as small as possible with only Rails-specific modifications to scrubbers.

- https://github.com/rails/rails-html-sanitizer/pull/136 examines the behavior differences between the two implementations
- `data-` attributes are the big diff, https://hackerone.com/reports/42728 was the motivating issue for that change


# What's Happening in these CVEs

There are a few related CVE and bugs that are all related to the same underlying behavior:

- [#81212 Potential XSS on sanitize/Rails::Html::WhiteListSanitizer](https://hackerone.com/reports/81212)
- [Nested Scripts · Issue #127 · flavorjones/loofah](https://github.com/flavorjones/loofah/issues/127)
- [#1530898 Rails::Html::SafeListSanitizer vulnerable to xss attack in an environment that allows the style tag](https://hackerone.com/bugs?report_id=1530898&subject=rails)
- [#1654310 Incomplete fix for CVE-2022-32209 (XSS in Rails::Html::Sanitizer under certain configurations)](https://hackerone.com/reports/1654310)
- [#1656627 Rails::Html::SafeListSanitizer vulnerable to XSS when certain tags are allowed (math+style || svg+style)](https://hackerone.com/reports/1656627)

Most of these are analyzed in detail below.

You may wish to refer to the [WHATWG HTML5 Standard](https://html.spec.whatwg.org/multipage/parsing.html) as an aid to follow the detailed explanations below.

## The underlying behavior

First, let's build a mental model, using only Nokogiri's HTML4 and HTML5 parsers, for the underlying mechanism that's causing problems.

Let's start with this input string:

``` html
<select>
  <style>
    <script>alert(1);</script>
  </style>
</select>
```

Nokogiri uses the libxml2 HTML4 parser to generate this HTML4 DOM:

``` text
#(Element:0x564 {
  name = "body",
  children = [
    #(Element:0x578 {
      name = "select",
      children = [
        #(Element:0x58c {
          name = "style",
          children = [ #(CDATA "<script>alert(1);</script>")]
          })]
      }),
    #(Text "\n")]
```

**⚠ Note that in the above DOM structure, the `style` tag's child is CDATA.**

This HTML4 DOM serializes as:

``` html
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN" "http://www.w3.org/TR/REC-html40/loose.dtd">
<html><body>
<select><style><script>alert(1);</script></style></select>
</body></html>
```

**⚠ Note that the CDATA payload of `style` is presented literally, without any entity escaping.**

Feeding the serialized HTML4 document into an HTML5 parser builds the following HTML5 DOM:

``` text
#(Element:0x5f0 {
  name = "body",
  children = [
    #(Text "\n"),
    #(Element:0x604 {
      name = "select",
      children = [
        #(Element:0x618 {
          name = "script",
          children = [ #(Text "alert(1);")]
          })]
      }),
    #(Text "\n" + "\n")]
  })]
```

**⚠ Note that the `style` tag has been removed because the HTML5 parser considers it to be an invalid child of `select`!** The internal HTML5 parser states are described in detail later in this document.

This DOM is equivalent to:

``` html
<!DOCTYPE html><html><head></head><body>
<select><script>alert(1);</script></select>

</body></html>
```

**⚠ Browsers will execute this javascript!**

TL;DR: The underlying issue is the combination of two behaviors:

1. libxml2's HTML4 parser serializes CDATA nodes without entity-escaping;
2. the user agent's HTML5 parser can be made to parse that HTML4 CDATA payload as HTML5 PCDATA.

libxml2's HTML4 parser creates CDATA nodes **only** for `script` and `style` tag contents. As a result, this class of sanitization vulnerability appears in situations where input contains nested `script` tags or where `style` tags are permitted but might be invalid in HTML5.


## Side note: CDATA vs PCDATA

CDATA is a string of bytes that HTML4 parsers will parse as **text and only text**; any embedded characters like `<` or `>` that might be invalid in HTML4 text nodes are valid here! Think of it as a **string literal**.

CDATA is not a thing in HTML5, which instead specifies a series of tokenizer and parser states and transitions -- for example, [tokenizing a `script` tag](https://html.spec.whatwg.org/multipage/parsing.html#script-data-state) or [tokenizing a `style` tag](https://html.spec.whatwg.org/multipage/parsing.html#rawtext-state).

PCDATA is a string of bytes that HTML4 parsers will interpret as a DOM. This data is _structural_, so characters like `<` and `>` are likely to be interpreted as parts of HTML tags. 

There is no such thing as PCDATA in the HTML5 spec (reiterating, HTML5 is specified using tokenizer and parser states and transitions), but it's useful shorthand to mean _bytes that will determine the structure of the document_ and so I hope you'll forgive my slight misuse of the term in this document.


## 2015-08-08: rails-html-sanitizer CVE-2015-7580

(Reported on 2015-08-08 in https://hackerone.com/reports/81212 (and separately in https://hackerone.com/reports/89914) and announced in https://nvd.nist.gov/vuln/detail/CVE-2015-7580 and https://github.com/advisories/GHSA-ghqm-pgxj-37gq.)

This vulnerability describes nested script tags going unsanitized:

``` ruby
#! /usr/bin/env ruby

require "bundler/inline"

gemfile do
  source "https://rubygems.org"
  gem "rails-html-sanitizer", "=1.0.2"
  gem "loofah", "=2.0.2"
  gem "nokogiri", "=1.6.6.2"
end

require "rails-html-sanitizer"

def sanitize(input, tags)
  Rails::Html::WhiteListSanitizer.new.sanitize(input, tags: tags)
end

input = "<div><script><script></script>alert(1);<script><</script>/</script><script>script></script></div>"
tags = %w(div)
sanitize(input, tags) # => "<div>\n<script>alert(1);</script>\n</div>"
```

This was fixed with https://github.com/rails/rails-html-sanitizer/commit/63903b0eaa6d2a4e1c91bc86008256c4c8335e78

``` patch
diff --git a/lib/rails/html/scrubbers.rb b/lib/rails/html/scrubbers.rb
index d6f8ce4..1e6f887 100644
--- a/lib/rails/html/scrubbers.rb
+++ b/lib/rails/html/scrubbers.rb
@@ -60,6 +60,11 @@ def attributes=(attributes)
       end
 
       def scrub(node)
+        if node.cdata?
+          text = node.document.create_text_node node.text
+          node.replace text
+          return CONTINUE
+        end
         return CONTINUE if skip_node?(node)
 
         unless keep_node?(node)
@@ -76,7 +81,7 @@ def allowed_node?(node)
       end
 
       def skip_node?(node)
-        node.text? || node.cdata?
+        node.text?
       end
 
       def scrub_attribute?(name)
```

which changed the behavior to:

``` ruby
#! /usr/bin/env ruby

require "bundler/inline"

gemfile do
  source "https://rubygems.org"
  gem "rails-html-sanitizer", "=1.0.3" # contains the fix
  gem "loofah", "=2.0.2"
  gem "nokogiri", "=1.6.6.2"
end

require "rails-html-sanitizer"

def sanitize(input, tags)
  Rails::Html::WhiteListSanitizer.new.sanitize(input, tags: tags)
end

input = "<div><script><script></script>alert(1);<script><</script>/</script><script>script></script></div>"
tags = %w(div)
sanitize(input, tags) # => "<div>&lt;script&gt;alert(1);&lt;/script&gt;</div>"
```

Here's how this patch works:

- the `script` tag's CDATA contents are converted into a Text node
- the parent `script` start and end tags are removed by the sanitizer
- the Text node left behind is then made a child of `div`
- as a child of `div`, the Text node will be entity-escaped
- which means the HTML5 parser receives `&lt;script&gt;...` instead of `<script>...`


This works because libxml2's HTML4 parser serializes all CDATA nodes, and any Text children of `script` and `style`, **without entities**,  but Text nodes that have been reparented under any other HTML4 tag **will be entity-escaped**. You can easily see this behavior by writing some code:

``` ruby
s = "check if <, >, and & are entities"
doc = Nokogiri::HTML::Document.parse("<div></div><style></style>")

doc.at_css("style").tap do |node|
  node.children = node.document.create_cdata(s)
  node.to_html # => "<style>check if <, >, and & are entities</style>\n"

  node.children = node.document.create_text_node(s)
  node.to_html # => "<style>check if <, >, and & are entities</style>\n"
end

doc.at_css("div").tap do |node|
  node.children = node.document.create_cdata(s)
  node.to_html # => "<div>check if <, >, and & are entities</div>\n"

  node.children = node.document.create_text_node(s)
  node.to_html # => "<div>check if &lt;, &gt;, and &amp; are entities</div>\n"
end
```


## 2017-10-10: loofah vulnerability

(Reported to Loofah on 2017-10-10 in https://github.com/flavorjones/loofah/issues/127.)

This "bug" also described a vulnerability related to nested script tags going unsanitized:

``` ruby
#! /usr/bin/env ruby

require "bundler/inline"

gemfile do
  source "https://rubygems.org"
  gem "loofah", "=2.1.1"
end

require "loofah"

def sanitize(input)
  Loofah.fragment(input).scrub!(:strip).to_html
end

input = "<div><script><script src='malicious.js'></script></div>"
sanitize(input) # => "<div><script src='malicious.js'></div>"
```

This was fixed in https://github.com/flavorjones/loofah/pull/132 by recursively sanitizing CDATA nodes:

``` patch
diff --git a/lib/loofah/scrubbers.rb b/lib/loofah/scrubbers.rb
index 508f6bf..982c593 100644
--- a/lib/loofah/scrubbers.rb
+++ b/lib/loofah/scrubbers.rb
@@ -99,7 +99,12 @@ def initialize
 
       def scrub(node)
         return CONTINUE if html5lib_sanitize(node) == CONTINUE
-        node.before node.children
+        if node.children.length == 1 && node.children.first.cdata?
+          sanitized_text = Loofah.fragment(node.children.first.to_html).scrub!(:strip).to_html
+          node.before Nokogiri::XML::Text.new(sanitized_text, node.document)
+        else
+          node.before node.children
+        end
         node.remove
       end
     end
```

This changed the behavior to:

``` ruby
#! /usr/bin/env ruby

require "bundler/inline"

gemfile do
  source "https://rubygems.org"
  gem "loofah", "=2.2.0" # contains the fix
end

require "loofah"

def sanitize(input)
  Loofah.fragment(input).scrub!(:strip).to_html
end

input = "<div><script><script src='malicious.js'></script></div>"
sanitize(input) # => "<div></div>"
```

One drawback to this recursive approach is that it's possible to trigger a "stack level too deep" exception in Loofah with sufficient nesting of script tags (see [Uncontrolled Recursion in Loofah · Advisory · flavorjones/loofah](https://github.com/flavorjones/loofah/security/advisories/GHSA-3x8r-x6xp-q4vm)).


## 2022-04-05: `select` and `style` parents, `script` payload:

Looking at CVE-2022-32209 ([#1530898 Rails::Html::SafeListSanitizer vulnerable to xss attack in an environment that allows the style tag](https://hackerone.com/bugs?report_id=1530898&subject=rails))

``` ruby
#! /usr/bin/env ruby

require "bundler/inline"

gemfile do
  source "https://rubygems.org"
  gem "rails-html-sanitizer", "=1.4.2"
end

require "rails-html-sanitizer"

def sanitize(input, tags)
  Rails::Html::WhiteListSanitizer.new.sanitize(input, tags: tags)
end

input, tags = "<select><style><script>alert(1)</script></style></select>", %w(select style)
sanitize(input, tags) # => "<select><style><script>alert(1)</script></style></select>"
```

In this case, the HTML4 doc's CDATA payload:

``` text
#(Element:0x5f0 {
  name = "body",
  children = [
    #(Element:0x604 {
      name = "select",
      children = [ #(Element:0x618 { name = "style", children = [ #(CDATA "<script>alert(1)</script>")] })]
      }),
    #(Text "\n")]
  })]
```

is serialized as:

``` html
<select><style><script>alert(1)</script></style></select>
```

The states that the HTML5 parser goes through as it parses this are roughly:

- ...
- insertion mode: ["in body"](https://html.spec.whatwg.org/multipage/parsing.html#parsing-main-inbody)
  - see "select"
    - insert `select` tag into `body`
    - move to ["in select" insertion mode](https://html.spec.whatwg.org/multipage/parsing.html#parsing-main-inselect)
- insertion mode: "in select"
  - see "style"
    - **ignore tag and drop it**
  - see "script"
    - **insert `script` tag into `select`**
    - move to ["text" insertion mode](https://html.spec.whatwg.org/multipage/parsing.html#parsing-main-incdata)
- insertion mode: "text"
  - see text tokens
    - insert them into `script`
- ...


resulting in this HTML5 DOM:

``` text
#(Element:0x67c {
  name = "body",
  children = [
    #(Text "\n"),
    #(Element:0x690 {
      name = "select",
      children = [ #(Element:0x6a4 { name = "script", children = [ #(Text "alert(1)")] })]
      }),
    #(Text "\n" + "\n")]
  })]
```

which is equivalent to

``` html
<!DOCTYPE html><html><head></head><body>
<select><script>alert(1)</script></select>

</body></html>
```

**⚠ Browsers will execute this javascript!**

With [the fix in v1.4.3](https://github.com/rails/rails-html-sanitizer/commit/45a5c10) the result is sanitized:

``` ruby
#! /usr/bin/env ruby

require "bundler/inline"

gemfile do
  source "https://rubygems.org"
  gem "rails-html-sanitizer", "=1.4.3" # contains the select/style fix
end

require "rails-html-sanitizer"

def sanitize(input, tags)
  Rails::Html::WhiteListSanitizer.new.sanitize(input, tags: tags)
end

input, tags = "<select><style><script>alert(1)</script></style></select>", %w(select style)
sanitize(input, tags) # => "<select>&lt;script&gt;alert(1)&lt;/script&gt;</select>"
# >> WARNING: Rails::Html::SafeListSanitizer: removing 'style' from safelist, should not be combined with 'select'
```

It's worth noting that this fix relies on the Text node fix for CVE-2015-7580 by reparenting the `style` CDATA payload as a Text child of `select`, so that the entities are properly escaped.


## Today: the foreign context vulnerability

Looking at [#1656627 Rails::Html::SafeListSanitizer vulnerable to XSS when certain tags are allowed (math+style || svg+style)](https://hackerone.com/reports/1656627) which describes a similar attack vector to CVE-2022-32209:

``` ruby
#! /usr/bin/env ruby

require "bundler/inline"

gemfile do
  source "https://rubygems.org"
  gem "rails-html-sanitizer", "=1.4.3" # contains the select/style fix
end

require "rails-html-sanitizer"

def sanitize(input, tags)
  Rails::Html::WhiteListSanitizer.new.sanitize(input, tags: tags)
end

input, tags = "<svg><style><script>alert(1);</script></style></svg>", %w(svg style)
sanitize(input, tags) # => "<svg><style><script>alert(1);</script></style></svg>"

input, tags = "<math><style><img src=x onerror=alert(1)></style></math>", %w(math style img)
sanitize(input, tags) # => "<math><style><img src=x onerror=alert(1)></style></math>"
```

In both of these cases, the HTML5 parser is put into a "foreign context" parsing mode that causes it to parse CDATA as PCDATA.


### the `svg` case

In the `svg` case, the HTML4 DOM is:

``` text
#(Element:0x5f0 {
  name = "body",
  children = [
    #(Element:0x604 {
      name = "svg",
      children = [ #(Element:0x618 { name = "style", children = [ #(CDATA "<script>alert(1)</script>")] })]
      }),
    #(Text "\n")]
  })]
```

serialized as:

``` html
<svg><style><script>alert(1)</script></style></svg>
```

The states that the HTML5 parser goes through as it parses this are roughly:

- ...
- insertion mode: "in body"
  - see "svg"
    - insert `svg` tag into `body`
    - move to ["in foreign content" insertion mode](https://html.spec.whatwg.org/multipage/parsing.html#parsing-main-inforeign)
- insertion mode: "in foreign content"
  - see "style"
    - insert `style` tag into `svg`
  - see "script"
    - insert `script` tag into `style`
  - see text tokens
    - insert them into `script`
- ...

resulting in this HTML5 DOM:

``` text
#(Element:0x67c {
  name = "body",
  children = [
    #(Text "\n"),
    #(Element:0x690 {
      name = "svg",
      namespace = #(Namespace:0x6a4 { prefix = "svg", href = "http://www.w3.org/2000/svg" }),
      children = [
        #(Element:0x6b8 {
          name = "style",
          namespace = #(Namespace:0x6a4 { prefix = "svg", href = "http://www.w3.org/2000/svg" }),
          children = [
            #(Element:0x6cc {
              name = "script",
              namespace = #(Namespace:0x6a4 { prefix = "svg", href = "http://www.w3.org/2000/svg" }),
              children = [ #(Text "alert(1)")]
              })]
          })]
      }),
    #(Text "\n" + "\n")]
  })]
```

which is equivalent to:

``` html
<svg><style><script>alert(1)</script></style></svg>
```

**⚠ Browsers will execute this javascript!**

Note that this behavior is also demonstrated with a `math` parent tag, but is not a vulnerability as browsers will not execute the contents of `script` tags in a MathML context. (See [SVG11](https://www.w3.org/TR/SVG11/script.html#ScriptElement) for documentation on SVG support for the `script` element.)


### the `math` case

For the `math` case, the HTML4 DOM is:

``` text
#(Element:0x5f0 {
  name = "body",
  children = [
    #(Element:0x604 {
      name = "math",
      children = [
        #(Element:0x618 { name = "style", children = [ #(CDATA "<img src=x onerror=alert(1)>")] })]
      }),
    #(Text "\n")]
  })]
```

serialized as:

``` html
<math><style><img src=x onerror=alert(1)></style></math>
```

The states that the HTML5 parser goes through as it parses this are roughly:

- ...
- insertion mode: "in body"
  - see "math"
    - insert `math` tag into `body`
    - move to "in foreign content" insertion mode
- insertion mode: "in foreign content"
  - see "style"
    - insert tag into `math`
  - see "img"
    - **consider it a parse error**
    - pop `style` node (close it)
    - pop `math` node (close it)
    - **insert `img` tag into `body`**
    - move to "in body" insertion mode
- insertion mode: "in body"
  - see `</style>`
    - consider it a parse error
    - ignore it
  - see `</math>`
    - consider it a parse error
    - ignore it
- ...

resulting in this HTML5 DOM:

``` text
#(Element:0x67c {
  name = "body",
  children = [
    #(Text "\n"),
    #(Element:0x690 {
      name = "math",
      namespace = #(Namespace:0x6a4 { prefix = "math", href = "http://www.w3.org/1998/Math/MathML" }),
      children = [
        #(Element:0x6b8 {
          name = "style",
          namespace = #(Namespace:0x6a4 { prefix = "math", href = "http://www.w3.org/1998/Math/MathML" })
          })]
      }),
    #(Element:0x6cc {
      name = "img",
      attributes = [
        #(Attr:0x6e0 { name = "src", value = "x" }),
        #(Attr:0x6f4 { name = "onerror", value = "alert(1)" })]
      }),
    #(Text "\n" + "\n")]
  })]
```

which is equivalent to:

``` html
<math><style></style></math><img src="x" onerror="alert(1)">
```

**⚠ Browsers will execute this javascript!**


Here we see that the `img` tag data which was originally contained within HTML4 CDATA context (and avoided sanitization of its attributes) has been lifted out of that context by the HTML5 parser, and parsed as a sibling to the `math` element.

Note that this behavior (and the vulnerability) is also present if we replace `<math>...</math>` with `<svg>...</svg>`.


# Solutions

## Potential solution 1

Rollback [the RHS fix applied in c871aa4 / 45a5c10](https://github.com/rails/rails-html-sanitizer/commit/45a5c10) and adopt Loofah's strategy (noted described above) of recursively sanitizing any HTML4 CDATA nodes.

### The patch

The code changes, after the revert, for this behavior would be:

``` patch
diff --git a/lib/rails/html/scrubbers.rb b/lib/rails/html/scrubbers.rb
index 09cfe95..7f29c12 100644
--- a/lib/rails/html/scrubbers.rb
+++ b/lib/rails/html/scrubbers.rb
@@ -61,9 +61,10 @@ def attributes=(attributes)
       end
 
       def scrub(node)
-        if node.cdata?
-          text = node.document.create_text_node node.text
-          node.replace text
+        if needs_further_escaping(node)
+          safe_text = Loofah.fragment(node.text).scrub!(self).to_html
+          safe_node = node.document.create_text_node(safe_text)
+          node.replace safe_node
           return CONTINUE
         end
         return CONTINUE if skip_node?(node)
@@ -77,6 +78,11 @@ def scrub(node)
 
       protected
 
+      def needs_further_escaping(node)
+        # Nokogiri's HTML4 parser on JRuby doesn't flag the child of a `style` tag as cdata, but it is.
+        node.cdata? || (Nokogiri.jruby? && node.text? && node.parent.name == "style")
+      end
+
       def allowed_node?(node)
         @tags.include?(node.name)
       end
diff --git a/test/sanitizer_test.rb b/test/sanitizer_test.rb
index 5bf188e..69eee45 100644
--- a/test/sanitizer_test.rb
+++ b/test/sanitizer_test.rb
@@ -581,6 +581,18 @@ def test_exclude_node_type_comment
     assert_equal("<div>text</div><b>text</b>", safe_list_sanitize("<div>text</div><!-- comment --><b>text</b>"))
   end
 
+  [
+      ["<select><style><script>alert(1)</script></style></select>", ["select", "style"],      "script"],
+      ["<svg><style><script>alert(1)</script></style></svg>",       ["svg", "style"],         "script"],
+      ["<math><style><img src=x onerror=alert(1)></style></math>",  ["math", "style", "img"], "onerror"],
+      ["<svg><style><img src=x onerror=alert(1)></style></svg>",    ["svg", "style", "img"],  "onerror"],
+  ].each do |input, tags, should_not_include|
+    define_method "test_disallow_the_dangerous_safelist_combination_of_#{tags.join("_")}" do
+      sanitized = safe_list_sanitize(input, tags: tags)
+      refute_includes(sanitized, should_not_include)
+    end
+  end
+
```

### The resulting behavior

The resulting behavior for each of our attack inputs would be:

``` ruby
#! /usr/bin/env ruby

require "bundler/inline"

gemfile do
  source "https://rubygems.org"
  gem "rails-html-sanitizer", path: "."
end

require "rails-html-sanitizer"

def sanitize(input, tags)
  Rails::Html::WhiteListSanitizer.new.sanitize(input, tags: tags)
end

input, tags = "<select><style>div { background: red; }</style></select>", %w(select style)
sanitize(input, tags) # => "<select><style>div { background: red; }</style></select>"

input, tags = "<style>div > span { background: \"red\"; }</style>", %w(style)
sanitize(input, tags) # => "<style>div &gt; span { background: \"red\"; }</style>"

input, tags = "<select><style>div > span { background: \"red\"; }</style></select>", %w(select style)
sanitize(input, tags) # => "<select><style>div &gt; span { background: \"red\"; }</style></select>"

input, tags = "<select><style><script>alert(1)</script></style></select>", %w(select style)
sanitize(input, tags) # => "<select><style>alert(1)</style></select>"

input, tags = "<svg><style><script>alert(1);</script></style></svg>", %w(svg style)
sanitize(input, tags) # => "<svg><style>alert(1);</style></svg>"

input, tags = "<math><style><img src=x onerror=alert(1)></style></math>", %w(math style)
sanitize(input, tags) # => "<math><style></style></math>"

input, tags = "<math><style><img src=x onerror=alert(1)></style></math>", %w(math style img)
sanitize(input, tags) # => "<math><style><img src=\"x\"></style></math>"
```

For the safe usage case, the output would revert the behavior change introduced in v1.4.3:

```
input:    "<select><style>div { background: red; }</style></select>"
v1.4.2:   "<select><style>div { background: red; }</style></select>"
v1.4.3:   "<select>div { background: red; }</select>"
proposed: "<select><style>div { background: red; }</style></select>"
```

For `select` and `style` parents, the `script` tag has been removed by the act of recursively sanitizing. This is different both from the 1.4.2 (unsafe) and 1.4.3 (safe) behavior, but is still safe:

```
input:    "<select><style><script>alert(1)</script></style></select>"
v1.4.2:   "<select><style><script>alert(1)</script></style></select>"
v1.4.3:   "<select>&lt;script&gt;alert(1)&lt;/script&gt;</select>"
proposed: "<select><style>alert(1)</style></select>"
```

For the "foreign element" `script` case, the `script` tag has again been removed by recursively sanitizing, and r-h-s is finally safe from this attack.

```
input:    "<svg><style><script>alert(1);</script></style></svg>"
v1.4.2:   "<svg><style><script>alert(1);</script></style></svg>"
v1.4.3:   "<svg><style><script>alert(1);</script></style></svg>"
proposed: "<svg><style>alert(1);</style></svg>"
```

For the "foreign element" `img` case, the recursive scrubbing results in:

- the `img` tag being removed in the case where `img` is **disallowed**,
- the `onerror` attribute being removed in the case where the `img` tag is **allowed**.

... Disallowing the `img` tag:

```
input:    "<math><style><img src=x onerror=alert(1)></style></math>"
v1.4.2:   "<math><style><img src=x onerror=alert(1)></style></math>"
v1.4.3:   "<math><style><img src=x onerror=alert(1)></style></math>"
proposed: "<math><style></style></math>"
```

... Allowing the `img` tag:

```
input:    "<math><style><img src=x onerror=alert(1)></style></math>"
v1.4.2:   "<math><style><img src=x onerror=alert(1)></style></math>"
v1.4.3:   "<math><style><img src=x onerror=alert(1)></style></math>"
proposed: "<math><style><img src=\"x\"></style></math>"
```


### Backwards incompatibilities

For `style` tags with special characters **there will be a backwards-incompatible change**:

``` text
input:    "<style>div > span { background: \"red\"; }</style>"
v1.4.2:   "<style>div > span { background: \"red\"; }</style>"
v1.4.3:   "<style>div > span { background: \"red\"; }</style>"
proposed: "<style>div &gt; span { background: \"red\"; }</style>"
```

However, once Loofah upgrades to HTML5 (hopefully very soon), this goes away and the behavior from `<= 1.4.3` is restored. I don't think this is a reason not to choose this option.


### Other failing tests

The behavior difference, more generally, is introducing entity escaping on nested script tags, and I think this is acceptable.

The test changes necessary for this patch:

``` patch
diff --git a/test/sanitizer_test.rb b/test/sanitizer_test.rb
index d19063c..69eee45 100644
--- a/test/sanitizer_test.rb
+++ b/test/sanitizer_test.rb
@@ -14,11 +14,11 @@ def test_sanitizer_sanitize_raises_not_implemented_error
   end
 
   def test_sanitize_nested_script
-    assert_equal '&lt;script&gt;alert("XSS");&lt;/script&gt;', safe_list_sanitize('<script><script></script>alert("XSS");<script><</script>/</script><script>script></script>', tags: %w(em))
+    assert_equal 'alert("XSS");&amp;lt;/script&amp;gt;', safe_list_sanitize('<script><script></script>alert("XSS");<script><</script>/</script><script>script></script>', tags: %w(em))
   end
 
   def test_sanitize_nested_script_in_style
-    assert_equal '&lt;script&gt;alert("XSS");&lt;/script&gt;', safe_list_sanitize('<style><script></style>alert("XSS");<style><</style>/</style><style>script></style>', tags: %w(em))
+    assert_equal 'alert("XSS");&amp;lt;/script&amp;gt;', safe_list_sanitize('<style><script></style>alert("XSS");<style><</style>/</style><style>script></style>', tags: %w(em))
   end
 
   class XpathRemovalTestSanitizer < Rails::Html::Sanitizer
@@ -366,7 +366,7 @@ def test_should_sanitize_invalid_script_tag
   end
 
   def test_should_sanitize_script_tag_with_multiple_open_brackets
-    assert_sanitized %(<<SCRIPT>alert("XSS");//<</SCRIPT>), "&lt;alert(\"XSS\");//&lt;"
+    assert_sanitized %(<<SCRIPT>alert("XSS");//<</SCRIPT>), "&lt;alert(\"XSS\");//&amp;lt;"
     assert_sanitized %(<iframe src=http://ha.ckers.org/scriptlet.html\n<a), ""
   end
```


### What about recursion attacks?

Yeah, of course, we need to be sensitive to inputs that would trigger a `SystemStackError: stack level too deep` exception. You can blow the stack on my dev machine at about 685 recursive calls.

We could limit the depth of recursion to about 5. If r-h-s has to go deeper than that, we could assume it's an XSS attack and drop the node from the doc.

Here's a patch that restricts the recursion depth:

``` patch
diff --git a/lib/rails/html/scrubbers.rb b/lib/rails/html/scrubbers.rb
index 7f29c12..d37245a 100644
--- a/lib/rails/html/scrubbers.rb
+++ b/lib/rails/html/scrubbers.rb
@@ -45,11 +45,14 @@ module Html
     # See the documentation for +Nokogiri::XML::Node+ to understand what's possible
     # with nodes: https://nokogiri.org/rdoc/Nokogiri/XML/Node.html
     class PermitScrubber < Loofah::Scrubber
+      CDATA_SCRUB_RECURSION_MAX_DEPTH = 5
+
       attr_reader :tags, :attributes
 
       def initialize
         @direction = :bottom_up
         @tags, @attributes = nil, nil
+        @recursion_depth = 0
       end
 
       def tags=(tags)
@@ -61,8 +64,15 @@ def attributes=(attributes)
       end
 
       def scrub(node)
+        if @recursion_depth > CDATA_SCRUB_RECURSION_MAX_DEPTH
+          node.remove
+          return CONTINUE
+        end
+
         if needs_further_escaping(node)
+          @recursion_depth += 1
           safe_text = Loofah.fragment(node.text).scrub!(self).to_html
+          @recursion_depth -= 1
           safe_node = node.document.create_text_node(safe_text)
           node.replace safe_node
           return CONTINUE
diff --git a/test/sanitizer_test.rb b/test/sanitizer_test.rb
index 69eee45..5af00c7 100644
--- a/test/sanitizer_test.rb
+++ b/test/sanitizer_test.rb
@@ -593,6 +593,16 @@ def test_exclude_node_type_comment
     end
   end
 
+  def test_recursive_cdata_scrubbing
+    n = 100
+    input = "<div><select><style>" + ("<script>" * n) + "alert(1)" + ("</script>" * n) + "</style></select></div>"
+    tags = %w(div select style)
+
+    expected = "<div><select><style></style></select></div>"
+    actual = Rails::Html::WhiteListSanitizer.new.sanitize(input, tags: tags)
+    assert_equal(expected, actual)
+  end
+
 protected
 
   def xpath_sanitize(input, options = {})
```

### Hmm.

Yeah, after playing with this solution, I'm not wild about introducing recursion and incurring the overhead of multiple sanitization passes.


## Potential solution 2

I think there's a simpler fix: rollback [the RHS fix applied in c871aa4 / 45a5c10](https://github.com/rails/rails-html-sanitizer/commit/45a5c10) and escape the CDATA node using `CGI::Escape#escapeHTML`.


### The patch

Here's the patch:

``` patch
diff --git a/lib/rails/html/scrubbers.rb b/lib/rails/html/scrubbers.rb
index 09cfe95..e3001f9 100644
--- a/lib/rails/html/scrubbers.rb
+++ b/lib/rails/html/scrubbers.rb
@@ -61,9 +61,9 @@ def attributes=(attributes)
       end
 
       def scrub(node)
-        if node.cdata?
-          text = node.document.create_text_node node.text
-          node.replace text
+        if cdata_needs_escaping?(node)
+          replacement = cdata_escape(node)
+          node.replace(replacement)
           return CONTINUE
         end
         return CONTINUE if skip_node?(node)
@@ -77,6 +77,45 @@ def scrub(node)
 
       protected
 
+      def cdata_needs_escaping?(node)
+        # Nokogiri's HTML4 parser on JRuby doesn't flag the child of a `style` or `script` tag as cdata, but it acts that way
+        node.cdata? || (Nokogiri.jruby? && node.text? && (node.parent.name == "style" || node.parent.name == "script"))
+      end
+
+      def cdata_escape(node)
+        escaped_text = escape_tags(node.text)
+        if Nokogiri.jruby?
+          node.document.create_text_node(escaped_text)
+        else
+          node.document.create_cdata(escaped_text)
+        end
+      end
+
+      TABLE_FOR_ESCAPE_TAGS__ = {
+        '<' => '&lt;',
+        '>' => '&gt;',
+      }
+
+      def escape_tags(string)
+        # modified version of CGI.escapeHTML from ruby 3.1
+        enc = string.encoding
+        unless enc.ascii_compatible?
+          if enc.dummy?
+            origenc = enc
+            enc = Encoding::Converter.asciicompat_encoding(enc)
+            string = enc ? string.encode(enc) : string.b
+          end
+          table = Hash[TABLE_FOR_ESCAPE_HTML__.map {|pair|pair.map {|s|s.encode(enc)}}]
+          string = string.gsub(/#{"[<>]".encode(enc)}/, table)
+          string.encode!(origenc) if origenc
+          string
+        else
+          string = string.b
+          string.gsub!(/[<>]/, TABLE_FOR_ESCAPE_TAGS__)
+          string.force_encoding(enc)
+        end
+      end
+
       def allowed_node?(node)
         @tags.include?(node.name)
       end
diff --git a/test/sanitizer_test.rb b/test/sanitizer_test.rb
index 5bf188e..5e2bd83 100644
--- a/test/sanitizer_test.rb
+++ b/test/sanitizer_test.rb
@@ -581,6 +581,41 @@ def test_exclude_node_type_comment
     assert_equal("<div>text</div><b>text</b>", safe_list_sanitize("<div>text</div><!-- comment --><b>text</b>"))
   end
 
+  def test_safe_combination_of_select_and_style
+    input, tags = "<select><style>div { background: red; }</style></select>", ["select", "style"]
+    expected = input
+    actual = safe_list_sanitize(input, tags: tags)
+    assert_equal(expected, actual)
+  end
+
+  def test_unsafe_combination_of_select_and_style_with_script_payload
+    input, tags = "<select><style><script>alert(1)</script></style></select>", ["select", "style"]
+    expected = "<select><style>&lt;script&gt;alert(1)&lt;/script&gt;</style></select>"
+    actual = safe_list_sanitize(input, tags: tags)
+    assert_equal(expected, actual)
+  end
+
+  def test_unsafe_combination_of_svg_and_style_with_script_payload
+    input, tags = "<svg><style><script>alert(1)</script></style></svg>", ["svg", "style"]
+    expected = "<svg><style>&lt;script&gt;alert(1)&lt;/script&gt;</style></svg>"
+    actual = safe_list_sanitize(input, tags: tags)
+    assert_equal(expected, actual)
+  end
+
+  def test_unsafe_combination_of_math_and_style_with_img_payload
+    input, tags = "<math><style><img src=x onerror=alert(1)></style></math>", ["math", "style"]
+    expected = "<math><style>&lt;img src=x onerror=alert(1)&gt;</style></math>"
+    actual = safe_list_sanitize(input, tags: tags)
+    assert_equal(expected, actual)
+  end
+
+  def test_unsafe_combination_of_svg_and_style_with_img_payload
+    input, tags = "<svg><style><img src=x onerror=alert(1)></style></svg>", ["svg", "style"]
+    expected = "<svg><style>&lt;img src=x onerror=alert(1)&gt;</style></svg>"
+    actual = safe_list_sanitize(input, tags: tags)
+    assert_equal(expected, actual)
+  end
+
 protected
 
   def xpath_sanitize(input, options = {})
```

### The resulting behavior

The resulting behavior for each of our attack inputs would be:

``` ruby
#! /usr/bin/env ruby

require "bundler/inline"

gemfile do
  source "https://rubygems.org"
  gem "rails-html-sanitizer", path: "."
end

puts Rails::Html::Sanitizer::VERSION

require "rails-html-sanitizer"

def sanitize(input, tags)
  Rails::Html::WhiteListSanitizer.new.sanitize(input, tags: tags)
end

input, tags = "<select><style>div { background: red; }</style></select>", %w(select style)
sanitize(input, tags) # => "<select><style>div { background: red; }</style></select>"

input, tags = "<style>div > span { background: \"red\"; }</style>", %w(style)
sanitize(input, tags) # => "<style>div &gt; span { background: \"red\"; }</style>"

input, tags = "<select><style>div > span { background: \"red\"; }</style></select>", %w(select style)
sanitize(input, tags) # => "<select><style>div &gt; span { background: \"red\"; }</style></select>"

input, tags = "<select><style><script>alert(1)</script></style></select>", %w(select style)
sanitize(input, tags) # => "<select><style>&lt;script&gt;alert(1)&lt;/script&gt;</style></select>"

input, tags = "<svg><style><script>alert(1);</script></style></svg>", %w(svg style)
sanitize(input, tags) # => "<svg><style>&lt;script&gt;alert(1);&lt;/script&gt;</style></svg>"

input, tags = "<math><style><img src=x onerror=alert(1)></style></math>", %w(math style)
sanitize(input, tags) # => "<math><style>&lt;img src=x onerror=alert(1)&gt;</style></math>"

input, tags = "<math><style><img src=x onerror=alert(1)></style></math>", %w(math style img)
sanitize(input, tags) # => "<math><style>&lt;img src=x onerror=alert(1)&gt;</style></math>"
```

For the case of an actual `style` tag without special characters, this looks OK

```
input:    "<select><style>div { background: red; }</style></select>"
v1.4.2:   "<select><style>div { background: red; }</style></select>"
v1.4.3:   "<select>div { background: red; }</select>"
proposed: "<select><style>div { background: red; }</style></select>"
```

For `select` and `style` parents:

```
input:    "<select><style><script>alert(1)</script></style></select>"
v1.4.2:   "<select><style><script>alert(1)</script></style></select>"
v1.4.3:   "<select>&lt;script&gt;alert(1)&lt;/script&gt;</select>"
proposed: "<select><style>&lt;script&gt;alert(1)&lt;/script&gt;</style></select>"
```

For the "foreign element" `script` case:

```
input:    "<svg><style><script>alert(1);</script></style></svg>"
v1.4.2:   "<svg><style><script>alert(1);</script></style></svg>"
v1.4.3:   "<svg><style><script>alert(1);</script></style></svg>"
proposed: "<svg><style>&lt;script&gt;alert(1);&lt;/script&gt;</style></svg>"
```

For the "foreign element" `img` case (note that it makes no difference whether `img` is permitted):

```
input:    "<math><style><img src=x onerror=alert(1)></style></math>"
v1.4.2:   "<math><style><img src=x onerror=alert(1)></style></math>"
v1.4.3:   "<math><style><img src=x onerror=alert(1)></style></math>"
proposed: "<math><style>&lt;img src=x onerror=alert(1)&gt;</style></math>"
```

### Backwards incompatibilities

For `style` tags with special characters **there will be a backwards-incompatible change**:

``` text
input:    "<style>div > span { background: \"red\"; }</style>"
v1.4.2:   "<style>div > span { background: \"red\"; }</style>"
v1.4.3:   "<style>div > span { background: \"red\"; }</style>"
proposed: "<style>div &gt; span { background: \"red\"; }</style>"
```

However, once Loofah upgrades to HTML5 (hopefully very soon), this goes away and the behavior from `<= 1.4.3` is restored. I don't think this is a reason not to choose this option.


### Other failing tests

There are no other failing tests when introducing this patch, and no known backwards-incompatibilities.


### What happens when Loofah moves to HTML5 sanitization?

Here's the difference in behavior for these tests specifically ("expected" is HTML4, "actual" is HTML5)

``` text
  1) Failure:
SanitizersTest#test_unsafe_combination_of_svg_and_style_with_script_payload [/home/flavorjones/code/oss/rails-html-sanitizer/test/sanitizer_test.rb:602]:
--- expected
+++ actual
@@ -1 +1 @@
-"<svg><style>&lt;script&gt;alert(1)&lt;/script&gt;</style></svg>"
+"<svg><style>alert(1)</style></svg>"


  2) Failure:
SanitizersTest#test_unsafe_combination_of_math_and_style_with_img_payload [/home/flavorjones/code/oss/rails-html-sanitizer/test/sanitizer_test.rb:609]:
--- expected
+++ actual
@@ -1 +1 @@
-"<math><style>&lt;img src=x onerror=alert(1)&gt;</style></math>"
+"<math><style></style></math>"


  3) Failure:
SanitizersTest#test_unsafe_combination_of_select_and_style_with_script_payload [/home/flavorjones/code/oss/rails-html-sanitizer/test/sanitizer_test.rb:595]:
--- expected
+++ actual
@@ -1 +1 @@
-"<select><style>&lt;script&gt;alert(1)&lt;/script&gt;</style></select>"
+"<select>alert(1)</select>"


  4) Failure:
SanitizersTest#test_safe_combination_of_select_and_style [/home/flavorjones/code/oss/rails-html-sanitizer/test/sanitizer_test.rb:588]:
--- expected
+++ actual
@@ -1 +1 @@
-"<select><style>div { background: red; }</style></select>"
+"<select>div { background: red; }</select>"


  5) Failure:
SanitizersTest#test_unsafe_combination_of_svg_and_style_with_img_payload [/home/flavorjones/code/oss/rails-html-sanitizer/test/sanitizer_test.rb:616]:
--- expected
+++ actual
@@ -1 +1 @@
-"<svg><style>&lt;img src=x onerror=alert(1)&gt;</style></svg>"
+"<svg><style></style></svg>"
```

There are minor behavioral differences related to where the HTML5 spec allows some tags to exist, but everything is still _safe_. I'm OK with this.
