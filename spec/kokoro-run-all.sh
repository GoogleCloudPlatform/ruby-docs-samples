#!/bin/bash

# This file runs tests for nightly builds and PRs.
# There are a few rules for what tests are run:
#  * Only the latest Ruby version runs E2E and Spanner tests (for nightly and PR builds).
#    - This is indicated by setting RUN_ALL_TESTS before starting this script.
#  * PRs only run tests in modified directories, unless the `spec` or `.kokoro` directories
#    are modified, in which case all tests will be run.
#  * Nightly runs will run all tests.

set -x -e -u -o pipefail

# Print out Ruby version
ruby --version

source $KOKORO_GFILE_DIR/secrets.sh

# Temporary workaround for a known bundler+docker issue:
# https://github.com/bundler/bundler/issues/6154
export BUNDLE_GEMFILE=

for REQUIRED_VARIABLE in                   \
  GOOGLE_CLOUD_PROJECT                     \
  GOOGLE_APPLICATION_CREDENTIALS           \
  GOOGLE_CLOUD_STORAGE_BUCKET              \
  ALTERNATE_GOOGLE_CLOUD_STORAGE_BUCKET    \
  GOOGLE_CLOUD_PROJECT_SECONDARY           \
  GOOGLE_APPLICATION_CREDENTIALS_SECONDARY \
  GOOGLE_CLOUD_KMS_KEY_NAME                \
  GOOGLE_CLOUD_KMS_KEY_RING
do
  if [[ -z "${REQUIRED_VARIABLE:-}" ]]; then
    echo "Must set $REQUIRED_VARIABLE"
    exit 1
  fi
done

SCRIPT_DIRECTORY="$(dirname "$(realpath "$0")")"
REPO_DIRECTORY="$(dirname "$SCRIPT_DIRECTORY")"

# Set application credentials before using gimmeproj so it has access.
export GOOGLE_APPLICATION_CREDENTIALS=$KOKORO_KEYSTORE_DIR/71386_kokoro-cloud-samples-ruby-test-0

# Get a project from the project pool.
# See https://github.com/GoogleCloudPlatform/golang-samples/tree/master/testing/gimmeproj.
curl https://storage.googleapis.com/gimme-proj/linux_amd64/gimmeproj > /bin/gimmeproj
chmod +x /bin/gimmeproj
gimmeproj version;
export GOOGLE_CLOUD_PROJECT=$(gimmeproj -project cloud-samples-ruby-test-kokoro lease 60m);
if [ -z "$GOOGLE_CLOUD_PROJECT" ]; then
  echo "Lease failed."
  exit 1
fi
echo "Running tests in project $GOOGLE_CLOUD_PROJECT";
trap "gimmeproj -project cloud-samples-ruby-test-kokoro done $GOOGLE_CLOUD_PROJECT" EXIT

# Set application credentials to the project-specific account. Some APIs do not
# allow the service account project and GOOGLE_CLOUD_PROJECT to be different.
export GOOGLE_APPLICATION_CREDENTIALS=$KOKORO_KEYSTORE_DIR/71386_kokoro-$GOOGLE_CLOUD_PROJECT

