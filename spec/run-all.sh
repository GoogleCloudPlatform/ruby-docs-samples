#!/bin/bash

for required_variable in                         \
	GOOGLE_CLOUD_PROJECT                     \
	GOOGLE_CLOUD_PROJECT_SECONDARY           \
	GOOGLE_APPLICATION_CREDENTIALS           \
	GOOGLE_APPLICATION_CREDENTIALS_SECONDARY \
	GOOGLE_CLOUD_STORAGE_BUCKET              \
	ALTERNATE_GOOGLE_CLOUD_STORAGE_BUCKET    \
	GOOGLE_CLOUD_SPANNER_TEST_INSTANCE       \
	GOOGLE_CLOUD_SPANNER_TEST_DATABASE       \
	CLOUD_SQL_MYSQL_USERNAME                 \
	CLOUD_SQL_MYSQL_PASSWORD                 \
	CLOUD_SQL_MYSQL_CONNECTION_NAME          \
	RAILS_SECRET_KEY_BASE                    \
; do
	if [[ -z "${!required_variable}" ]]; then
		echo "Must set $required_variable"
		exit 1
	fi
done

script_directory="$(dirname "`realpath $0`")"
repo_directory="$(dirname $script_directory)"
status_return=0 # everything passed

# Print out Ruby version
ruby --version

# Start Cloud SQL Proxy
$HOME/cloud_sql_proxy -dir=/cloudsql -credential_file=$GOOGLE_APPLICATION_CREDENTIALS &
export CLOUD_SQL_PROXY_PROCESS_ID=$!

while read product
do
	# Run Tets
	export BUILD_ID=$CIRCLE_BUILD_NUM
	export TEST_DIR=$product
	echo "[$product]"
	pushd "$repo_directory/$product/"
	bundle install && bundle exec rspec --format documentation
	
	# Check status of bundle exec rspec
	if [ $? != 0 ]; then
		status_return=1
	fi
	
	# Clean up deployed version
	bundle exec ruby "$repo_directory/spec/e2e_cleanup.rb" "$TEST_DIR" "$BUILD_ID"
	
	popd
done < <(find * -type d -name 'spec' -path "*/*" -not -path "*vendor/*" -exec dirname {} \;)

# Stop Cloud SQL Proxy
kill $CLOUD_SQL_PROXY_PROCESS_ID

exit $status_return
