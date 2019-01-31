# export JOB_TYPE="thing"

# bundle exec rake kokoro:$JOB_TYPE

if [[ "$(ruby --version)" = "1" ]]; then
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
else
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
fi

ruby --version