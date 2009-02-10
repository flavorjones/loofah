# -*- ruby -*-

require 'rubygems'
begin
  require 'jeweler'
  Jeweler::Tasks.new do |s|
    s.name = "dryopteris"
    s.summary = "HTML sanitization using Nokogiri"
    s.email = "bryan@brynary.com"
    s.homepage = "http://github.com/brynary/dryopteris/tree/master"
    s.description = "Dryopteris erythrosora is the Japanese Shield Fern. It also can be used to sanitize HTML to help prevent XSS attacks."
    s.authors = ["Bryan Helmkamp", "Mike Dalessio"]
  end
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end


require 'rake'
require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.test_files = FileList['test/*.rb']
  t.verbose = true
  t.warning = true 
end

task :default => :test

