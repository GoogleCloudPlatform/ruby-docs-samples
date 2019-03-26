# Copyright 2018 Google, Inc
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

require "google/cloud/pubsub"

def create_topic project_id:, topic_name:
  # [START pubsub_create_topic]
  # project_id = "Your Google Cloud Project ID"
  # topic_name = "Your Pubsub topic name"
  require "google/cloud/pubsub"

  pubsub = Google::Cloud::Pubsub.new project: project_id

  topic  = pubsub.create_topic topic_name

  puts "Topic #{topic.name} created."
  # [END pubsub_create_topic]
end

def list_topics project_id:
  # [START pubsub_list_topics]
  # project_id = "Your Google Cloud Project ID"
  require "google/cloud/pubsub"

  pubsub = Google::Cloud::Pubsub.new project: project_id

  topics = pubsub.topics

  puts "Topics in project:"
  topics.each do |topic|
    puts topic.name
  end
  # [END pubsub_list_topics]
end

def list_topic_subscriptions project_id:, topic_name:
  # [START pubsub_list_topic_subscriptions]
  # project_id = "Your Google Cloud Project ID"
  # topic_name = "Your Pubsub topic name"
  require "google/cloud/pubsub"

  pubsub = Google::Cloud::Pubsub.new project: project_id

  topic         = pubsub.topic topic_name
  subscriptions = topic.subscriptions

  puts "Subscriptions in topic #{topic.name}:"
  subscriptions.each do |subscription|
    puts subscription.name
  end
  # [END pubsub_list_topic_subscriptions]
end

def delete_topic project_id:, topic_name:
  # [START pubsub_delete_topic]
  # project_id = "Your Google Cloud Project ID"
  # topic_name = "Your Pubsub topic name"
  require "google/cloud/pubsub"

  pubsub = Google::Cloud::Pubsub.new project: project_id

  topic = pubsub.topic topic_name
  topic.delete

  puts "Topic #{topic_name} deleted."
  # [END pubsub_delete_topic]
end

def get_topic_policy project_id:, topic_name:
  # [START pubsub_get_topic_policy]
  # project_id = "Your Google Cloud Project ID"
  # topic_name = "Your Pubsub topic name"
  require "google/cloud/pubsub"

  pubsub = Google::Cloud::Pubsub.new project: project_id

  topic  = pubsub.topic topic_name
  policy = topic.policy

  puts "Topic policy:"
  puts policy.roles
  # [END pubsub_get_topic_policy]
end

def set_topic_policy project_id:, topic_name:
  # [START pubsub_set_topic_policy]
  # project_id = "Your Google Cloud Project ID"
  # topic_name = "Your Pubsub topic name"
  require "google/cloud/pubsub"

  pubsub = Google::Cloud::Pubsub.new project: project_id

  topic = pubsub.topic topic_name
  topic.policy do |policy|
    policy.add "roles/pubsub.publisher",
               "serviceAccount:account_name@project_name.iam.gserviceaccount.com"
  end
  # [END pubsub_set_topic_policy]
end

def test_topic_permissions project_id:, topic_name:
  # [START pubsub_test_topic_permissions]
  # project_id = "Your Google Cloud Project ID"
  # topic_name = "Your Pubsub topic name"
  require "google/cloud/pubsub"

  pubsub = Google::Cloud::Pubsub.new project: project_id

  topic       = pubsub.topic topic_name
  permissions = topic.test_permissions "pubsub.topics.attachSubscription",
                                       "pubsub.topics.publish", "pubsub.topics.update"

  puts "Permission to attach subscription" if permissions.include? "pubsub.topics.attachSubscription"
  puts "Permission to publish" if permissions.include? "pubsub.topics.publish"
  puts "Permission to update" if permissions.include? "pubsub.topics.update"
  # [END pubsub_test_topic_permissions]
end

