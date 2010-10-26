# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{loofah}
  s.version = "1.0.0.beta.1.20101025234603"

  s.required_rubygems_version = Gem::Requirement.new("> 1.3.1") if s.respond_to? :required_rubygems_version=
  s.authors = ["Mike Dalessio", "Bryan Helmkamp"]
  s.date = %q{2010-10-25}
  s.description = %q{Loofah is a general library for manipulating and transforming HTML/XML
documents and fragments. It's built on top of Nokogiri and libxml2, so
it's fast and has a nice API.

Loofah excels at HTML sanitization (XSS prevention). It includes some
nice HTML sanitizers, which are based on HTML5lib's whitelist, so it
most likely won't make your codes less secure. (These statements have
not been evaluated by Netexperts.)

ActiveRecord extensions for sanitization are available in the
`loofah-activerecord` gem (see
http://github.com/flavorjones/loofah-activerecord).}
  s.email = ["mike.dalessio@gmail.com", "bryan@brynary.com"]
  s.extra_rdoc_files = ["MIT-LICENSE.txt", "Manifest.txt", "CHANGELOG.rdoc", "README.rdoc"]
  s.files = ["CHANGELOG.rdoc", "MIT-LICENSE.txt", "Manifest.txt", "README.rdoc", "Rakefile", "benchmark/benchmark.rb", "benchmark/fragment.html", "benchmark/helper.rb", "benchmark/www.slashdot.com.html", "lib/loofah.rb", "lib/loofah/elements.rb", "lib/loofah/helpers.rb", "lib/loofah/html/document.rb", "lib/loofah/html/document_fragment.rb", "lib/loofah/html5/scrub.rb", "lib/loofah/html5/whitelist.rb", "lib/loofah/instance_methods.rb", "lib/loofah/metahelpers.rb", "lib/loofah/scrubber.rb", "lib/loofah/scrubbers.rb", "lib/loofah/xml/document.rb", "lib/loofah/xml/document_fragment.rb", "test/helper.rb", "test/html5/test_sanitizer.rb", "test/integration/test_ad_hoc.rb", "test/integration/test_helpers.rb", "test/integration/test_html.rb", "test/integration/test_scrubbers.rb", "test/integration/test_xml.rb", "test/unit/test_api.rb", "test/unit/test_helpers.rb", "test/unit/test_scrubber.rb", "test/unit/test_scrubbers.rb"]
  s.homepage = %q{http://github.com/flavorjones/loofah}
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{loofah}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Loofah is a general library for manipulating and transforming HTML/XML documents and fragments}
  s.test_files = ["test/integration/test_html.rb", "test/integration/test_ad_hoc.rb", "test/integration/test_helpers.rb", "test/integration/test_scrubbers.rb", "test/integration/test_xml.rb", "test/html5/test_sanitizer.rb", "test/unit/test_scrubber.rb", "test/unit/test_helpers.rb", "test/unit/test_scrubbers.rb", "test/unit/test_api.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<nokogiri>, [">= 1.3.3"])
      s.add_development_dependency(%q<rubyforge>, [">= 2.0.4"])
      s.add_development_dependency(%q<mocha>, [">= 0.9"])
      s.add_development_dependency(%q<shoulda>, [">= 2.10"])
      s.add_development_dependency(%q<rake>, [">= 0.8"])
      s.add_development_dependency(%q<hoe>, [">= 2.6.1"])
    else
      s.add_dependency(%q<nokogiri>, [">= 1.3.3"])
      s.add_dependency(%q<rubyforge>, [">= 2.0.4"])
      s.add_dependency(%q<mocha>, [">= 0.9"])
      s.add_dependency(%q<shoulda>, [">= 2.10"])
      s.add_dependency(%q<rake>, [">= 0.8"])
      s.add_dependency(%q<hoe>, [">= 2.6.1"])
    end
  else
    s.add_dependency(%q<nokogiri>, [">= 1.3.3"])
    s.add_dependency(%q<rubyforge>, [">= 2.0.4"])
    s.add_dependency(%q<mocha>, [">= 0.9"])
    s.add_dependency(%q<shoulda>, [">= 2.10"])
    s.add_dependency(%q<rake>, [">= 0.8"])
    s.add_dependency(%q<hoe>, [">= 2.6.1"])
  end
end
