#!/bin/bash

source $KOKORO_GFILE_DIR/secrets.sh

curl https://storage.googleapis.com/gimme-proj/linux_amd64/gimmeproj > /bin/gimmeproj && chmod +x /bin/gimmeproj;
gimmeproj version;
export GOOGLE_CLOUD_PROJECT=$(gimmeproj -project cloud-samples-ruby-test-kokoro lease 30m);
if [ -z "$GOOGLE_CLOUD_PROJECT" ]; then
  echo "Lease failed."
  exit 1
fi
echo "Running tests in project $GOOGLE_CLOUD_PROJECT";
trap "gimmeproj -project cloud-samples-ruby-test-kokoro done $GOOGLE_CLOUD_PROJECT" EXIT

export GOOGLE_CLOUD_STORAGE_BUCKET="$GOOGLE_CLOUD_PROJECT-$GOOGLE_CLOUD_STORAGE_BUCKET"
export ALTERNATE_GOOGLE_CLOUD_STORAGE_BUCKET="$GOOGLE_CLOUD_STORAGE_BUCKET-alt"

cd github/ruby-docs-samples/
./spec/kokoro-run-all.sh
