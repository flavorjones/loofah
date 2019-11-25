#! /usr/bin/env bash

set -e -x -u

pushd loofah

  # TODO: remove this once fefc629 (2019-11-25) is far enough in the past
  export RUBYOPT="--enable-frozen-string-literal --debug=frozen-string-literal"

  bundle install
  bundle exec rake test

popd
