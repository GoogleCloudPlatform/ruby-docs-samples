<img src="https://avatars2.githubusercontent.com/u/2810941?v=3&s=96" alt="Google Cloud Platform logo" title="Google Cloud Platform" align="right" height="96" width="96"/>

# Google Cloud Security Command Center Ruby Samples

[Google Cloud Security Command Center][language_docs] is a comprehensive security management and data risk platform for Google Cloud.

[language_docs]: https://cloud.google.com/security-command-center/docs

## Setup

### Authentication

Authentication is typically done through [Application Default Credentials](https://cloud.google.com/docs/authentication#getting_credentials_for_server-centric_flow)
, which means you do not have to change the code to authenticate as long as your
environment has credentials. You have a few options for setting up
authentication:

1. When running locally, use the [Google Cloud SDK](https://cloud.google.com/sdk/)

    `gcloud auth application-default login`

1. You can create a [Service Account key file](https://cloud.google.com/docs/authentication#service_accounts)
. This file can be used to authenticate to Google Cloud Platform services from
any environment. To use the file, set the `GOOGLE_APPLICATION_CREDENTIALS`
environment variable to the path to the key file, for example:

    `export GOOGLE_APPLICATION_CREDENTIALS=/path/to/service_account.json`

### Install Dependencies

1. Install the [Bundler](http://bundler.io) gem.

1. Install dependencies using:

    `bundle install`

## Run Samples

Run the sample for using topics:

    bundle exec ruby notification.rb

    Usage: bundle exec ruby notification.rb [command] [arguments]

    Commands:
      create_notification_config  <org_id> <config_id> <pubsub_topic>                Creates a Notification config
      delete_notification_config  <org_id> <config_id>                               Deletes a Notification config
      get_notification_config     <org_id> <config_id>                               Fetches a Notification config
      update_notification_config  <org_id> <config_id> <description> <pubsub_topic> <filter>  Updates a Notification config
      list_notification_configs   <org_id>                                           Lists Notification configs in an organization

For example:

    create_notification_config 123 config-id projects/my-project/topics/my-topic

## Test samples

Test the sample:

    bundle exec rspec
