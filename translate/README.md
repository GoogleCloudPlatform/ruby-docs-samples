<img src="https://avatars2.githubusercontent.com/u/2810941?v=3&s=96" alt="Google Cloud Platform logo" title="Google Cloud Platform" align="right" height="96" width="96"/>

# Google Cloud Translation API Ruby Samples

The [Google Cloud Translation API][translate_docs] can dynamically translate
text between thousands of language pairs. The Cloud Translation API lets
websites and programs integrate with the translation service programmatically.
The Google Translation API is part of the larger Cloud Machine Learning API
family.

[translate_docs]: https://cloud.google.com/translate/docs/

## Setup

### Authentication

Authentication is typically done through [Application Default Credentials](https://cloud.google.com/docs/authentication#getting_credentials_for_server-centric_flow)
, which means you do not have to change the code to authenticate as long as your
environment has credentials. You have a few options for setting up
authentication:

1. When running locally, use the [Google Cloud SDK](https://cloud.google.com/sdk/)

    `gcloud auth application-default login`

1. When running on App Engine or Compute Engine, credentials are already set-up.
However, you may need to configure your Compute Engine instance with
[additional scopes](https://cloud.google.com/compute/docs/authentication#using).

1. You can create a [Service Account key file](https://cloud.google.com/docs/authentication#service_accounts)
. This file can be used to authenticate to Google Cloud Platform services from
any environment. To use the file, set the `GOOGLE_APPLICATION_CREDENTIALS`
environment variable to the path to the key file, for example:

    `export GOOGLE_APPLICATION_CREDENTIALS=/path/to/service_account.json`

### Set Project ID

Next, set the *GOOGLE_CLOUD_PROJECT* environment variable to the project name
set in the
[Google Cloud Platform Developer Console](https://console.cloud.google.com):

    `export GOOGLE_CLOUD_PROJECT="YOUR-PROJECT-ID"`

### Install Dependencies

1. Install the [Bundler](http://bundler.io/) gem.

1. Install dependencies using:

    `bundle install`

## Run samples

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
