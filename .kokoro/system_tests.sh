#!/bin/bash

source $KOKORO_GFILE_DIR/secrets.sh

# Get a project from the project pool.
curl https://storage.googleapis.com/gimme-proj/linux_amd64/gimmeproj > /bin/gimmeproj && chmod +x /bin/gimmeproj;
gimmeproj version;
export GOOGLE_CLOUD_PROJECT=$(gimmeproj -project cloud-samples-ruby-test-kokoro lease 30m);
if [ -z "$GOOGLE_CLOUD_PROJECT" ]; then
  echo "Lease failed."
  exit 1
fi
echo "Running tests in project $GOOGLE_CLOUD_PROJECT";
trap "gimmeproj -project cloud-samples-ruby-test-kokoro done $GOOGLE_CLOUD_PROJECT" EXIT

export FIRESTORE_PROJECT_ID=ruby-firestore

# Use a project-specific bucket to avoid race conditions.
export GOOGLE_CLOUD_STORAGE_BUCKET="$GOOGLE_CLOUD_PROJECT-cloud-samples-ruby-bucket"
export ALTERNATE_GOOGLE_CLOUD_STORAGE_BUCKET="$GOOGLE_CLOUD_STORAGE_BUCKET-alt"

# Run Spanner tests if RUN_ALL_TESTS is set.
if [[ -n ${RUN_ALL_TESTS:-} ]]; then
  export GOOGLE_CLOUD_SPANNER_TEST_INSTANCE=ruby-test-instance
  export GOOGLE_CLOUD_SPANNER_PROJECT=cloud-samples-ruby-test-0
fi

cd github/ruby-docs-samples/
./spec/kokoro-run-all.sh
