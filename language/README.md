<img src="https://avatars2.githubusercontent.com/u/2810941?v=3&s=96" alt="Google Cloud Platform logo" title="Google Cloud Platform" align="right" height="96" width="96"/>

# Google Cloud Natural Language API Ruby Samples

[![Build](https://storage.googleapis.com/cloud-docs-samples-badges/GoogleCloudPlatform/ruby-docs-samples/language.svg)]()

[Cloud Natural Language API](https://cloud.google.com/natural-language/docs) provides natural language understanding technologies to developers, including sentiment analysis, entity recognition, and syntax analysis. This API is part of the larger Cloud Machine Learning API.

## Table of Contents

* [Setup](#setup)
* [Samples](#samples)
  * [Analyze](#analyze)
* [Running the tests](#running-the-tests)

## Setup

1.  Read [Prerequisites][prereq] and [How to run a sample][run] first.
1.  Install dependencies:

        bundle install

[prereq]: ../README.md#prerequisities
[run]: ../README.md#how-to-run-a-sample

## Samples

### Analyze


View the [documentation][language_0_docs] or the [source code][language_0_code].

__Usage:__ `ruby language_samples.rb`

```
Usage: ruby language_samples.rb <text-to-analyze>
```

[language_0_docs]: https://cloud.google.com/natural-language/docs
[language_0_code]: language_samples.rb

## Running the tests

1.  Set the **GCLOUD_PROJECT** and **GOOGLE_APPLICATION_CREDENTIALS** environment variables.

1.  Run the tests:

        bundle exec rspec
