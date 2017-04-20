# Copyright 2016 Google, Inc
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# This application demonstrates how to perform basic operations on
# subscriptions with the Google Cloud Pub/Sub API.
#
# For more information, see the README.md under /pubsub and the documentation at
# https://cloud.google.com/pubsub/docs.

require "google/cloud"

# [START pubsub_list_subscriptions]
def list_subscriptions
  # Instantiates the client library
  gcloud = Google::Cloud.new
  pubsub_client = gcloud.pubsub

  # Lists all subscriptions in the current project
  subscriptions = pubsub_client.subscriptions

  puts "Subscriptions:"
  subscriptions.each do |subscription|
    puts subscription.name
  end
end
# [END pubsub_list_subscriptions]

# [START pubsub_list_topic_subscriptions]
def list_topic_subscriptions topic_name:
  # Instantiates the client library
  gcloud = Google::Cloud.new
  pubsub_client = gcloud.pubsub

  # References an existing topic, e.g. "my-topic"
  topic = pubsub_client.topic topic_name, skip_lookup: true

  # Lists all subscriptions for the topic
  subscriptions = topic.subscriptions

  puts "Subscriptions:"
  subscriptions.each do |subscription|
    puts subscription.name
  end
end
# [END pubsub_list_topic_subscriptions]

# [START pubsub_create_subscription]
def create_subscription topic_name:, subscription_name:
  # Instantiates the client library
  gcloud = Google::Cloud.new
  pubsub_client = gcloud.pubsub

  # References an existing topic, e.g. "my-topic"
  topic = pubsub_client.topic topic_name, skip_lookup: true

  # Creates a new subscription, e.g. "my-new-subscription"
  subscription = topic.subscribe subscription_name

  puts "Subscription #{subscription.name} created."
end
# [END pubsub_create_subscription]

# [START pubsub_create_push_subscription]
def create_push_subscription topic_name:, subscription_name:
  # Instantiates the client library
  gcloud = Google::Cloud.new
  pubsub_client = gcloud.pubsub

  # References an existing topic, e.g. "my-topic"
  topic = pubsub_client.topic topic_name, skip_lookup: true

  project_id = pubsub_client.project

  # Creates a new push subscription, e.g. "my-new-subscription"
  subscription = topic.subscribe(
    subscription_name,
    # Set to an HTTPS endpoint of your choice. If necessary, register
    # (authorize) the domain on which the server is hosted.
    endpoint: "https://#{project_id}.appspot.com/push"
  )

  puts "Subscription #{subscription.name} created."
end
# [END pubsub_create_push_subscription]

# [START pubsub_delete_subscription]
def delete_subscription subscription_name:
  # Instantiates the client library
  gcloud = Google::Cloud.new
  pubsub_client = gcloud.pubsub

  # References an existing subscription, e.g. "my-subscription"
  subscription = pubsub_client.subscription subscription_name, skip_lookup: true

  # Deletes the subscription
  subscription.delete

  puts "Subscription #{subscription.name} deleted."
end
# [END pubsub_delete_subscription]

# [START pubsub_get_subscription]
def get_subscription subscription_name:
  # Instantiates the client library
  gcloud = Google::Cloud.new
  pubsub_client = gcloud.pubsub

  # Gets the metadata for an existing subscription, e.g. "my-subscription"
  subscription = pubsub_client.subscription subscription_name

  puts "Subscription: #{subscription.name}"
  puts "Topic: #{subscription.topic.name}"
  puts "Push config: #{subscription.endpoint}"
  puts "Ack deadline: #{subscription.deadline}s"
end
# [END pubsub_get_subscription]

# [START pubsub_pull_messages]
def pull_messages subscription_name:
  # Instantiates the client library
  gcloud = Google::Cloud.new
  pubsub_client = gcloud.pubsub

  # References an existing subscription, e.g. "my-subscription"
  subscription = pubsub_client.subscription subscription_name, skip_lookup: true

  # Pulls messages. Set "immediate" to false to block until messages are
  # received.
  messages = subscription.pull immediate: true

  puts "Received #{messages.length} messages."

  messages.each do |message|
    puts "* #{message.message_id} #{message.data} #{message.attributes}"
  end

  # Acknowledges received messages. If you do not acknowledge, Pub/Sub will
  # redeliver the message.
  messages.each { |message| message.acknowledge! }
end
# [END pubsub_pull_messages]

# [START pubsub_get_subscription_policy]
def get_subscription_policy subscription_name:
  # Instantiates the client library
  gcloud = Google::Cloud.new
  pubsub_client = gcloud.pubsub

  # References an existing subscription, e.g. "my-subscription"
  subscription  = pubsub_client.subscription subscription_name

  # Retrieves the IAM policy for the subscription
  policy = subscription.policy

  puts "Policy for subscription: #{policy.roles}."
end
# [END pubsub_get_subscription_policy]

# [START pubsub_set_subscription_policy]
def set_subscription_policy subscription_name:
  # Instantiates the client library
  gcloud = Google::Cloud.new
  pubsub_client = gcloud.pubsub

  # References an existing subscription, e.g. "my-subscription"
  subscription  = pubsub_client.subscription subscription_name

  # Updates the IAM policy for the subscription
  policy = subscription.policy do |p|
    # Add a group as editors
    p.add "roles/pubsub.editor", "group:cloud-logs@google.com"
    # Add all users as viewers
    p.add "roles/pubsub.viewer", "allUsers"
  end

  puts "Updated policy for subscription: #{policy.roles}."
end
# [END pubsub_set_subscription_policy]

# [START pubsub_test_subscription_permissions]
def test_subscription_permissions subscription_name:
  # Instantiates the client library
  gcloud = Google::Cloud.new
  pubsub_client = gcloud.pubsub

  # References an existing subscription, e.g. "my-subscription"
  subscription  = pubsub_client.subscription subscription_name

  # Tests the IAM policy for the specified subscription
  permissions = subscription.test_permissions "pubsub.subscriptions.consume",
                                       "pubsub.subscriptions.update"

  puts "Tested permissions for subscription: #{permissions}"
end
# [END pubsub_test_subscription_permissions]

if __FILE__ == $PROGRAM_NAME
  command = ARGV.shift

  case command
  when "list"
    topic_name = ARGV.shift
    if topic_name
      list_topic_subscriptions topic_name: topic_name
    else
      list_subscriptions
    end
  when "create"
    create_subscription topic_name: ARGV.shift, subscription_name: ARGV.shift
  when "create-push"
    create_push_subscription topic_name: ARGV.shift, subscription_name: ARGV.shift
  when "delete"
    delete_subscription subscription_name: ARGV.shift
  when "get"
    get_subscription subscription_name: ARGV.shift
  when "pull"
    pull_messages subscription_name: ARGV.shift
  when "get-policy"
    get_subscription_policy subscription_name: ARGV.shift
  when "set-policy"
    set_subscription_policy subscription_name: ARGV.shift
  when "test-permissions"
    test_subscription_permissions subscription_name: ARGV.shift
  else
    puts <<-usage
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
  usage
  end
end