#!/bin/bash

source $KOKORO_GFILE_DIR/secrets.sh

export GOOGLE_APPLICATION_CREDENTIALS=$KOKORO_GFILE_DIR/cloud-samples-tests-ruby-35fe8d65344c.json

cd github/ruby-docs-samples/storage
echo $GOOGLE_APPLICATION_CREDENTIALS
ls -l $GOOGLE_APPLICATION_CREDENTIALS
ls -l $KOKORO_GFILE_DIR

gem install bundle
bundle install
bundle exec rspec spec/quickstart_spec.rb

