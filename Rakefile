require 'rubygems'
gem 'hoe', '>= 2.3.0'
require 'hoe'

Hoe.plugin :git

Hoe.spec "loofah" do
  developer "Mike Dalessio", "mike.dalessio@gmail.com"
  developer "Bryan Helmkamp", "bryan@brynary.com"

  self.extra_rdoc_files = FileList["*.rdoc"]
  self.history_file     = "CHANGELOG.rdoc"
  self.readme_file      = "README.rdoc"

  extra_deps << ["nokogiri", ">= 1.3.3"]

  # note: .hoerc should have the following line to omit rails tests and tmp
  #   exclude: !ruby/regexp /\/tmp\/|\/rails_tests\/|CVS|TAGS|\.(svn|git|DS_Store)/
end

task :fake_install => [:gem] do
  FileUtils.mkdir_p "tmp"
  system "mkdir -p tmp"
  system "gem install pkg/loofah-0.2.2.gem -i tmp --no-ri --no-rdoc"
  system "chmod -R go-w tmp"
end

def run(cmd)
  puts "* running: #{cmd}"
  system cmd
  raise "ERROR running command" unless $? == 0
end

task :rails_test => [:fake_install] do
  Dir.chdir("rails_tests") do
    Dir["rails-*"].sort.each do |rails|
      Dir.chdir rails do
        ENV['GEM_HOME'] = File.expand_path("../../tmp")
        FileUtils.rm Dir['db/*sqlite3']
        run "touch db/development.sqlite3" # db:create doesn't exist before rails 2.0
        run "rake db:migrate db:test:prepare test"
      end
    end
  end
end
