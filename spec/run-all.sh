#!/bin/bash

for required_variable in                       \
	GOOGLE_CLOUD_PROJECT                   \
	GOOGLE_APPLICATION_CREDENTIALS         \
	GOOGLE_CLOUD_STORAGE_BUCKET            \
	ALTERNATE_GOOGLE_CLOUD_STORAGE_BUCKET  \
	TRANSLATE_API_KEY                      \
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

# Run Tets
for product in      \
	bigquery    \
	datastore   \
	endpoints   \
	language    \
	logging     \
	pubsub      \
	speech      \
	storage     \
	translate   \
	vision      \
; do
	echo "[$product]"
	cd "$repo_directory/$product/"
	bundle install && bundle exec rspec --format documentation
        
	 # Check status of bundle exec rspec
	if [ $? != 0 ]; then
		status_return=1
	fi
done

exit $status_return
