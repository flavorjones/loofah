# -*- encoding: utf-8 -*-
# frozen_String_literal: true
# stub: loofah 2.5.0.20200405164942 ruby lib

Gem::Specification.new do |s|
  s.name = 'loofah'
  s.version = '2.5.0.20200405164942'
  if s.respond_to? :required_rubygems_version=
    s.required_rubygems_version = Gem::Requirement.new('>= 0')
  end
  if s.respond_to? :metadata=
    s.metadata = {
      'bug_tracker_uri' => 'https://github.com/flavorjones/loofah/issues',
      'changelog_uri' => 'https://github.com/flavorjones/loofah/master/CHANGELOG.md',
      'documentation_uri' => 'https://www.rubydoc.info/gems/loofah/',
      'homepage_uri' => 'https://github.com/flavorjones/loofah',
      'source_code_uri' => 'https://github.com/flavorjones/loofah'
    }
  end
  s.require_paths = ['lib']
  s.authors = ['Mike Dalessio', 'Bryan Helmkamp']
  s.date = '2020-04-05'
  s.description = <<-DESC
  Loofah is a general library for manipulating and transforming
  HTML/XML documents and fragments, built on top of Nokogiri.

  Loofah excels at HTML sanitization (XSS prevention). It includes
  some nice HTML sanitizers, which are based on HTML5lib's safelist,
  so it most likely won't make your codes less secure.
  (These statements have not been evaluated by Netexperts.)

  ActiveRecord extensions for sanitization are available in the
  [`loofah-activerecord` gem](https://github.com/flavorjones/loofah-activerecord).
  DESC

  s.email = ['mike.dalessio@gmail.com', 'bryan@brynary.com']
  s.extra_rdoc_files = [
    'CHANGELOG.md',
    'MIT-LICENSE.txt',
    'Manifest.txt',
    'README.md',
    'SECURITY.md'
  ]
  s.files = [
    'CHANGELOG.md',
    'Gemfile',
    'MIT-LICENSE.txt',
    'Manifest.txt',
    'README.md',
    'Rakefile',
    'SECURITY.md',
    'benchmark/benchmark.rb',
    'benchmark/fragment.html',
    'benchmark/helper.rb',
    'benchmark/www.slashdot.com.html',
    'lib/loofah.rb',
    'lib/loofah/elements.rb',
    'lib/loofah/helpers.rb',
    'lib/loofah/html/document.rb',
    'lib/loofah/html/document_fragment.rb',
    'lib/loofah/html5/libxml2_workarounds.rb',
    'lib/loofah/html5/safelist.rb',
    'lib/loofah/html5/scrub.rb',
    'lib/loofah/instance_methods.rb',
    'lib/loofah/metahelpers.rb',
    'lib/loofah/scrubber.rb',
    'lib/loofah/scrubbers.rb',
    'lib/loofah/xml/document.rb',
    'lib/loofah/xml/document_fragment.rb'
  ]
  s.homepage = 'https://github.com/flavorjones/loofah'
  s.licenses = ['MIT']
  s.rdoc_options = ['--main', 'README.md']
  s.rubygems_version = '3.1.2'
  s.summary = <<-SUM
  Loofah is a general library for manipulating and transforming HTML/XML
  documents and fragments, built on top of Nokogiri
  SUM

  s.specification_version = 4 if s.respond_to? :specification_version

  if s.respond_to? :add_runtime_dependency
    s.add_development_dependency('concourse', ['>= 0.26.0'])
    s.add_runtime_dependency('crass', ['~> 1.0.2'])
    s.add_development_dependency('hoe', ['~> 3.22'])
    s.add_development_dependency('hoe-bundler', ['~> 1.5'])
    s.add_development_dependency('hoe-debugging', ['~> 2.0'])
    s.add_development_dependency('hoe-gemspec', ['~> 1.0'])
    s.add_development_dependency('hoe-git', ['~> 1.6'])
    s.add_development_dependency('json', ['~> 2.2.0'])
    s.add_development_dependency('minitest', ['~> 2.2'])
    s.add_runtime_dependency('nokogiri', ['>= 1.5.9'])
    s.add_development_dependency('rake', ['~> 12.3'])
    s.add_development_dependency('rdoc', ['>= 4.0', '< 7'])
    s.add_development_dependency('rr', ['~> 1.2.0'])
    s.add_development_dependency('rubocop', ['>= 0.76.0'])
  else
    s.add_dependency('concourse', ['>= 0.26.0'])
    s.add_dependency('crass', ['~> 1.0.2'])
    s.add_dependency('hoe', ['~> 3.22'])
    s.add_dependency('hoe-bundler', ['~> 1.5'])
    s.add_dependency('hoe-debugging', ['~> 2.0'])
    s.add_dependency('hoe-gemspec', ['~> 1.0'])
    s.add_dependency('hoe-git', ['~> 1.6'])
    s.add_dependency('json', ['~> 2.2.0'])
    s.add_dependency('minitest', ['~> 2.2'])
    s.add_dependency('nokogiri', ['>= 1.5.9'])
    s.add_dependency('rake', ['~> 12.3'])
    s.add_dependency('rdoc', ['>= 4.0', '< 7'])
    s.add_dependency('rr', ['~> 1.2.0'])
    s.add_dependency('rubocop', ['>= 0.76.0'])
  end
end
