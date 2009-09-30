#!/usr/bin/env ruby
require "#{File.dirname(__FILE__)}/helper.rb"

class MeasureBenchmark < Measure
  def bench(content, ntimes, fragment_p)
    sanitizer = RailsSanitize.new
    html5_sanitizer = HTML5libSanitize.new

    measure("Loofah", ntimes) do
      Loofah::Rails.sanitize(content)
    end

    measure("ActionView", ntimes) do
      sanitizer.sanitize(content)
    end

    measure("Sanitize", ntimes) do
      Sanitize.clean(content, Sanitize::Config::RELAXED)
    end

    measure("HTML5lib", ntimes) do
      html5_sanitizer.sanitize(content)
    end

    puts
  end

  def test_set
    puts "Large document, #{BIG_FILE.length} bytes (x100)"
    bench BIG_FILE, 100, false
    puts "Small fragment, #{FRAGMENT.length} bytes (x1000)"
    bench FRAGMENT, 1000, true
    puts "Text snippet, #{SNIPPET.length} bytes (x10000)"
    bench SNIPPET, 10000, true
  end
end

puts "Nokogiri version:"
p Nokogiri::VERSION_INFO
puts "Loofah version:"
p Loofah::VERSION

bench = MeasureBenchmark.new
puts "---------- rehearsal ----------"
bench.test_set
puts "---------- realsies ----------"
bench.test_set
