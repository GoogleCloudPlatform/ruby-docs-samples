<img src="https://avatars2.githubusercontent.com/u/2810941?v=3&s=96" alt="Google Cloud Platform logo" title="Google Cloud Platform" align="right" height="96" width="96"/>

# Google Cloud Speech API Ruby Samples

[![Build](https://storage.googleapis.com/cloud-docs-samples-badges/GoogleCloudPlatform/ruby-docs-samples/speech.svg)]()

The [Cloud Speech API](https://cloud.google.com/speech/docs) enables easy integration of Google speech recognition technologies into developer applications.

## Table of Contents

* [Setup](#setup)
* [Samples](#samples)
  * [Speech](#speech)
* [Running the tests](#running-the-tests)

## Setup

1.  Read [Prerequisites][prereq] and [How to run a sample][run] first.
1.  Install dependencies:

        bundle install

[prereq]: ../README.md#prerequisities
[run]: ../README.md#how-to-run-a-sample

## Samples

### Speech


View the [documentation][speech_0_docs] or the [source code][speech_0_code].

__Usage:__ `ruby speech_samples.rb --help`

```
Usage: ruby speech_samples.rb <command> [arguments]

Commands:
  recognize           <filename> Detects speech in a local audio file.
  recognize_gcs       <gcsUri>   Detects speech in an audio file located in a Google Cloud Storage bucket.
  async_recognize     <filename> Creates a job to detect speech in a local audio file, and waits for the job to complete.
  async_recognize_gcs <gcsUri>   Creates a job to detect speech in an audio file located in a Google Cloud Storage bucket, and
                                 waits for the job to complete.
```

[speech_0_docs]: https://cloud.google.com/speech/docs
[speech_0_code]: speech_samples.rb

## Running the tests

1.  Set the **GCLOUD_PROJECT** and **GOOGLE_APPLICATION_CREDENTIALS** environment variables.

1.  Run the tests:

        bundle exec rspec