def create_pull_subscription project_id:, topic_name:, subscription_name:
  # [START pubsub_create_pull_subscription]
  # project_id        = "Your Google Cloud Project ID"
  # topic_name        = "Your Pubsub topic name"
  # subscription_name = "Your Pubsub subscription name"
  require "google/cloud/pubsub"

  pubsub = Google::Cloud::Pubsub.new project: project_id

  topic        = pubsub.topic topic_name
  subscription = topic.subscribe subscription_name

  puts "Pull subscription #{subscription_name} created."
  # [END pubsub_create_pull_subscription]
end

def create_push_subscription project_id:, topic_name:, subscription_name:, endpoint:
  # [START pubsub_create_push_subscription]
  # project_id        = "Your Google Cloud Project ID"
  # topic_name        = "Your Pubsub topic name"
  # subscription_name = "Your Pubsub subscription name"
  # endpoint          = "Endpoint where your app receives messages"
  require "google/cloud/pubsub"

  pubsub = Google::Cloud::Pubsub.new project: project_id

  topic        = pubsub.topic topic_name
  subscription = topic.subscribe subscription_name,
                                 endpoint: endpoint

  puts "Push subscription #{subscription_name} created."
  # [END pubsub_create_push_subscription]
end

def publish_message project_id:, topic_name:
  # [START pubsub_quickstart_publisher]
  # project_id = "Your Google Cloud Project ID"
  # topic_name = "Your Pubsub topic name"
  require "google/cloud/pubsub"

  pubsub = Google::Cloud::Pubsub.new project: project_id

  topic = pubsub.topic topic_name
  topic.publish "This is a test message."

  puts "Message published."
  # [END pubsub_quickstart_publisher]
end

def publish_messages_with_batch_settings project_id:, topic_name:
  # [START pubsub_publisher_batch_settings]
  # project_id = "Your Google Cloud Project ID"
  # topic_name = "Your Pubsub topic name"
  require "google/cloud/pubsub"

  pubsub = Google::Cloud::Pubsub.new project: project_id

  topic = pubsub.topic topic_name
  topic.publish do |batch|
    10.times do |i|
      batch.publish "This is message \##{i}."
    end
  end

  puts "Messages published in batch."
  # [END pubsub_publisher_batch_settings]
end

def publish_message_async project_id:, topic_name:
  # [START pubsub_publish]
  # project_id = "Your Google Cloud Project ID"
  # topic_name = "Your Pubsub topic name"
  require "google/cloud/pubsub"

  pubsub = Google::Cloud::Pubsub.new project: project_id

  topic = pubsub.topic topic_name
  topic.publish_async "This is a test message." do |result|
    raise "Failed to publish the message." unless result.succeeded?
    puts "Message published asynchronously."
  end

  # Stop the async_publisher to send all queued messages immediately.
  topic.async_publisher.stop.wait!
  # [END pubsub_publish]
end

def publish_message_async_with_custom_attributes project_id:, topic_name:
  # [START pubsub_publish_custom_attributes]
  # project_id = "Your Google Cloud Project ID"
  # topic_name = "Your Pubsub topic name"
  require "google/cloud/pubsub"

  pubsub = Google::Cloud::Pubsub.new project: project_id

  topic = pubsub.topic topic_name
  # Add two attributes, origin and username, to the message
  topic.publish_async "This is a test message.",
                      origin:   "ruby-sample",
                      username: "gcp" do |result|
    raise "Failed to publish the message." unless result.succeeded?
    puts "Message with custom attributes published asynchronously."
  end

  # Stop the async_publisher to send all queued messages immediately.
  topic.async_publisher.stop.wait!
  # [END pubsub_publish_custom_attributes]
end

