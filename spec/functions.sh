run_all_tests() {
  echo "Running all tests"
  SPEC_DIRS=$(find * -type d -name 'spec' -path "*/*" -not -path "*vendor/*" -exec dirname {} \; | sort | uniq)
  for PRODUCT in $SPEC_DIRS; do
    # Run Tests
    echo "[$PRODUCT]"
    export TEST_DIR="$PRODUCT"
    pushd "$REPO_DIRECTORY/$PRODUCT/"

    (bundle install && bundle exec rspec --format documentation) || set_failed_status

    if [[ $E2E = "true" ]]; then
      # Clean up deployed version
      bundle exec ruby "$REPO_DIRECTORY/spec/e2e_cleanup.rb" "$TEST_DIR" "$BUILD_ID"
    fi
    popd
  done
}

run_changed_tests() {
  SPEC_DIRS=$(find $CHANGED_DIRS -type d -name 'spec' -path "*/*" -not -path "*vendor/*" -exec dirname {} \; | sort | uniq)
  echo "Running tests in modified directories: $SPEC_DIRS"
  for PRODUCT in $SPEC_DIRS
  do
    # Run Tests
    echo "[$PRODUCT]"
    export TEST_DIR="$PRODUCT"
    pushd "$REPO_DIRECTORY/$PRODUCT/"

    (bundle install && bundle exec rspec --format documentation) || set_failed_status

    if [[ $E2E = "true" ]]; then
      # Clean up deployed version
      bundle exec ruby "$REPO_DIRECTORY/spec/e2e_cleanup.rb" "$TEST_DIR" "$BUILD_ID"
    fi
    popd
  done
}

verify_env_vars() {
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
}

prep_end_to_end() {
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
}

get_changed_dirs() {
    # CHANGED_DIRS is the list of top-level directories that changed. CHANGED_DIRS will be empty when run on master.
    CHANGED_DIRS=$(git --no-pager diff --name-only HEAD $(git merge-base HEAD master) | grep "/" | cut -d/ -f1 | sort | uniq || true)

    # The appengine directory has many subdirectories. Only test the modified ones.
    if [[ $CHANGED_DIRS =~ "appengine" ]]; then
        AE_CHANGED_DIRS=$(git --no-pager diff --name-only HEAD $(git merge-base HEAD master) | grep "appengine/" | cut -d/ -f1,2 | sort | uniq || true)
        CHANGED_DIRS="${CHANGED_DIRS/appengine/} $AE_CHANGED_DIRS"
    fi
}

setup_gimmeproj() {
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
}

set_env_vars() {
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
}