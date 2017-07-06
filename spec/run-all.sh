#!/bin/bash

function PrepareAppYaml () {
	if [ -a "app.yaml" ]; then
	  if [ -a "bin/rails" ]; then
	    sed -i'.bak' \
	      -e "s/\[SECRET_KEY\]/${RAILS_SECRET_KEY_BASE}/g" \
	      app.yaml
	    sed -i'.bak' \
	      -e "s/\[YOUR_INSTANCE_CONNECTION_NAME\]/${CLOUD_SQL_CONNECTION_NAME}/g" \
	      app.yaml
	    sed -i'.bak' \
	      -e "s/\[MYSQL_USER\]/${CLOUD_SQL_MYSQL_USERNAME}/g" \
	      config/database.yml
	    sed -i'.bak' \
	      -e "s/\[MYSQL_PASSWORD\]/${CLOUD_SQL_MYSQL_PASSWORD}/g" \
	      config/database.yml
	    sed -i'.bak' \
	      -e "s/\[YOUR_INSTANCE_CONNECTION_NAME\]/${CLOUD_SQL_CONNECTION_NAME}/g" \
	      config/database.yml
	  fi
	fi
}

for required_variable in                       \
	GOOGLE_CLOUD_PROJECT                   \
	GOOGLE_APPLICATION_CREDENTIALS         \
	GOOGLE_CLOUD_STORAGE_BUCKET            \
	ALTERNATE_GOOGLE_CLOUD_STORAGE_BUCKET  \
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

while read product
do
	# Run Tets
	export BUILD_ID=$CIRCLE_BUILD_NUM
	export TEST_DIR=$product
	echo "[$product]"
	pushd "$repo_directory/$product/"
	PrepareAppYaml
	bundle install && bundle exec rspec --format documentation
	
	# Check status of bundle exec rspec
	if [ $? != 0 ]; then
		status_return=1
	fi
	
	# Clean up deployed version
	bundle exec ruby "$repo_directory/spec/e2e_cleanup.rb" "$TEST_DIR" "$BUILD_ID"
	
	popd
done < <(find * -type d -name 'spec' -path "*/*" -not -path "*vendor/*" -exec dirname {} \;)

exit $status_return
