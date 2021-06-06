require "./lib/loofah/version"

Gem::Specification.new do |spec|
  spec.name = "loofah"
  spec.version = Loofah::VERSION

  spec.authors = ["Mike Dalessio", "Bryan Helmkamp"]
  spec.email = ["mike.dalessio@gmail.com", "bryan@brynary.com"]

  spec.summary = "Loofah is a general library for manipulating and transforming HTML/XML documents and fragments, built on top of Nokogiri"
  spec.description = "Loofah is a general library for manipulating and transforming HTML/XML documents and fragments, built on top of Nokogiri.\n\nLoofah excels at HTML sanitization (XSS prevention). It includes some nice HTML sanitizers, which are based on HTML5lib's safelist, so it most likely won't make your codes less secure. (These statements have not been evaluated by Netexperts.)\n\nActiveRecord extensions for sanitization are available in the [`loofah-activerecord` gem](https://github.com/flavorjones/loofah-activerecord)."

  spec.homepage = "https://github.com/flavorjones/loofah"
  spec.license = "MIT"

  spec.metadata = {
    "homepage_uri" => spec.homepage,
    "source_code_uri" => spec.homepage,
    "bug_tracker_uri" => "#{spec.homepage}/issues",
    "changelog_uri" => "#{spec.homepage}/blob/main/CHANGELOG.md",
    "documentation_uri" => "https://www.rubydoc.info/gems/loofah/",
  }

  spec.require_paths = ["lib"]
  spec.files = Dir.chdir(File.expand_path("..", __FILE__)) do
    spec.files = %w[
      CHANGELOG.md
      MIT-LICENSE.txt
      README.md
      SECURITY.md
    ] + Dir.glob("lib/**/*.*")
  end

  spec.add_runtime_dependency("crass", ["~> 1.0.2"])
  spec.add_runtime_dependency("nokogiri", [">= 1.5.9"])

  spec.add_development_dependency("hoe-markdown", ["~> 1.3"])
  spec.add_development_dependency("json", ["~> 2.2"])
  spec.add_development_dependency("minitest", ["~> 5.14"])
  spec.add_development_dependency("rake", ["~> 13.0"])
  spec.add_development_dependency("rdoc", [">= 4.0", "< 7"])
  spec.add_development_dependency("rr", ["~> 1.2.0"])
  spec.add_development_dependency("rubocop", "~> 1.1")
end
