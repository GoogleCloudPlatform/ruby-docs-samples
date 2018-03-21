#!/bin/bash

set -e -u -o pipefail

for required_variable in                   \
  GOOGLE_CLOUD_PROJECT                     \
  GOOGLE_APPLICATION_CREDENTIALS           \
  GOOGLE_CLOUD_STORAGE_BUCKET              \
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
  cdn
do
  # Run Tests
  echo "[$product]"
  pushd "$repo_directory/$product/"

  (bundle install && bundle exec rspec --format documentation) || set_failed_status
  popd
done

exit $exit_status
