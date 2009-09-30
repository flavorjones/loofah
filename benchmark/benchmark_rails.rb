#!/usr/bin/env ruby
require "#{File.dirname(__FILE__)}/helper.rb"

class MeasureRailsPerformance < Measure
  def bench(content, ntimes)
    sanitizer = RailsSanitize.new

    measure("Loofah::Rails.sanitize", ntimes) do
      Loofah::Rails.sanitize(content)    
    end

    measure('   ActionView sanitize', ntimes) do
      sanitizer.sanitize(content)
    end

    measure('Loofah::Rails.strip_tags', ntimes) do
      Loofah::Rails.strip_tags(content)
    end
    
    measure('   ActionView strip_tags', ntimes) do
      sanitizer.strip_tags(content)
    end

    puts
  end

  def test_set
    puts "Large document, #{BIG_FILE.length} bytes (x100)"
    bench BIG_FILE, 100
    puts "Small fragment, #{FRAGMENT.length} bytes (x1000)"
    bench FRAGMENT, 1000
    puts "Text snippet, #{SNIPPET.length} bytes (x10000)"
    bench SNIPPET, 10000
  end
end

puts "Nokogiri version:"
p Nokogiri::VERSION_INFO
puts "Loofah version:"
p Loofah::VERSION

bench = MeasureRailsPerformance.new
puts "---------- rehearsal ----------"
bench.test_set
puts "---------- realsies ----------"
bench.test_set

