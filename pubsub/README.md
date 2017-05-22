# Cloud Pub/Sub Sample

[![Build](https://storage.googleapis.com/cloud-docs-samples-badges/GoogleCloudPlatform/ruby-docs-samples/pubsub.svg)]()

Set the environment variable `GOOGLE_CLOUD_PROJECT` to your Google Cloud
Platform project ID.

Test:

```bash
$ bundle exec rspec
```

Deploy the push listener:

```bash
$ gcloud app deploy --promote
```

You will see messages pushed to the listener in
[Google Cloud Logging](https://cloud.google.com/logging/docs/).
