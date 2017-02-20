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