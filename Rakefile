# frozen_string_literal: true

require "hoe/markdown"
Hoe::Markdown::Standalone.new("loofah").define_markdown_tasks

require "rake/testtask"
Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = Dir["test/**/*.rb"]
  t.verbose = true
end

desc "generate safelists from W3C specifications"
task :generate_safelists do
  load "tasks/generate-safelists"
end

begin
  require "rubocop/rake_task"

  module RubocopHelper
    class << self
      def common_options(task)
        task.patterns += [
          "Gemfile",
          "Rakefile",
          "lib",
          "loofah.gemspec",
          "test",
        ]
      end
    end
  end

  RuboCop::RakeTask.new do |task|
    RubocopHelper.common_options(task)
  end

  desc("Generate the rubocop todo list")
  RuboCop::RakeTask.new("rubocop:todo") do |task|
    RubocopHelper.common_options(task)
    task.options << "--auto-gen-config"
    task.options << "--exclude-limit=50"
  end
  Rake::Task["rubocop:todo:autocorrect"].clear
  Rake::Task["rubocop:todo:autocorrect_all"].clear

  task(default: :rubocop)
rescue LoadError
  warn("NOTE: rubocop not available")
end

desc "Print out the files packaged in the gem"
task :debug_manifest do
  puts Bundler.load_gemspec("loofah.gemspec").files
end

task(default: :test)
