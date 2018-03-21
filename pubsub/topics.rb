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
  # [START create_topic]
  # project_id = "Your Google Cloud Project ID"
  # topic_name = "Your Pubsub topic name"
  require "google/cloud/pubsub"

  pubsub = Google::Cloud::Pubsub.new project: project_id

  topic  = pubsub.create_topic topic_name

  puts "Topic #{topic.name} created."
  # [END create_topic]
end

def list_topics project_id:
  # [START list_topics]
  # project_id = "Your Google Cloud Project ID"
  require "google/cloud/pubsub"

  pubsub = Google::Cloud::Pubsub.new project: project_id

  topics = pubsub.topics

  puts "Topics in project:"
  topics.each do |topic|
    puts topic.name
  end
  # [END list_topics]
end

def list_topic_subscriptions project_id:, topic_name:
  # [START list_topic_subscriptions]
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
  # [END list_topic_subscriptions]
end

def delete_topic project_id:, topic_name:
  # [START delete_topic]
  # project_id = "Your Google Cloud Project ID"
  # topic_name = "Your Pubsub topic name"
  require "google/cloud/pubsub"

  pubsub = Google::Cloud::Pubsub.new project: project_id

  topic = pubsub.topic topic_name
  topic.delete

  puts "Topic #{topic_name} deleted."
  # [END delete_topic]
end

def get_topic_policy project_id:, topic_name:
  # [START get_topic_policy]
  # project_id = "Your Google Cloud Project ID"
  # topic_name = "Your Pubsub topic name"
  require "google/cloud/pubsub"

  pubsub = Google::Cloud::Pubsub.new project: project_id

  topic  = pubsub.topic topic_name
  policy = topic.policy

  puts "Topic policy:"
  puts policy.roles
  # [END get_topic_policy]
end

def set_topic_policy project_id:, topic_name:
  # [START set_topic_policy]
  # project_id = "Your Google Cloud Project ID"
  # topic_name = "Your Pubsub topic name"
  require "google/cloud/pubsub"

  pubsub = Google::Cloud::Pubsub.new project: project_id

  topic = pubsub.topic topic_name
  topic.policy do |policy|
    policy.add "roles/pubsub.publisher", 
      "serviceAccount:account_name@project_name.iam.gserviceaccount.com"
  end
  # [END set_topic_policy]
end

def test_topic_permissions project_id:, topic_name:
  # [START test_topic_permissions]
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
  # [END test_topic_permissions]
end

def create_pull_subscription project_id:, topic_name:, subscription_name:
  # [START create_pull_subscription]
  # project_id        = "Your Google Cloud Project ID"
  # topic_name        = "Your Pubsub topic name"
  # subscription_name = "Your Pubsub subscription name"
  require "google/cloud/pubsub"

  pubsub = Google::Cloud::Pubsub.new project: project_id

  topic        = pubsub.topic topic_name
  subscription = topic.subscribe subscription_name

  puts "Pull subscription #{subscription_name} created."
  # [END create_pull_subscription]
end

def create_push_subscription project_id:, topic_name:, subscription_name:, endpoint:
  # [START create_push_subscription]
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
  # [END create_push_subscription]
end

def publish_message project_id:, topic_name:
  # [START publish_message] 
  # project_id = "Your Google Cloud Project ID"
  # topic_name = "Your Pubsub topic name"
  require "google/cloud/pubsub"

  pubsub = Google::Cloud::Pubsub.new project: project_id

  topic = pubsub.topic topic_name
  topic.publish data: "This is a test message."

  puts "Message published."
  # [END publish_message]
end

def publish_messages_with_batch_settings project_id:, topic_name:
  # [START publish_messages_with_batch_settings]
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
  # [END publish_messages_with_batch_settings]
end

def publish_message_async project_id:, topic_name:
  # [START publish_message_async]
  # project_id = "Your Google Cloud Project ID"
  # topic_name = "Your Pubsub topic name"
  require "google/cloud/pubsub"

  pubsub = Google::Cloud::Pubsub.new project: project_id

  topic = pubsub.topic topic_name
  topic.publish_async "This is a test message." do |result|
    if result.succeeded?
      puts "Message published asynchronously."
    else
      raise "Failed to publish the message."
    end
  end

  # Stop the async_publisher to send all queued messages immediately.
  topic.async_publisher.stop.wait!
  # [END publish_message_async]
end

def publish_messages_async_with_batch_settings project_id:, topic_name:
  # [START publish_messages_async_with_batch_settings]
  # project_id = "Your Google Cloud Project ID"
  # topic_name = "Your Pubsub topic name"
  require "google/cloud/pubsub"

  pubsub = Google::Cloud::Pubsub.new project: project_id

  # Start sending messages in one request once the size of all queued messages
  # reaches 1 MB or the number of queued messages reaches 20
  topic = pubsub.topic topic_name, async: {
    :max_bytes => 1000000,
    :max_messages => 20
  }
  10.times do |i|
    topic.publish_async "This is message \##{i}."
  end

  # Stop the async_publisher to send all queued messages immediately.
  topic.async_publisher.stop.wait!
  puts "Messages published asynchronously in batch."
  # [END publish_messages_async_with_batch_settings]
end

def publish_messages_async_with_concurrency_control project_id:, topic_name:
  # [START publish_messages_async_with_concurrency_control]
  # project_id = "Your Google Cloud Project ID"
  # topic_name = "Your Pubsub topic name"
  require "google/cloud/pubsub"

  pubsub = Google::Cloud::Pubsub.new project: project_id

  topic = pubsub.topic topic_name, async: {
    :threads => {
      # Use exactly one thread for publishing message and exactly one thread
      # for executing callbacks
      :publish => 1,
      :callback => 1
    }
  }
  topic.publish_async "This is a test message." do |result|
    if result.succeeded?
      puts "Message published asynchronously."
    else
      raise "Failed to publish the message."
    end
  end

  # Stop the async_publisher to send all queued messages immediately.
  topic.async_publisher.stop.wait!
  # [END publish_messages_async_with_concurrency_control]
end

if __FILE__ == $PROGRAM_NAME
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
    create_pull_subscription project_id: ARGV.shift,
                             topic_name: ARGV.shift,
                             subscription_name: ARGV.shift
  when "create_push_subscription"
    create_push_subscription project_id: ARGV.shift,
                             topic_name: ARGV.shift,
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
  when "publish_messages_async_with_batch_settings"
    publish_messages_with_batch_settings project_id: ARGV.shift,
                                         topic_name: ARGV.shift
  when "publish_messages_async_with_concurrency_control"
    publish_messages_async_with_concurrency_control project_id: ARGV.shift, 
                                                    topic_name: ARGV.shift
  else
    puts <<-usage
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
  publish_messages_async_with_batch_settings      <project_id> <topic_name>                     Publish messages asynchronously in batch
  publish_messages_async_with_concurrency_control <project_id> <topic_name>                     Publish messages asynchronously with concurrency control
    usage
  end
end
