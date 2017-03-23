<img src="https://avatars2.githubusercontent.com/u/2810941?v=3&s=96" alt="Google Cloud Platform logo" title="Google Cloud Platform" align="right" height="96" width="96"/>

# Google Cloud Speech API Ruby Samples

[Sign up for the Alpha](https://services.google.com/fb/forms/speech-api-alpha/).

The [Cloud Speech API](https://cloud.google.com/speech/) enables easy
integration of Google speech recognition technologies into developer applications.

## Run sample

To run the sample, first install dependencies:

    bundle install

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
