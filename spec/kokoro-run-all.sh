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

RUN_ALL_TESTS="0"
# If this is a nightly test (not a PR), run all tests.
if [ -z ${KOKORO_GITHUB_PULL_REQUEST_NUMBER:-} ]; then
  RUN_ALL_TESTS="1"
fi

CHANGED_DIRS=$(git --no-pager diff --name-only HEAD $(git merge-base HEAD master) | grep "/" | cut -d/ -f1 | sort | uniq)

# If test configuration is changed, run all tests.
if [[ $CHANGED_DIRS =~ "spec" || $CHANGED_DIRS =~ ".kokoro" ]]; then
  RUN_ALL_TESTS="1"
fi

if [[ $RUN_ALL_TESTS = "1" ]]; then
  echo "Running all tests"
  # leave this until all tests are added
  for product in \
    auth \
    bigquery \
    bigquerydatatransfer \
    cdn \
    datastore \
    dialogflow \
    dlp \
    endpoints/getting-started \
    firestore \
    iot \
    kms \
    language \
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
else
  SPEC_DIRS=$(find $CHANGED_DIRS -type d -name 'spec' -path "*/*" -not -path "*vendor/*" -exec dirname {} \; | sort | uniq)
  echo "Running tests in modified directories: $SPEC_DIRS"
  for product in $SPEC_DIRS
  do
    # Run Tests
    echo "[$product]"
    pushd "$repo_directory/$product/"

    (bundle install && bundle exec rspec --format documentation) || set_failed_status
    popd
  done
fi

exit $exit_status
