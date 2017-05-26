<img src="https://avatars2.githubusercontent.com/u/2810941?v=3&s=96" alt="Google Cloud Platform logo" title="Google Cloud Platform" align="right" height="96" width="96"/>

# Google Cloud Translation API Ruby Samples

The [Google Cloud Translation API][translate_docs] can dynamically translate
text between thousands of language pairs. The Cloud Translation API lets
websites and programs integrate with the translation service programmatically.
The Google Translation API is part of the larger Cloud Machine Learning API
family.

[translate_docs]: https://cloud.google.com/translate/docs/

## Run sample

To run the sample, first install dependencies:

    bundle install

Set up authentication for the Translation API:

    1. Generate a Service Account by following [Translation API authentication instructions](https://cloud.google.com/translate/docs/common/auth#service-accounts).
    1. Set environment variable `GOOGLE_APPLICATION_CREDENTIALS=<path_to_service_account_file>`

Next, set the configured project by setting the *GOOGLE_CLOUD_PROJECT*
environment variable to the project name set in the
[Google Cloud Platform Developer Console](https://console.cloud.google.com):

    export GOOGLE_CLOUD_PROJECT="YOUR-PROJECT-ID"

## Samples

Run the sample:

    bundle exec ruby translate_samples.rb

Usage:

  Usage: ruby translate_samples.rb <command> [arguments]

  Commands:
    translate       <desired-language-code> <text>
    detect_language <text>
    list_names      <language-code-for-display>
    list_codes

  Examples:

    ruby translate_samples.rb translate fr "Hello World"
    ruby translate_samples.rb detect_language "Hello World"
    ruby translate_samples.rb list_codes
    ruby translate_samples.rb list_names en
