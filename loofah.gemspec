# frozen_string_literal: true

require "./lib/loofah/version"

Gem::Specification.new do |spec|
  spec.name = "loofah"
  spec.version = Loofah::VERSION

  spec.authors = ["Mike Dalessio", "Bryan Helmkamp"]
  spec.email = ["mike.dalessio@gmail.com", "bryan@brynary.com"]

  spec.summary = <<~TEXT
    Loofah is a general library for manipulating and transforming HTML/XML documents and fragments,
    built on top of Nokogiri.
  TEXT
  spec.description = <<~TEXT
    Loofah is a general library for manipulating and transforming HTML/XML documents and fragments,
    built on top of Nokogiri.

    Loofah also includes some HTML sanitizers based on `html5lib`'s safelist, which are a specific
    application of the general transformation functionality.
  TEXT

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
  Dir.chdir(File.expand_path("..", __FILE__)) do
    spec.files = [
      "CHANGELOG.md",
      "MIT-LICENSE.txt",
      "README.md",
      "SECURITY.md",
    ] + Dir.glob("lib/**/*.*")
  end

  spec.required_ruby_version = ">= 2.5.0"

  spec.add_dependency("crass", ["~> 1.0.2"])
  spec.add_dependency("nokogiri", [">= 1.12.0"])
end
