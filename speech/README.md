<img src="https://avatars2.githubusercontent.com/u/2810941?v=3&s=96" alt="Google Cloud Platform logo" title="Google Cloud Platform" align="right" height="96" width="96"/>

# Google Cloud Speech API Ruby Samples

The [Google Cloud Speech API](https://cloud.google.com/speech/) enables easy
integration of Google speech recognition technologies into developer applications.

## Run sample

To run the sample, first install dependencies:

    bundle install

Set up authentication for the Speech API:

    1. Generate a Service Account by following the [authentication instructions](https://cloud.google.com/docs/authentication#service_accounts).
    1. Set environment variable `GOOGLE_APPLICATION_CREDENTIALS=<path_to_service_account_file>`

Next, set the configured project by setting the *GOOGLE_CLOUD_PROJECT*
environment variable to the project name set in the
[Google Cloud Platform Developer Console](https://console.cloud.google.com):

    export GOOGLE_CLOUD_PROJECT="YOUR-PROJECT-ID"

## Samples

Run the sample:

    bundle exec ruby speech_samples.rb

Usage:

    Usage: ruby speech_samples.rb <command> [arguments]

    Commands:
    recognize           <filename> Detects speech in a local audio file.
    recognize_gcs       <gcsUri>   Detects speech in an audio file located in a Google Cloud Storage bucket.
    async_recognize     <filename> Creates a job to detect speech in a local audio file, and waits for the job to complete.
    async_recognize_gcs <gcsUri>   Creates a job to detect speech in an audio file located in a Google Cloud Storage bucket, and
                                   waits for the job to complete.

Examples:

    $ bundle exec ruby speech_samples.rb recognize audio_files/audio.raw
    Text: how old is the Brooklyn Bridge
