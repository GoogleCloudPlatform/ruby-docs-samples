<img src="https://avatars2.githubusercontent.com/u/2810941?v=3&s=96" alt="Google Cloud Platform logo" title="Google Cloud Platform" align="right" height="96" width="96"/>

# Google Translate API Ruby Samples

[![Build](https://storage.googleapis.com/cloud-docs-samples-badges/GoogleCloudPlatform/ruby-docs-samples/translate.svg)]()

With the [Google Translate API](https://cloud.google.com/translate/docs), you can dynamically translate text between thousands of language pairs.

## Table of Contents

* [Setup](#setup)
* [Samples](#samples)
  * [Translate](#translate)
* [Running the tests](#running-the-tests)

## Setup

1.  Read [Prerequisites][prereq] and [How to run a sample][run] first.
1.  Install dependencies:

        bundle install

[prereq]: ../README.md#prerequisities
[run]: ../README.md#how-to-run-a-sample

## Samples

### Translate


View the [documentation][translate_0_docs] or the [source code][translate_0_code].

__Usage:__ `ruby translate_samples.rb --help`

```
Usage: ruby translate_samples.rb <command> [arguments]

Commands:
  translate           <desired-language-code> <text>
  translate_premium   <desired-language-code> <text>
  detect_language     <text>
  list_names          <language-code-for-display>
  list_codes

Examples:
  ruby translate_samples.rb translate fr "Hello World"
  ruby translate_samples.rb translate_premium fr "Hello World"
  ruby translate_samples.rb detect_language "Hello World"
  ruby translate_samples.rb list_codes
  ruby translate_samples.rb list_names en
```

[translate_0_docs]: https://cloud.google.com/translate/docs
[translate_0_code]: translate_samples.rb

## Running the tests

1.  Set the **GCLOUD_PROJECT** and **GOOGLE_APPLICATION_CREDENTIALS** environment variables.

1.  Run the tests:

        bundle exec rspec
