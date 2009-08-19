require 'rubygems'
require 'open-uri'
require 'hpricot'
require File.expand_path(File.dirname(__FILE__) + "/../lib/loofah")
require 'benchmark'
require "action_view"
require "action_controller/vendor/html-scanner"
require "sanitize"

class RailsSanitize
  include ActionView::Helpers::SanitizeHelper
  extend ActionView::Helpers::SanitizeHelper::ClassMethods
end

class HTML5libSanitize
  require 'html5/html5parser'
  require 'html5/liberalxmlparser'
  require 'html5/treewalkers'
  require 'html5/treebuilders'
  require 'html5/serializer'
  require 'html5/sanitizer'

  include HTML5

  def sanitize(html)
    HTMLParser.parse_fragment(html, {
      :tokenizer  => HTMLSanitizer,
      :encoding   => 'utf-8',
      :tree       => TreeBuilders::REXML::TreeBuilder
    }).to_s
  end
end
