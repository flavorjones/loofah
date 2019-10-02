# -*- encoding: utf-8 -*-
# stub: loofah 2.3.0.20190928134624 ruby lib

Gem::Specification.new do |s|
  s.name = "loofah".freeze
  s.version = "2.3.0.20190928134624"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Mike Dalessio".freeze, "Bryan Helmkamp".freeze]
  s.date = "2019-09-28"
  s.description = "Loofah is a general library for manipulating and transforming HTML/XML documents and fragments, built on top of Nokogiri.\n\nLoofah excels at HTML sanitization (XSS prevention). It includes some nice HTML sanitizers, which are based on HTML5lib's safelist, so it most likely won't make your codes less secure. (These statements have not been evaluated by Netexperts.)\n\nActiveRecord extensions for sanitization are available in the [`loofah-activerecord` gem](https://github.com/flavorjones/loofah-activerecord).".freeze
  s.email = ["mike.dalessio@gmail.com".freeze, "bryan@brynary.com".freeze]
  s.extra_rdoc_files = ["CHANGELOG.md".freeze, "MIT-LICENSE.txt".freeze, "Manifest.txt".freeze, "README.md".freeze, "SECURITY.md".freeze, "CHANGELOG.md".freeze, "README.md".freeze, "SECURITY.md".freeze]
  s.files = [".gemtest".freeze, "CHANGELOG.md".freeze, "Gemfile".freeze, "MIT-LICENSE.txt".freeze, "Manifest.txt".freeze, "README.md".freeze, "Rakefile".freeze, "SECURITY.md".freeze, "benchmark/benchmark.rb".freeze, "benchmark/fragment.html".freeze, "benchmark/helper.rb".freeze, "benchmark/www.slashdot.com.html".freeze, "lib/loofah.rb".freeze, "lib/loofah/elements.rb".freeze, "lib/loofah/helpers.rb".freeze, "lib/loofah/html/document.rb".freeze, "lib/loofah/html/document_fragment.rb".freeze, "lib/loofah/html5/libxml2_workarounds.rb".freeze, "lib/loofah/html5/safelist.rb".freeze, "lib/loofah/html5/scrub.rb".freeze, "lib/loofah/instance_methods.rb".freeze, "lib/loofah/metahelpers.rb".freeze, "lib/loofah/scrubber.rb".freeze, "lib/loofah/scrubbers.rb".freeze, "lib/loofah/xml/document.rb".freeze, "lib/loofah/xml/document_fragment.rb".freeze, "test/assets/msword.html".freeze, "test/assets/testdata_sanitizer_tests1.dat".freeze, "test/helper.rb".freeze, "test/html5/test_sanitizer.rb".freeze, "test/html5/test_scrub.rb".freeze, "test/integration/test_ad_hoc.rb".freeze, "test/integration/test_helpers.rb".freeze, "test/integration/test_html.rb".freeze, "test/integration/test_scrubbers.rb".freeze, "test/integration/test_xml.rb".freeze, "test/unit/test_api.rb".freeze, "test/unit/test_encoding.rb".freeze, "test/unit/test_helpers.rb".freeze, "test/unit/test_scrubber.rb".freeze, "test/unit/test_scrubbers.rb".freeze]
  s.homepage = "https://github.com/flavorjones/loofah".freeze
  s.licenses = ["MIT".freeze]
  s.rdoc_options = ["--main".freeze, "README.md".freeze]
  s.rubygems_version = "3.0.3".freeze
  s.summary = "Loofah is a general library for manipulating and transforming HTML/XML documents and fragments, built on top of Nokogiri".freeze

  s.metadata = {
    'bug_tracker_uri'   => 'https://github.com/flavorjones/loofah/issues',
    'changelog_uri'     => "https://github.com/flavorjones/loofah/blob/v#{s.version}/CHANGELOG.md",
    'documentation_uri' => "https://www.rubydoc.info/gems/loofah/#{s.version}",
    'mailing_list_uri'  => 'https://groups.google.com/forum/#!forum/loofah-talk',
    'source_code_uri'   => "https://github.com/flavorjones/loofah/tree/v#{s.version}",
    'wiki_uri'          => 'https://github.com/flavorjones/loofah/wiki'
  }

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
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
      s.add_development_dependency(%q<rdoc>.freeze, [">= 4.0", "< 7"])
      s.add_development_dependency(%q<hoe>.freeze, ["~> 3.18"])
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
      s.add_dependency(%q<rdoc>.freeze, [">= 4.0", "< 7"])
      s.add_dependency(%q<hoe>.freeze, ["~> 3.18"])
    end
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
    s.add_dependency(%q<rdoc>.freeze, [">= 4.0", "< 7"])
    s.add_dependency(%q<hoe>.freeze, ["~> 3.18"])
  end
end
