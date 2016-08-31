<img src="https://avatars2.githubusercontent.com/u/2810941?v=3&s=96" alt="Google Cloud Platform logo" title="Google Cloud Platform" align="right" height="96" width="96"/>

# Google Cloud Translate API Ruby Samples


With the [Google Translate API][translate_docs], you can dynamically translate
text between thousands of language pairs.

[translate_docs]: https://cloud.google.com/translate/docs/

## Run sample

To run the sample, first install dependencies:

    bundle install

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
