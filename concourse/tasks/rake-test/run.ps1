. "c:\var\vcap\packages\windows-ruby-dev-tools\prelude.ps1"

push-location loofah

    system-cmd "gem install bundler"
    system-cmd "bundle install"
    system-cmd "bundle exec rake test"

pop-location
