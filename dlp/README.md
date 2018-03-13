# DLP Sample

This sample provides example code for
[cloud.google.com/dlp/docs](https://cloud.google.com/dlp/docs).

## Setup

Before you can run or test the sample, you will need to enable the DLP API in the [Google Developers Console](https://console.developers.google.com/projectselector/apis/api/dlp.googleapis.com/overview).

## Testing

The tests for the sample are integration tests that run against the DLP
service and require authentication.

### Authenticating

Set the following environment variable to your Google Cloud Platform project ID:

* `GCLOUD_PROJECT`

For more information, see
[Authentication](https://googlecloudplatform.github.io/gcloud-ruby/#/docs/guides/authentication).

### Running the tests

```bash
$ bundle exec rspec
```

