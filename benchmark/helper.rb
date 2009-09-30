require 'rubygems'
require 'open-uri'
require 'hpricot'
require File.expand_path(File.dirname(__FILE__) + "/../lib/loofah")
require 'benchmark'
require "action_view"
require "action_controller/vendor/html-scanner"
require "sanitize"
require 'hitimes'

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
SNIPPET = "This is typical form field input in <b>length and content."

class Measure
  def initialize
    @first_time = true
  end

  def measure(name, ntimes)
    if @first_time
      printf "%-30s %7s  %8s\n", "", "total", "single"
      @first_time = false
    end
    timer = Hitimes::TimedMetric.new(name)
    timer.start
    ntimes.times do |j|
      yield
    end
    timer.stop
    printf "%-30s %7.3f (%.6f)\n", timer.name, timer.sum, timer.sum / ntimes
  end
end
