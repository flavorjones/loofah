# -*- encoding: utf-8 -*-
# stub: loofah 2.1.0.rc1.20150817193255 ruby lib

Gem::Specification.new do |s|
  s.name = "loofah"
  s.version = "2.1.0.rc1.20150817193255"

  s.required_rubygems_version = Gem::Requirement.new("> 1.3.1") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Mike Dalessio", "Bryan Helmkamp"]
  s.date = "2015-08-17"
  s.description = "Loofah is a general library for manipulating and transforming HTML/XML\ndocuments and fragments. It's built on top of Nokogiri and libxml2, so\nit's fast and has a nice API.\n\nLoofah excels at HTML sanitization (XSS prevention). It includes some\nnice HTML sanitizers, which are based on HTML5lib's whitelist, so it\nmost likely won't make your codes less secure. (These statements have\nnot been evaluated by Netexperts.)\n\nActiveRecord extensions for sanitization are available in the\n`loofah-activerecord` gem (see\nhttps://github.com/flavorjones/loofah-activerecord)."
  s.email = ["mike.dalessio@gmail.com", "bryan@brynary.com"]
  s.extra_rdoc_files = ["CHANGELOG.rdoc", "MIT-LICENSE.txt", "Manifest.txt", "README.rdoc", "CHANGELOG.rdoc", "README.rdoc"]
  s.files = [".gemtest", "CHANGELOG.rdoc", "Gemfile", "MIT-LICENSE.txt", "Manifest.txt", "README.rdoc", "Rakefile", "benchmark/benchmark.rb", "benchmark/fragment.html", "benchmark/helper.rb", "benchmark/www.slashdot.com.html", "lib/loofah.rb", "lib/loofah/elements.rb", "lib/loofah/helpers.rb", "lib/loofah/html/document.rb", "lib/loofah/html/document_fragment.rb", "lib/loofah/html5/scrub.rb", "lib/loofah/html5/whitelist.rb", "lib/loofah/instance_methods.rb", "lib/loofah/metahelpers.rb", "lib/loofah/scrubber.rb", "lib/loofah/scrubbers.rb", "lib/loofah/xml/document.rb", "lib/loofah/xml/document_fragment.rb", "test/assets/testdata_sanitizer_tests1.dat", "test/helper.rb", "test/html5/test_sanitizer.rb", "test/integration/test_ad_hoc.rb", "test/integration/test_helpers.rb", "test/integration/test_html.rb", "test/integration/test_scrubbers.rb", "test/integration/test_xml.rb", "test/unit/test_api.rb", "test/unit/test_encoding.rb", "test/unit/test_helpers.rb", "test/unit/test_scrubber.rb", "test/unit/test_scrubbers.rb"]
  s.homepage = "https://github.com/flavorjones/loofah"
  s.licenses = ["MIT"]
  s.rdoc_options = ["--main", "README.rdoc"]
  s.rubygems_version = "2.4.6"
  s.summary = "Loofah is a general library for manipulating and transforming HTML/XML documents and fragments"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<nokogiri>, [">= 1.6.6.4"])
      s.add_runtime_dependency(%q<crass>, ["~> 1.0.2"])
      s.add_development_dependency(%q<rdoc>, ["~> 4.0"])
      s.add_development_dependency(%q<rake>, [">= 0.8"])
      s.add_development_dependency(%q<minitest>, ["~> 2.2"])
      s.add_development_dependency(%q<rr>, ["~> 1.1.0"])
      s.add_development_dependency(%q<json>, [">= 0"])
      s.add_development_dependency(%q<hoe-gemspec>, [">= 0"])
      s.add_development_dependency(%q<hoe-debugging>, [">= 0"])
      s.add_development_dependency(%q<hoe-bundler>, [">= 0"])
      s.add_development_dependency(%q<hoe-git>, [">= 0"])
      s.add_development_dependency(%q<hoe>, ["~> 3.13"])
    else
      s.add_dependency(%q<nokogiri>, [">= 1.6.6.4"])
      s.add_dependency(%q<crass>, ["~> 1.0.2"])
      s.add_dependency(%q<rdoc>, ["~> 4.0"])
      s.add_dependency(%q<rake>, [">= 0.8"])
      s.add_dependency(%q<minitest>, ["~> 2.2"])
      s.add_dependency(%q<rr>, ["~> 1.1.0"])
      s.add_dependency(%q<json>, [">= 0"])
      s.add_dependency(%q<hoe-gemspec>, [">= 0"])
      s.add_dependency(%q<hoe-debugging>, [">= 0"])
      s.add_dependency(%q<hoe-bundler>, [">= 0"])
      s.add_dependency(%q<hoe-git>, [">= 0"])
      s.add_dependency(%q<hoe>, ["~> 3.13"])
    end
  else
    s.add_dependency(%q<nokogiri>, [">= 1.6.6.4"])
    s.add_dependency(%q<crass>, ["~> 1.0.2"])
    s.add_dependency(%q<rdoc>, ["~> 4.0"])
    s.add_dependency(%q<rake>, [">= 0.8"])
    s.add_dependency(%q<minitest>, ["~> 2.2"])
    s.add_dependency(%q<rr>, ["~> 1.1.0"])
    s.add_dependency(%q<json>, [">= 0"])
    s.add_dependency(%q<hoe-gemspec>, [">= 0"])
    s.add_dependency(%q<hoe-debugging>, [">= 0"])
    s.add_dependency(%q<hoe-bundler>, [">= 0"])
    s.add_dependency(%q<hoe-git>, [">= 0"])
    s.add_dependency(%q<hoe>, ["~> 3.13"])
  end
end
