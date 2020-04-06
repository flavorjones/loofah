# -*- encoding: utf-8 -*-
# stub: loofah 2.5.0.20200405164942 ruby lib

Gem::Specification.new do |s|
  s.name = "loofah".freeze
  s.version = "2.5.0.20200405164942"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "bug_tracker_uri" => "https://github.com/flavorjones/loofah/issues", "changelog_uri" => "https://github.com/flavorjones/loofah/blob/master/CHANGELOG.md", "documentation_uri" => "https://www.rubydoc.info/gems/loofah/", "homepage_uri" => "https://github.com/flavorjones/loofah", "source_code_uri" => "https://github.com/flavorjones/loofah" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Mike Dalessio".freeze, "Bryan Helmkamp".freeze]
  s.date = "2020-04-05"
  s.description = "Loofah is a general library for manipulating and transforming HTML/XML documents and fragments, built on top of Nokogiri.\n\nLoofah excels at HTML sanitization (XSS prevention). It includes some nice HTML sanitizers, which are based on HTML5lib's safelist, so it most likely won't make your codes less secure. (These statements have not been evaluated by Netexperts.)\n\nActiveRecord extensions for sanitization are available in the [`loofah-activerecord` gem](https://github.com/flavorjones/loofah-activerecord).".freeze
  s.email = ["mike.dalessio@gmail.com".freeze, "bryan@brynary.com".freeze]
  s.extra_rdoc_files = ["CHANGELOG.md".freeze, "MIT-LICENSE.txt".freeze, "Manifest.txt".freeze, "README.md".freeze, "SECURITY.md".freeze]
  s.files = ["CHANGELOG.md".freeze, "Gemfile".freeze, "MIT-LICENSE.txt".freeze, "Manifest.txt".freeze, "README.md".freeze, "Rakefile".freeze, "SECURITY.md".freeze, "benchmark/benchmark.rb".freeze, "benchmark/fragment.html".freeze, "benchmark/helper.rb".freeze, "benchmark/www.slashdot.com.html".freeze, "lib/loofah.rb".freeze, "lib/loofah/elements.rb".freeze, "lib/loofah/helpers.rb".freeze, "lib/loofah/html/document.rb".freeze, "lib/loofah/html/document_fragment.rb".freeze, "lib/loofah/html5/libxml2_workarounds.rb".freeze, "lib/loofah/html5/safelist.rb".freeze, "lib/loofah/html5/scrub.rb".freeze, "lib/loofah/instance_methods.rb".freeze, "lib/loofah/metahelpers.rb".freeze, "lib/loofah/scrubber.rb".freeze, "lib/loofah/scrubbers.rb".freeze, "lib/loofah/xml/document.rb".freeze, "lib/loofah/xml/document_fragment.rb".freeze]
  s.homepage = "https://github.com/flavorjones/loofah".freeze
  s.licenses = ["MIT".freeze]
  s.rdoc_options = ["--main".freeze, "README.md".freeze]
  s.rubygems_version = "3.1.2".freeze
  s.summary = "Loofah is a general library for manipulating and transforming HTML/XML documents and fragments, built on top of Nokogiri".freeze

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<nokogiri>.freeze, [">= 1.5.9"])
    s.add_runtime_dependency(%q<crass>.freeze, ["~> 1.0.2"])
    s.add_development_dependency(%q<rake>.freeze, ["~> 12.3"])
    s.add_development_dependency(%q<minitest>.freeze, ["~> 2.2"])
    s.add_development_dependency(%q<rr>.freeze, ["~> 1.2.0"])
    s.add_development_dependency(%q<json>.freeze, ["~> 2.2.0"])
    s.add_development_dependency(%q<hoe-gemspec>.freeze, ["~> 1.0"])
    s.add_development_dependency(%q<hoe-debugging>.freeze, ["~> 2.0"])
    s.add_development_dependency(%q<hoe-bundler>.freeze, ["~> 1.5"])
    s.add_development_dependency(%q<hoe-git>.freeze, ["~> 1.6"])
    s.add_development_dependency(%q<concourse>.freeze, [">= 0.26.0"])
    s.add_development_dependency(%q<rubocop>.freeze, [">= 0.76.0"])
    s.add_development_dependency(%q<rdoc>.freeze, [">= 4.0", "< 7"])
    s.add_development_dependency(%q<hoe>.freeze, ["~> 3.22"])
  else
    s.add_dependency(%q<nokogiri>.freeze, [">= 1.5.9"])
    s.add_dependency(%q<crass>.freeze, ["~> 1.0.2"])
    s.add_dependency(%q<rake>.freeze, ["~> 12.3"])
    s.add_dependency(%q<minitest>.freeze, ["~> 2.2"])
    s.add_dependency(%q<rr>.freeze, ["~> 1.2.0"])
    s.add_dependency(%q<json>.freeze, ["~> 2.2.0"])
    s.add_dependency(%q<hoe-gemspec>.freeze, ["~> 1.0"])
    s.add_dependency(%q<hoe-debugging>.freeze, ["~> 2.0"])
    s.add_dependency(%q<hoe-bundler>.freeze, ["~> 1.5"])
    s.add_dependency(%q<hoe-git>.freeze, ["~> 1.6"])
    s.add_dependency(%q<concourse>.freeze, [">= 0.26.0"])
    s.add_dependency(%q<rubocop>.freeze, [">= 0.76.0"])
    s.add_dependency(%q<rdoc>.freeze, [">= 4.0", "< 7"])
    s.add_dependency(%q<hoe>.freeze, ["~> 3.22"])
  end
end
