#!/usr/bin/env ruby
require 'rubygems'
require 'open-uri'
require 'hpricot'
require File.expand_path(File.dirname(__FILE__) + "/lib/dryopteris")
require 'benchmark'
require "action_view"
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

uri = URI.parse('http://www.slashdot.com/')
content = uri.read
 
N = 100 #0
 
Benchmark.bm do |x|
  x.report('Dryopteris') do
    N.times do
      Dryopteris.sanitize(content)
    end
  end
 
  x.report('ActionView') do
    sanitizer = RailsSanitize.new
    
    N.times do
      sanitizer.sanitize(content)
    end
  end
  
  x.report('Sanitize') do
    N.times do
      Sanitize.clean(content, Sanitize::Config::RELAXED)
    end
  end
  
  x.report('HTML5lib') do
    sanitizer = HTML5libSanitize.new
    
    N.times do
      sanitizer.sanitize(content)
    end
  end
end
