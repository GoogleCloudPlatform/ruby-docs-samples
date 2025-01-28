#!/bin/bash

set -e -u

# Choose the Ruby version to run
if [[ $KOKORO_RUBY_VERSION == "newest" ]]; then
  rbenv global "$NEWEST_RUBY_VERSION"
else
  rbenv global "$OLDEST_RUBY_VERSION"
fi
ruby --version

# Get secrets from GCS
source $KOKORO_GFILE_DIR/secrets.sh

# Move into the repo
cd github/ruby-docs-samples/

# Install tools
gem install --no-document toys

# Run the CI script
toys kokoro-ci -v
