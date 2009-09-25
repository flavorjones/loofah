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

if File.exist?("rails_test/Rakefile")
  load "rails_test/Rakefile"
else
  task :test do
    puts "----------"
    puts "-- NOTE: An additional Rails regression test suite is available in source repository"
    puts "----------"
  end
end

task :redocs => :fix_css
task :fix_css do
  better_css = <<-EOT
.method-description pre {
  margin: 1em 0 ;
}

.method-description ul {
  padding: .5em 0 .5em 2em ;
}

.method-description {
  padding-top: .5em ;
}
EOT
  puts "* fixing css"
  File.open("doc/rdoc.css", "a") { |f| f.write better_css }
end

