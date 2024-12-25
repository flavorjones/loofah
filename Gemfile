# frozen_string_literal: true

source "https://rubygems.org/"

gemspec

group :development do
  gem("hoe-markdown", ["~> 1.5", ">= 1.5.1"])
  gem("json", ["~> 2.2"])
  gem("minitest", ["~> 5.14"])
  gem("rake", ["~> 13.0"])
  gem("rdoc", [">= 4.0", "< 7"])
  gem("jar-dependencies", "0.4.1") if RUBY_PLATFORM == "java" # https://github.com/jruby/jruby/issues/7262

  if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new("3.0.0")
    gem("rubocop", "1.65.0")
    gem("rubocop-minitest", "0.29.0")
    gem("rubocop-packaging", "0.5.2")
    gem("rubocop-performance", "1.16.0")
    gem("rubocop-rake", "0.6.0")
    gem("rubocop-shopify", "2.12.0")
  end
end
