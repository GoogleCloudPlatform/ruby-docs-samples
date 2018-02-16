#!/bin/bash

source $KOKORO_GFILE_DIR/secrets.sh

export GOOGLE_APPLICATION_CREDENTIALS=$KOKORO_GFILE_DIR/client_secret_978467553869-f5a190d93kfbv0req8ejnpkj41quuncd.apps.googleusercontent.com.json

cd github/ruby-docs-samples/storage

gem install bundle
bundle install
bundle exec rspec spec/quickstart_spec.rb

