#! /usr/bin/env bash

set -e -x -u

pushd loofah

  bundle install

  # TODO: remove this once fefc629 (2019-11-25) is far enough in the past
  export RUBYOPT="--enable-frozen-string-literal --debug=frozen-string-literal"

  bundle exec rake

popd
