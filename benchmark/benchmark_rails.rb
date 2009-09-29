#!/usr/bin/env ruby
require "#{File.dirname(__FILE__)}/helper.rb"

FRAGMENT = File.read(File.join(File.dirname(__FILE__), "fragment.html"))
SNIPPET = "This is typical form field input in <b>length and content."

def bench(content, ntimes)
  Benchmark.bm(25) do |x|
    x.report('Loofah::Rails.sanitize') do
      ntimes.times do
        Loofah::Rails.sanitize(content)
      end
    end
    
    x.report('ActionView sanitize') do
      sanitizer = RailsSanitize.new
      
      ntimes.times do
        sanitizer.sanitize(content)
      end
    end

    x.report('Loofah::Rails.strip_tags') do
      ntimes.times do
        Loofah::Rails.strip_tags(content)
      end
    end
    
    x.report('ActionView strip_tags') do
      sanitizer = RailsSanitize.new
      
      ntimes.times do
        sanitizer.strip_tags(content)
      end
    end
  end
end

puts "Small fragment, #{FRAGMENT.length} bytes (x1000)"
bench FRAGMENT, 1000
puts "Text snippet, #{SNIPPET.length} bytes (x10000)"
bench SNIPPET, 10000
