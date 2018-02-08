<img src="https://avatars2.githubusercontent.com/u/2810941?v=3&s=96" alt="Google Cloud Platform logo" title="Google Cloud Platform" align="right" height="96" width="96"/>

# Google Cloud CDN Ruby Samples

The [Google Cloud CDN][cdn_docs] (Content Delivery Network) uses Google's
globally distributed edge points of presence to cache HTTP(S) load balanced
content close to your users. Caching content at the edges of Google's network
provides faster delivery of content to your users while reducing serving costs.

[cdn_docs]: https://cloud.google.com/cdn/docs/

## Setup

### Install Dependencies

1. Install the [Bundler](http://bundler.io/) gem.

1. Install dependencies using:

    `bundle install`

## Run samples

Usage: bundle exec ruby sign_url.rb <url> <key_name> <key_file> <expiration>

Arguments:
  url        - URL to content served by Google Cloud CDN
  key_name   - Signing key name
  key_file   - Signing key file name with a urlsafe base64 encoded key
  expiration - Expiration time for signed URL formatted as a Unix Timestamp

