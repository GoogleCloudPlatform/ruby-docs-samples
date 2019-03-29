<img src="https://avatars2.githubusercontent.com/u/2810941?v=3&s=96" alt="Google Cloud Platform logo" title="Google Cloud Platform" align="right" height="96" width="96"/>

# Google Cloud Pub/Sub Ruby Samples

[Google Cloud Pub/Sub][language_docs] is a simple, reliable, scalable foundation for stream analytics 
and event-driven computing systems.

[language_docs]: https://cloud.google.com/pubsub/docs/

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

Next, set the `GOOGLE_CLOUD_PROJECT` environment variable to the project name
set in the [Google Cloud Platfrom Developer COnsole](https://console.cloud.google.com):

    export GOOGLE_CLOUD_PROJECT="YOUR-PROJECT-ID"

### Install Dependencies

1. Install the [Bundler](http://bundler.io) gem.

1. Install dependencies using:

    `bundle install`

## Run samples

Deploy the push listener:

    gcloud app deploy --promote

Run the sample for using topics:

    bundle exec ruby topics.rb

Usage:

    bundle exec ruby topics.rb [command] [arguments]

    Commands:
    create_topic                                    <project_id> <topic_name>                     Create a topic
    list_topics                                     <project_id>                                  List topics in a project
    list_topic_subscriptions                        <project_id> <topic_name>                     List subscriptions in a topic
    delete_topic                                    <project_id> <topic_name>                     Delete topic policies
    get_topic_policy                                <project_id> <topic_name>                     Get topic policies
    set_topic_policy                                <project_id> <topic_name>                     Set topic policies
    test_topic_permissions                          <project_id> <topic_name>                     Test topic permissions
    create_pull_subscription                        <project_id> <topic_name> <subscription_name> Create a pull subscription
    create_push_subscription                        <project_id> <topic_name> <subscription_name> Create a push subscription
    publish_message                                 <project_id> <topic_name>                     Publish message 
    publish_messages_with_batch_settings            <project_id> <topic_name>                     Publish messages in batch
    publish_message_async                           <project_id> <topic_name>                     Publish messages asynchronously
    publish_messages_async_with_batch_settings      <project_id> <topic_name>                     Publish messages asynchronously in batch
    publish_message_async_with_custom_attributes    <project_id> <topic_name>                     Publish messages asynchronously with custom attributes
    publish_messages_async_with_concurrency_control <project_id> <topic_name>                     Publish messages asynchronously with concurrency control

Example:

    bundle exec ruby topics.rb create_topic YOUR-PROJECT-ID new_topic

    Topic new_topic created.

Run the sample for using subscriptions:

    bundle exec ruby subscriptions.rb

Usage:

    bundle exec ruby subscriptions.rb [command] [arguments]

    Commands:
    update_push_configuration                    <project_id> <subscription_name> <endpoint> Update the endpoint of a push subscription
    list_subscriptions                           <project_id>                                List subscriptions of a project
    delete_subscription                          <project_id> <subscription_name>            Delete a subscription
    get_subscription_policy                      <project_id> <subscription_name>            Get policies of a subscription
    set_subscription_policy                      <project_id> <subscription_name>            Set policies of a subscription
    test_subscription_policy                     <project_id> <subscription_name>            Test policies of a subscription
    listen_for_messages                          <project_id> <subscription_name>            Listen for messages
    listen_for_messages_with_custom_attributes   <project_id> <subscription_name>            Listen for messages with custom attributes
    pull_messages                                <project_id> <subscription_name>            Pull messages
    listen_for_messages_with_error_handler       <project_id> <subscription_name>            Listen for messages with an error handler
    listen_for_messages_with_flow_control        <project_id> <subscription_name>            Listen for messages with flow control
    listen_for_messages_with_concurrency_control <project_id> <subscription_name>            Listen for messages with concurrency control

Example:

    bundle exec ruby subscriptions.rb list_subscriptions YOUR-PROJECT-ID

    Subscriptions:
    YOUR-SUBSCRIPTION


## Test samples

Test the sample:

    bundle exec rspec

You will see messages pushed to the listener in
[Google Cloud Logging](https://cloud.google.com/logging/docs/).
