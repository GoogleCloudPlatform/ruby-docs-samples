#! /bin/bash

set -e

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

# TODO: make all environment variables consistent
export GOOGLE_PROJECT_ID="$GOOGLE_CLOUD_PROJECT"
export GCLOUD_PROJECT="$GOOGLE_CLOUD_PROJECT"
export STORAGE_BUCKET="$GOOGLE_CLOUD_STORAGE_BUCKET"
export BUCKET="$GOOGLE_CLOUD_STORAGE_BUCKET"
export ALT_BUCKET="$ALTERNATE_GOOGLE_CLOUD_STORAGE_BUCKET"
export TRANSLATE_KEY="$TRANSLATE_API_KEY"

script_directory="$(dirname "`realpath $0`")"
repo_directory="$(dirname $script_directory)"

for product in      \
	bigquery    \
	datastore   \
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
	bundle install
	bundle exec rspec --format documentation --fail-fast
done
