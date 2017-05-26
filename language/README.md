<img src="https://avatars2.githubusercontent.com/u/2810941?v=3&s=96" alt="Google Cloud Platform logo" title="Google Cloud Platform" align="right" height="96" width="96"/>

# Google Cloud Natural Language API Ruby Samples

The [Google Cloud Natural Language API][language_docs] provides natural language
understanding technologies to developers, including sentiment analysis, entity
recognition, and syntax analysis. This API is part of the larger Cloud Machine
Learning API.

[language_docs]: https://cloud.google.com/natural-language/docs/

## Setup

### Authentication

Authentication is typically done through [Application Default Credentials](https://cloud.google.com/docs/authentication#getting_credentials_for_server-centric_flow)
, which means you do not have to change the code to authenticate as long as your
environment has credentials. You have a few options for setting up
authentication:

1. When running locally, use the [Google Cloud SDK](https://cloud.google.com/sdk/)

    gcloud auth application-default login

1. When running on App Engine or Compute Engine, credentials are already set-up.
However, you may need to configure your Compute Engine instance with
[additional scopes](https://cloud.google.com/compute/docs/authentication#using).

1. You can create a [Service Account key file](https://cloud.google.com/docs/authentication#service_accounts)
. This file can be used to authenticate to Google Cloud Platform services from
any environment. To use the file, set the `GOOGLE_APPLICATION_CREDENTIALS`
environment variable to the path to the key file, for example:

    export GOOGLE_APPLICATION_CREDENTIALS=/path/to/service_account.json

### Set Project ID

Next, set the *GOOGLE_CLOUD_PROJECT* environment variable to the project name
set in the
[Google Cloud Platform Developer Console](https://console.cloud.google.com):

    export GOOGLE_CLOUD_PROJECT="YOUR-PROJECT-ID"

### Install Dependencies

1. Install the [Bundler](http://bundler.io/) gem.

1. Install dependencies using:

    bundle install

## Run samples

Run the sample:

    bundle exec ruby language_samples.rb

Usage:

    Usage: ruby language_samples.rb <text-to-analyze>

Example:

    bundle exec ruby language_samples.rb "Alice and Bob are frustrated. William Shakespeare is extremely amazingly great."

    Sentiment:
    Overall document sentiment: 0.20000000298023224
    Sentence level sentiment:
    Alice and Bob are frustrated. (-0.30000001192092896)
    William Shakespeare is extremely amazingly great. (0.800000011920929)

    Entities:
    Entity Alice PERSON
    Entity Bob PERSON
    Entity William Shakespeare PERSON http://en.wikipedia.org/wiki/William_Shakespeare

    Syntax:
    Sentences: 2
    Tokens: 13
    NOUN Alice
    CONJ and
    NOUN Bob
    VERB are
    ADJ frustrated
    PUNCT .
    NOUN William
    NOUN Shakespeare
    VERB is
    ADV extremely
    ADV amazingly
    ADJ great
    PUNCT .

