# Eventarc – Pub/Sub tutorial

This sample shows how to create a service that processes Pub/Sub messages.

[![Run in Google Cloud][run_img]][run_link]

[run_img]: https://storage.googleapis.com/cloudrun/button.svg
[run_link]: https://console.cloud.google.com/cloudshell/editor?shellonly=true&cloudshell_image=gcr.io/cloudrun/button&cloudshell_git_repo=https://github.com/GoogleCloudPlatform/ruby-docs-samples&cloudshell_working_dir=run/events-pubsub

## Quickstart

Create a Cloud Pub/Sub topic:

```
gcloud pubsub topics create my-topic
```

Create a Cloud Pub/Sub topic:

```
gcloud alpha events triggers create pubsub-trigger-ruby \
--target-service eventarc-pubsub \
--type com.google.cloud.pubsub.topic.publish \
--parameters topic=my-topic
```

Deploy your Cloud Run service:

```
gcloud builds submit \
 --tag gcr.io/$(gcloud config get-value project)/eventarc-pubsub
gcloud run deploy eventarc-pubsub \
 --image gcr.io/$(gcloud config get-value project)/eventarc-pubsub
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
