# -*- ruby -*-

require 'rubygems'
require 'rake'
require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.test_files = FileList['test/*.rb']
  t.verbose = true
  t.warning = true 
end
