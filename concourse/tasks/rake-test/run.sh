#! /usr/bin/env bash

set -e -x -u

VERSION_INFO=$(ruby -v)
RUBY_ENGINE=$(cut -d" " -f1 <<< "${VERSION_INFO}")
RUBY_VERSION=$(cut -d" " -f2 <<< "${VERSION_INFO}")

APT_UPDATED=false

function rbx-engine {
  if [[ $RUBY_ENGINE == "rubinius" ]] ; then
    return 0
  fi
  return 1
}

pushd loofah

  if rbx-engine ; then
    apt-get update
    apt-get install -y ca-certificates gcc pkg-config libxml2-dev libxslt-dev
    echo "gem 'racc'" >> Gemfile # https://github.com/rubinius/rubinius/issues/2632
  fi

  bundle install
  bundle exec rake test

popd