def publish_messages_async_with_batch_settings project_id:, topic_name:
  # [START pubsub_publisher_batch_settings]
  # project_id = "Your Google Cloud Project ID"
  # topic_name = "Your Pubsub topic name"
  require "google/cloud/pubsub"

  pubsub = Google::Cloud::Pubsub.new project: project_id

  # Start sending messages in one request once the size of all queued messages
  # reaches 1 MB or the number of queued messages reaches 20
  topic = pubsub.topic topic_name, async: {
    max_bytes:    1_000_000,
    max_messages: 20
  }
  10.times do |i|
    topic.publish_async "This is message \##{i}."
  end

  # Stop the async_publisher to send all queued messages immediately.
  topic.async_publisher.stop.wait!
  puts "Messages published asynchronously in batch."
  # [END pubsub_publisher_batch_settings]
end

def publish_messages_async_with_concurrency_control project_id:, topic_name:
  # [START pubsub_publisher_concurrency_control]
  # project_id = "Your Google Cloud Project ID"
  # topic_name = "Your Pubsub topic name"
  require "google/cloud/pubsub"

  pubsub = Google::Cloud::Pubsub.new project: project_id

  topic = pubsub.topic topic_name, async: {
    threads: {
      # Use exactly one thread for publishing message and exactly one thread
      # for executing callbacks
      publish:  1,
      callback: 1
    }
  }
  topic.publish_async "This is a test message." do |result|
    raise "Failed to publish the message." unless result.succeeded?
    puts "Message published asynchronously."
  end

  # Stop the async_publisher to send all queued messages immediately.
  topic.async_publisher.stop.wait!
  # [END pubsub_publisher_concurrency_control]
end

if $PROGRAM_NAME == __FILE__
  case ARGV.shift
  when "create_topic"
    create_topic project_id: ARGV.shift,
                 topic_name: ARGV.shift
  when "list_topics"
    list_topics project_id: ARGV.shift
  when "list_topic_subscriptions"
    list_topic_subscriptions project_id: ARGV.shift,
                             topic_name: ARGV.shift
  when "delete_topic"
    delete_topic project_id: ARGV.shift,
                 topic_name: ARGV.shift
  when "get_topic_policy"
    get_topic_policy project_id: ARGV.shift,
                     topic_name: ARGV.shift
  when "set_topic_policy"
    set_topic_policy project_id: ARGV.shift,
                     topic_name: ARGV.shift
  when "test_topic_permissions"
    test_topic_permissions project_id: ARGV.shift,
                           topic_name: ARGV.shift
  when "create_pull_subscription"
    create_pull_subscription project_id:        ARGV.shift,
                             topic_name:        ARGV.shift,
                             subscription_name: ARGV.shift
  when "create_push_subscription"
    create_push_subscription project_id:        ARGV.shift,
                             topic_name:        ARGV.shift,
                             subscription_name: ARGV.shift
  when "publish_message"
    publish_message project_id: ARGV.shift,
                    topic_name: ARGV.shift
  when "publish_messages_with_batch_settings"
    publish_messages_with_batch_settings project_id: ARGV.shift,
                                         topic_name: ARGV.shift
  when "publish_message_async"
    publish_message_async project_id: ARGV.shift,
                          topic_name: ARGV.shift
  when "publish_message_async_with_custom_attributes"
    publish_message_async_with_custom_attributes project_id: ARGV.shift,
                                                 topic_name: ARGV.shift
  when "publish_messages_async_with_batch_settings"
    publish_messages_with_batch_settings project_id: ARGV.shift,
                                         topic_name: ARGV.shift
  when "publish_messages_async_with_concurrency_control"
    publish_messages_async_with_concurrency_control project_id: ARGV.shift,
                                                    topic_name: ARGV.shift
  else
    puts <<~USAGE
      Usage: bundle exec ruby topics.rb [command] [arguments]

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
        publish_message_async_with_custom_attributes    <project_id> <topic_name>                     Publish messages asynchronously with custom attributes
        publish_messages_async_with_batch_settings      <project_id> <topic_name>                     Publish messages asynchronously in batch
        publish_messages_async_with_concurrency_control <project_id> <topic_name>                     Publish messages asynchronously with concurrency control
    USAGE
  end
end
