# Eventarc - Generic

This sample shows how to create a service that receives and prints generic events.

[![Run in Google Cloud][run_img]][run_link]

[run_img]: https://storage.googleapis.com/cloudrun/button.svg
[run_link]: https://console.cloud.google.com/cloudshell/editor?shellonly=true&cloudshell_image=gcr.io/cloudrun/button&cloudshell_git_repo=https://github.com/GoogleCloudPlatform/ruby-docs-samples&cloudshell_working_dir=run/events-pubsub

## Quickstart

Deploy your Cloud Run service:

```
gcloud builds submit \
 --tag gcr.io/$(gcloud config get-value project)/eventarc-generic
gcloud run deploy eventarc-generic \
 --image gcr.io/$(gcloud config get-value project)/eventarc-generic
```

## Test

Test your Cloud Run service by publishing a message to the topic:

```sh
gcloud pubsub topics publish my-topic --message="Hello there"
```

You may observe the Run service receiving an event in Cloud Logging.

## Unit Test

```
bundle install
bundle exec rspec
```
