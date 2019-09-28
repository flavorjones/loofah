#! /usr/bin/env bash

set -e -x -u

pushd loofah

  bundle install
  bundle exec rake test

popd
