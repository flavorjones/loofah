#!/usr/bin/env ruby
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

BIG_FILE = File.read(File.join(File.dirname(__FILE__), "www.slashdot.com.html"))
FRAGMENT = File.read(File.join(File.dirname(__FILE__), "fragment.html"))

def bench(content, ntimes, fragment_p)
  Benchmark.bm(15) do |x|
    x.report('Loofah') do
      ntimes.times do
        if fragment_p
          Loofah.scrub_fragment(content, :escape)
        else
          Loofah.scrub_document(content, :escape)
        end
      end
    end
    
    x.report('ActionView') do
      sanitizer = RailsSanitize.new
      
      ntimes.times do
        sanitizer.sanitize(content)
      end
    end
    
    x.report('Sanitize') do
      ntimes.times do
        Sanitize.clean(content, Sanitize::Config::RELAXED)
      end
    end
    
    x.report('HTML5lib') do
      sanitizer = HTML5libSanitize.new
      
      ntimes.times do
        sanitizer.sanitize(content)
      end
    end
  end
end

puts "Large document (x100)  =========="
bench BIG_FILE, 100, false
puts "Small fragment (x1000) =========="
bench FRAGMENT, 1000, true
 
