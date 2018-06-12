#!/bin/bash

set -x -e -u -o pipefail

# Temporary workaround for a known bundler+docker issue:
# https://github.com/bundler/bundler/issues/6154
export BUNDLE_GEMFILE=

for required_variable in                   \
  GOOGLE_CLOUD_PROJECT                     \
  GOOGLE_APPLICATION_CREDENTIALS           \
  GOOGLE_CLOUD_STORAGE_BUCKET              \
  ALTERNATE_GOOGLE_CLOUD_STORAGE_BUCKET    \
; do
  if [[ -z "${!required_variable}" ]]; then
    echo "Must set $required_variable"
    exit 1
  fi
done

script_directory="$(dirname "$(realpath "$0")")"
repo_directory="$(dirname "$script_directory")"

# Capture failures
exit_status=0 # everything passed
function set_failed_status {
  exit_status=1
}

# Print out Ruby version
ruby --version

# leave this until all tests are added
for product in \
  auth \
  bigquery \
  bigquerydatatransfer \
  cdn \
  datastore \
  # dialogflow \
  dlp \
  endpoints/getting-started \
  firestore \
  iot \
  kms \
  language \
  # logging \
  pubsub \
  spanner \
  speech \
  translate \
  video \
  vision
do
  # Run Tests
  echo "[$product]"
  pushd "$repo_directory/$product/"

  (bundle install && bundle exec rspec --format documentation) || set_failed_status
  popd
done

exit $exit_status
