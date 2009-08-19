#!/usr/bin/env ruby
require "#{File.dirname(__FILE__)}/helper.rb"

BIG_FILE = File.read(File.join(File.dirname(__FILE__), "www.slashdot.com.html"))
FRAGMENT = File.read(File.join(File.dirname(__FILE__), "fragment.html"))
SNIPPET = "This is typical form field input in <b>length and content."

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

puts "Large document, #{BIG_FILE.length} bytes (x100)"
bench BIG_FILE, 100, false
puts "Small fragment, #{FRAGMENT.length} bytes (x1000)"
bench FRAGMENT, 1000, true
puts "Text snippet, #{SNIPPET.length} bytes (x10000)"
bench SNIPPET, 10000, true
