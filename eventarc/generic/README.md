# Eventarc - Generic

This sample shows how to create a service that receives and prints generic events.

[![Run in Google Cloud][run_img]][run_link]

[run_img]: https://storage.googleapis.com/cloudrun/button.svg
[run_link]: https://console.cloud.google.com/cloudshell/editor?shellonly=true&cloudshell_image=gcr.io/cloudrun/button&cloudshell_git_repo=https://github.com/GoogleCloudPlatform/ruby-docs-samples&cloudshell_working_dir=run/events-pubsub

## Quickstart

Set your environment variables:

```
export GOOGLE_CLOUD_PROJECT=<PROJECT_ID>
export GOOGLE_CLOUD_REGION=<REGION>
```

Create an Artifact Registry:

```
gcloud artifacts repositories create containers --repository-format docker --location ${GOOGLE_CLOUD_REGION}
```

Deploy your Cloud Run service:

```
gcloud builds submit \
 --tag ${GOOGLE_CLOUD_REGION}-docker.pkg.dev/${GOOGLE_CLOUD_PROJECT}/containers/eventarc-generic
gcloud run deploy eventarc-generic \
 --image ${GOOGLE_CLOUD_REGION}-docker.pkg.dev/${GOOGLE_CLOUD_PROJECT}/containers/eventarc-generic
```

## Test

Test your Cloud Run service with cURL:

```sh
URL=$(gcloud run services describe eventarc-generic --format='value(status.address.url)')
curl -XPOST $URL -H "CE-ID: 1234" --data '{"foo":"bar"}'
```

Observe the Run service replying with the headers and body of the sent HTTP request.

## Unit Test

```
bundle install
bundle exec rspec
```
