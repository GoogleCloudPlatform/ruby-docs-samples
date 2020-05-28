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

## Adding a sample

To add a sample:

*   Determine the region tag for the sample (i.e. the string identifying the
    sample in the cloudsite source). This should always be a string beginning
    with `functions_`; for example, `functions_helloworld_http`.
*   Create a Ruby directory/file matching the region tag. For tag
    `functions_helloworld_http`, create the file `helloworld/http.rb`. Write
    the sample in this file. You can use existing samples as a model.
*   Create a test for the sample in the parallel `test` directory. For tag
    `functions_helloworld_http`, the test file should be
    `test/helloworld/http_test.rb`. You can use existing tests as a model.
*   Make sure the test passes, as well as Rubocop. See the section above on
    running the tests.
