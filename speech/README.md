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
      recognize           audio-file.raw                Transcribe file
      recognize_gcs       gs://bucket/audio-file.raw    Transcribe file
      async_recognize     audio-file.raw                Transcribe file
      async_recognize_gcs gs://bucket/audio-file.raw    Transcribe file

Examples:

    $ bundle exec ruby speech_samples.rb recognize audio_files/audio.raw
    Text: how old is the Brooklyn Bridge
