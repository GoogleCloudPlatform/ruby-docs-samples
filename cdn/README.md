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

```
Usage: bundle exec ruby sign_url.rb <url> <key_name> <key> <expires_in>

Arguments:
  url        - URL of the endpoint served by Cloud CDN
  key_name   - Name of the signing key added to the Google Cloud Storage bucket or service
  key        - Signing key as a urlsafe base64 encoded string
  expires_in - Expire signed URL in number of seconds from current time
```

