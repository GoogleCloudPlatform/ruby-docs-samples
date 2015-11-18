# Cloud Pub/Sub Sample

Set the environment variable `GCLOUD_PROJECT` to your Google Cloud
Platform project ID.

Test:

```bash
$ bundle exec rake spec
```

Deploy the push listener:

```bash
$ gcloud preview app deploy --promote
```

You will see messages pushed to the listener in
[Google Cloud Logging](https://cloud.google.com/logging/docs/).
