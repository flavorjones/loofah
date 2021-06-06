require "hoe/markdown"
Hoe::Markdown::Standalone.new("loofah").define_markdown_tasks

require "rake/testtask"
Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = Dir["test/**/*.rb"]
end

desc "generate safelists from W3C specifications"
task :generate_safelists do
  load "tasks/generate-safelists"
end

task :rubocop => [:rubocop_security, :rubocop_frozen_string_literals]
task :rubocop_security do
  sh "rubocop lib --only Security"
end
task :rubocop_frozen_string_literals do
  sh "rubocop lib --auto-correct --only Style/FrozenStringLiteralComment"
end

task :default => [:rubocop, :test]

task :debug_manifest do
  spec = eval(File.read("loofah.gemspec"))
  puts spec.files
end