export FIRESTORE_PROJECT_ID=ruby-firestore
export E2E_GOOGLE_CLOUD_PROJECT=cloud-samples-ruby-test-kokoro
export MYSQL_DATABASE=${GOOGLE_CLOUD_PROJECT//-/_}
export POSTGRES_DATABASE=${GOOGLE_CLOUD_PROJECT//-/_}

# Use a project-specific bucket to avoid race conditions.
export GOOGLE_CLOUD_STORAGE_BUCKET="$GOOGLE_CLOUD_PROJECT-cloud-samples-ruby-bucket"
export ALTERNATE_GOOGLE_CLOUD_STORAGE_BUCKET="$GOOGLE_CLOUD_STORAGE_BUCKET-alt"

# Run Spanner tests if RUN_ALL_TESTS is set.
if [[ -n ${RUN_ALL_TESTS:-} ]]; then
  export GOOGLE_CLOUD_SPANNER_TEST_INSTANCE=ruby-test-instance
  export GOOGLE_CLOUD_SPANNER_PROJECT=cloud-samples-ruby-test-0
fi

export E2E="false"

# If we're running nightly tests (not a PR) and RUN_ALL_TESTS is set, run E2E tests.
if [[ $KOKORO_BUILD_ARTIFACTS_SUBDIR =~ "system-tests" && -n ${RUN_ALL_TESTS:-} ]]; then
  export E2E="true"
fi

cd github/ruby-docs-samples/

# CHANGED_DIRS is the list of top-level directories that changed. CHANGED_DIRS will be empty when run on master.
CHANGED_DIRS=$(git --no-pager diff --name-only HEAD $(git merge-base HEAD master) | grep "/" | cut -d/ -f1 | sort | uniq || true)

# The appengine directory has many subdirectories. Only test the modified ones.
if [[ $CHANGED_DIRS =~ "appengine" ]]; then
  AE_CHANGED_DIRS=$(git --no-pager diff --name-only HEAD $(git merge-base HEAD master) | grep "appengine/" | cut -d/ -f1,2 | sort | uniq || true)
  CHANGED_DIRS="${CHANGED_DIRS/appengine/} $AE_CHANGED_DIRS"
fi

# Most tests in the appengine directory are E2E.
if [[ $CHANGED_DIRS =~ "appengine" && -n ${RUN_ALL_TESTS:-} ]]; then
  E2E="true"
fi

# RUN_ALL_TESTS after this point is used to indicate if we should run tests in every directory,
# rather than only tests in modified directories.
RUN_ALL_TESTS="0"
# If this is a nightly test (not a PR), run all tests (rather than only tests in modified directories).
if [[ $KOKORO_BUILD_ARTIFACTS_SUBDIR =~ "system-tests" ]]; then
  RUN_ALL_TESTS="1"
fi

# If the test configuration changed, run all tests.
if [[ $CHANGED_DIRS =~ "spec" || $CHANGED_DIRS =~ ".kokoro" ]]; then
  RUN_ALL_TESTS="1"
fi

# Start memcached (for appengine/memcache).
service memcached start

if [[ $E2E = "true" ]]; then
  echo "This test run will run end-to-end tests."

  export PATH="$PATH:/tmp/google-cloud-sdk/bin"
  export BUILD_ID=${KOKORO_BUILD_ID: -10}

  ./.kokoro/configure_gcloud.sh

  # Download Cloud SQL Proxy.
  wget https://dl.google.com/cloudsql/cloud_sql_proxy.linux.amd64
  mv cloud_sql_proxy.linux.amd64 /cloud_sql_proxy
  chmod +x /cloud_sql_proxy
  mkdir /cloudsql && chmod 0777 /cloudsql

  # Start Cloud SQL Proxy.
  /cloud_sql_proxy -dir=/cloudsql -credential_file=$GOOGLE_APPLICATION_CREDENTIALS &
  export CLOUD_SQL_PROXY_PROCESS_ID=$!
  trap "kill $CLOUD_SQL_PROXY_PROCESS_ID || true" EXIT
fi

# Capture failures
EXIT_STATUS=0 # everything passed
function set_failed_status {
  EXIT_STATUS=1
}

(bundle update && bundle exec rubocop) || set_failed_status

if [[ $RUN_ALL_TESTS = "1" ]]; then
  echo "Running all tests"
  SPEC_DIRS=$(find * -type d -name 'spec' -path "*/*" -not -path "*vendor/*" -exec dirname {} \; | sort | uniq)
  for PRODUCT in $SPEC_DIRS; do
    # Run Tests
    echo "[$PRODUCT]"
    export TEST_DIR="$PRODUCT"
    pushd "$REPO_DIRECTORY/$PRODUCT/"

    (bundle update && bundle exec rspec --format documentation) || set_failed_status

    if [[ $E2E = "true" ]]; then
      # Clean up deployed version
      bundle exec ruby "$REPO_DIRECTORY/spec/e2e_cleanup.rb" "$TEST_DIR" "$BUILD_ID"
    fi
    popd
  done
else
  SPEC_DIRS=$(find $CHANGED_DIRS -type d -name 'spec' -path "*/*" -not -path "*vendor/*" -exec dirname {} \; | sort | uniq)
  echo "Running tests in modified directories: $SPEC_DIRS"
  for PRODUCT in $SPEC_DIRS
  do
    # Run Tests
    echo "[$PRODUCT]"
    export TEST_DIR="$PRODUCT"
    pushd "$REPO_DIRECTORY/$PRODUCT/"

    (bundle update && bundle exec rspec --format documentation) || set_failed_status

    if [[ $E2E = "true" ]]; then
      # Clean up deployed version
      bundle exec ruby "$REPO_DIRECTORY/spec/e2e_cleanup.rb" "$TEST_DIR" "$BUILD_ID"
    fi
    popd
  done
fi

exit $EXIT_STATUS
