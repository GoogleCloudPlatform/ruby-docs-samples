<img src="https://avatars2.githubusercontent.com/u/2810941?v=3&s=96" alt="Google Cloud Platform logo" title="Google Cloud Platform" align="right" height="96" width="96"/>

# Google Cloud Natural Language API Ruby Samples

[Cloud Natural Language API][language_docs] provides natural language
understanding technologies to developers, including sentiment analysis, entity
recognition, and syntax analysis. This API is part of the larger Cloud Machine
Learning API.

[language_docs]: https://cloud.google.com/natural-language/docs/

## Run sample

To run the sample, first install dependencies:

    bundle install

Run the sample:

    export GOOGLE_CLOUD_PROJECT="Your Google Cloud project ID"

    bundle exec ruby language_samples.rb

Usage:

    Usage: ruby language_samples.rb <text-to-analyze>

Example:

    bundle exec ruby language_samples.rb "Alice and Bob are happy people."

    Sentiment:
    1.0 (0.699999988079071)

    Entries:
    Entity Alice PERSON
    Entity Bob PERSON

    Syntax:
    Sentences: 1
    Tokens: 7
    NOUN Alice
    CONJ and
    NOUN Bob
    VERB are
    ADJ happy
    NOUN people
    PUNCT .
