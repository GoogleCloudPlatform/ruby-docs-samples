# Ruby Cloud Functions samples

This directory contains the Ruby samples for Cloud Functions.

Samples are organized one region tag (i.e. one sample) per file, where the file
paths (directories and file names) match the region tags. For example, the
sample for region tag `functions_helloworld_http` is in `helloworld/http.rb`.

Tests are organized similarly, one test file per sample file in the `test`
directory. The test for `functions_helloworld_http` is in
`test/helloworld/http_test.rb`. Tests generally do not deploy to GCF itself,
but use the testing facilities provided by the Ruby Functions Framework.

## Running the tests

In the `functions` directory:

```
bundle install
bundle exec rake test
```

Rubocop is generally run on the entire repository at once. Move up to the base
directory and:

```
bundle install
bundle exec rubocop
```

## Deploying a sample to Cloud Functions

Each sample comes with an `app.rb` file and a `Gemfile`, suitable for deploying
to Google Cloud Functions. If you have Cloud Functions active in your project,
you can deploy each sample directly from its directory.

First, install the bundle. Cloud Functions requires a locked bundle in order
to deploy (to encourage you to test against a locked bundle).

```
bundle install
```

Next, deploy using the gcloud command line:

```
gcloud functions deploy $YOUR_FUNCTION_NAME --project=$YOUR_PROJECT_ID \
  --runtime=ruby26 --trigger-http --entry-point=$FUNCTION_TARGET_NAME
```

For functions that use a different trigger, such as storage events, you will
need to replace `--trigger-http` with the appropriate trigger type. For more
details, see the
[reference documentation](https://cloud.google.com/sdk/gcloud/reference/functions/deploy)
for `gcloud functions deploy`.

## Adding a sample

To add a sample:

 *  Determine the region tag for the sample (i.e. the string identifying the
    sample in the cloudsite source). This should always be a string beginning
    with `functions_`; for example, `functions_helloworld_http`.
 *  Create two levels of directories matching the region tag. For tag
    `functions_helloworld_http`, create the directory `helloworld/http/`. For
    tag `functions_tips_infinite_retries`, the directory should be just two
    levels deep: `tips/infinite_retries`.
 *  In this directory, create a `Gemfile` and `app.rb`. Write the sample in
    these files. You can use existing samples as a model.
 *  Create a test for the sample in the parallel `test` directory. For tag
    `functions_helloworld_http`, the test file should be
    `test/helloworld/http_test.rb`. You can use existing tests as a model.
 *  Make sure the test passes, as well as Rubocop. See the section above on
    running the tests.
