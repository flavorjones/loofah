#! /usr/bin/env bash

set -e -x -u

pushd loofah

  export RUBYOPT="--enable-frozen-string-literal --debug=frozen-string-literal"
  bundle install
  bundle exec rake test

popd
