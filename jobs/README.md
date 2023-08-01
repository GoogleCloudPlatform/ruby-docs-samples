<img src="https://avatars2.githubusercontent.com/u/2810941?v=3&s=96" alt="Google Cloud Platform logo" title="Google Cloud Platform" align="right" height="96" width="96"/>

# Google Cloud Job Discovery API Samples

The [Cloud Job Discovery API][jobs_docs] is part of Google for Jobs - a Google-wide 
commitment to help people find jobs more easily. Job Discovery provides plug and play 
access to Google’s search and machine learning capabilities, enabling the entire 
recruiting ecosystem - company career sites, job boards, applicant tracking systems, 
and staffing agencies to improve job site engagement and candidate conversion.

[jobs_docs]: https://cloud.google.com/job-discovery/docs/

## Google Cloud Jobs v3 is [deprecated](https://cloud.google.com/talent-solution/job-search/docs/migrate). Please refer [google-cloud-talent](https://github.com/googleapis/google-cloud-ruby/tree/main/google-cloud-talent) for newer implementation. 

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

### Install Dependencies

1. Install the [Bundler](http://bundler.io/) gem.

1. Install dependencies using:

    `bundle install`

## Run samples

### Quickstart

    `ruby quickstart.rb`

## Contributing changes

* See [CONTRIBUTING.md](../../CONTRIBUTING.md)

## Licensing

* See [LICENSE](../../LICENSE)
