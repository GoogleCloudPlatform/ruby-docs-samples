# Cloud Pub/Sub Sample

Set the environment variable `GOOGLE_CLOUD_PROJECT` to your Google Cloud
Platform project ID.

Test:

```bash
$ bundle exec rspec
```

Deploy the push listener:

```bash
$ gcloud app deploy --promote
```

You will see messages pushed to the listener in
[Google Cloud Logging](https://cloud.google.com/logging/docs/).

## Samples

### Topics

```
Usage: ruby topics.rb <command> [arguments]

Commands:
  list                                 Lists all topics in the current project.
  create <topic_name>                  Creates a new topic.
  delete <topic_name>                  Deletes a topic.
  publish <topic_name> <data>          Publishes a message.
  get-policy <topic_name>              Gets the IAM policy for a topic.
  set-policy <topic_name>              Sets the IAM policy for a topic.
  test-permissions <topic_name>        Tests the permissions for a topic.
```

### Subscriptions

```
Usage: ruby subscriptions.rb <command> [arguments]

Commands:
  list [topic_name]                              Lists all subscriptions in the current project, optionally filtering by a topic.
  create <topic_name> <subscription_name>        Creates a new subscription.
  create-push <topic_name> <subscription_name>   Creates a new push subscription.
  delete <subscription_name>                     Deletes a subscription.
  get <subscription_name>                        Gets the metadata for a subscription.
  pull <subscription_name>                       Pulls messages.
  get-policy <subscription_name>                 Gets the IAM policy for a subscription.
  set-policy <subscription_name>                 Sets the IAM policy for a subscription.
  test-permissions <subscription_name>           Tests the permissions for a subscription.
```