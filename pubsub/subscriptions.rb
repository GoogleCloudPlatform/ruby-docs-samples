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

def update_push_configuration project_id:, subscription_name:, new_endpoint:
  # [START pubsub_update_push_configuration]
  # project_id        = "Your Google Cloud Project ID"
  # subscription_name = "Your Pubsub subscription name"
  # new_endpoint      = "Endpoint where your app receives messages""
  require "google/cloud/pubsub"

  pubsub = Google::Cloud::Pubsub.new project: project_id

  subscription          = pubsub.subscription subscription_name
  subscription.endpoint = new_endpoint

  puts "Push endpoint updated."
  # [END pubsub_update_push_configuration]
end

def list_subscriptions project_id:
  # [START pubsub_list_subscriptions]
  # project_id = Your Google Cloud Project ID
  require "google/cloud/pubsub"

  pubsub = Google::Cloud::Pubsub.new project: project_id

  subscriptions = pubsub.list_subscriptions

  puts "Subscriptions:"
  subscriptions.each do |subscription|
    puts subscription.name
  end
  # [END pubsub_list_subscriptions]
end

def delete_subscription project_id:, subscription_name:
  # [START pubsub_delete_subscription]
  # project_id        = "Your Google Cloud Project ID"
  # subscription_name = "Your Pubsub subscription name"
  require "google/cloud/pubsub"

  pubsub = Google::Cloud::Pubsub.new project: project_id

  subscription = pubsub.subscription subscription_name
  subscription.delete

  puts "Subscription #{subscription_name} deleted."
  # [END pubsub_delete_subscription]
end

def get_subscription_policy project_id:, subscription_name:
  # [START pubsub_get_subscription_policy]
  # project_id        = "Your Google Cloud Project ID"
  # subscription_name = "Your Pubsub subscription name"
  require "google/cloud/pubsub"

  pubsub = Google::Cloud::Pubsub.new project: project_id

  subscription = pubsub.subscription subscription_name
  policy       = subscription.policy

  puts "Subscription policy:"
  puts policy.roles
  # [END pubsub_get_subscription_policy]
end

def set_subscription_policy project_id:, subscription_name:
  # [START pubsub_set_subscription_policy]
  # project_id        = "Your Google Cloud Project ID"
  # subscription_name = "Your Pubsub subscription name"
  require "google/cloud/pubsub"

  pubsub = Google::Cloud::Pubsub.new project: project_id

  subscription = pubsub.subscription subscription_name
  subscription.policy do |policy|
    policy.add "roles/pubsub.subscriber",
               "serviceAccount:account-name@project-name.iam.gserviceaccount.com"
  end
  # [END pubsub_set_subscription_policy]
end

def test_subscription_permissions project_id:, subscription_name:
  # [START pubsub_test_subscription_permissions]
  # project_id        = "Your Google Cloud Project ID"
  # subscription_name = "Your Pubsub subscription name"
  require "google/cloud/pubsub"

  pubsub = Google::Cloud::Pubsub.new project: project_id

  subscription = pubsub.subscription subscription_name
  permissions  = subscription.test_permissions "pubsub.subscriptions.consume",
                                               "pubsub.subscriptions.update"

  puts "Permission to consume" if permissions.include? "pubsub.subscriptions.consume"
  puts "Permission to update" if permissions.include? "pubsub.subscriptions.update"
  # [END pubsub_test_subscription_permissions]
end

def listen_for_messages project_id:, subscription_name:
  # [START pubsub_quickstart_subscriber]
  # project_id        = "Your Google Cloud Project ID"
  # subscription_name = "Your Pubsub subscription name"
  require "google/cloud/pubsub"

  pubsub = Google::Cloud::Pubsub.new project: project_id

  subscription = pubsub.subscription subscription_name
  subscriber   = subscription.listen do |received_message|
    puts "Received message: #{received_message.data}"
    received_message.acknowledge!
  end

  subscriber.start
  # Let the main thread sleep for 60 seconds so the thread for listening
  # messages does not quit
  sleep 60
  subscriber.stop.wait!
  # [END pubsub_quickstart_subscriber]
end

def listen_for_messages_with_custom_attributes project_id:, subscription_name:
  # [START pubsub_subscriber_sync_pull_custom_attributes]
  # project_id        = "Your Google Cloud Project ID"
  # subscription_name = "Your Pubsub subscription name"
  require "google/cloud/pubsub"

  pubsub = Google::Cloud::Pubsub.new project: project_id

  subscription = pubsub.subscription subscription_name
  subscriber   = subscription.listen do |received_message|
    puts "Received message: #{received_message.data}"
    unless received_message.attributes.empty?
      puts "Attributes:"
      received_message.attributes.each do |key, value|
        puts "#{key}: #{value}"
      end
    end
    received_message.acknowledge!
  end

  subscriber.start
  # Let the main thread sleep for 60 seconds so the thread for listening
  # messages does not quit
  sleep 60
  subscriber.stop.wait!
  # [END pubsub_subscriber_sync_pull_custom_attributes]
end

def pull_messages project_id:, subscription_name:
  # [START pubsub_subscriber_sync_pull]
  # project_id        = "Your Google Cloud Project ID"
  # subscription_name = "Your Pubsub subscription name"
  require "google/cloud/pubsub"

  pubsub = Google::Cloud::Pubsub.new project: project_id

  subscription = pubsub.subscription subscription_name
  subscription.pull.each do |message|
    puts "Message pulled: #{message.data}"
    message.acknowledge!
  end
  # [END pubsub_subscriber_sync_pull]
end

def listen_for_messages_with_error_handler project_id:, subscription_name:
  # [START pubsub_subscriber_error_listener]
  # project_id        = "Your Google Cloud Project ID"
  # subscription_name = "Your Pubsub subscription name"
  require "google/cloud/pubsub"

  pubsub = Google::Cloud::Pubsub.new project: project_id

  subscription = pubsub.subscription subscription_name
  subscriber   = subscription.listen do |received_message|
    puts "Received message: #{received_message.data}"
    received_message.acknowledge!
  end
  # Propagate expection from child threads to the main thread as soon as it is
  # raised. Exceptions happened in the callback thread are collected in the
  # callback thread pool and do not propagate to the main thread
  Thread.abort_on_exception = true

  begin
    subscriber.start
    # Let the main thread sleep for 60 seconds so the thread for listening
    # messages does not quit
    sleep 60
    subscriber.stop.wait!
  rescue Exception => ex
    puts "Exception #{ex.inspect}: #{ex.message}"
    raise "Stopped listening for messages."
  end
  # [END pubsub_subscriber_error_listener]
end

def listen_for_messages_with_flow_control project_id:, subscription_name:
  # [START pubsub_subscriber_flow_settings]
  # project_id        = "Your Google Cloud Project ID"
  # subscription_name = "Your Pubsub subscription name"
  require "google/cloud/pubsub"

  pubsub = Google::Cloud::Pubsub.new project: project_id

  subscription = pubsub.subscription subscription_name
  subscriber   = subscription.listen inventory: 10 do |received_message|
    puts "Received message: #{received_message.data}"
    received_message.acknowledge!
  end

  subscriber.start
  # Let the main thread sleep for 60 seconds so the thread for listening
  # messages does not quit
  sleep 60
  subscriber.stop.wait!
  # [END pubsub_subscriber_flow_settings]
end

def listen_for_messages_with_concurrency_control project_id:, subscription_name:
  # [START pubsub_subscriber_concurrency_control]
  # project_id        = "Your Google Cloud Project ID"
  # subscription_name = "Your Pubsub subscription name"
  require "google/cloud/pubsub"

  pubsub = Google::Cloud::Pubsub.new project: project_id

  subscription = pubsub.subscription subscription_name
  # Use 2 threads for streaming, 4 threads for executing callbacks and 2 threads
  # for sending acknowledgements and/or delays
  subscriber   = subscription.listen streams: 2, threads: {
    callback: 4,
    push:     2
  } do |received_message|
    puts "Received message: #{received_message.data}"
    received_message.acknowledge!
  end

  subscriber.start
  # Let the main thread sleep for 60 seconds so the thread for listening
  # messages does not quit
  sleep 60
  subscriber.stop.wait!
  # [END pubsub_subscriber_concurrency_control]
end

if $PROGRAM_NAME == __FILE__
  case ARGV.shift
  when "update_push_configuration"
    update_push_configuration project_id:        ARGV.shift,
                              subscription_name: ARGV.shift,
                              new_endpoint:      ARGV.shift
  when "list_subscriptions"
    list_subscriptions project_id: ARGV.shift
  when "delete_subscription"
    delete_subscription project_id:        ARGV.shift,
                        subscription_name: ARGV.shift
  when "get_subscription_policy"
    get_subscription_policy project_id:        ARGV.shift,
                            subscription_name: ARGV.shift
  when "set_subscription_policy"
    set_subscription_policy project_id:        ARGV.shift,
                            subscription_name: ARGV.shift
  when "test_subscription_permissions"
    test_subscription_permissions project_id:        ARGV.shift,
                                  subscription_name: ARGV.shift
  when "listen_for_messages"
    listen_for_messages project_id:        ARGV.shift,
                        subscription_name: ARGV.shift
  when "listen_for_messages_with_custom_attributes"
    listen_for_messages_with_custom_attributes project_id:        ARGV.shift,
                                               subscription_name: ARGV.shift
  when "pull_messages"
    pull_messages project_id:        ARGV.shift,
                  subscription_name: ARGV.shift
  when "listen_for_messages_with_error_handler"
    listen_for_messages_with_error_handler project_id:        ARGV.shift,
                                           subscription_name: ARGV.shift
  when "listen_for_messages_with_flow_control"
    listen_for_messages_with_flow_control project_id:        ARGV.shift,
                                          subscription_name: ARGV.shift
  when "listen_for_messages_with_concurrency_control"
    listen_for_messages_with_concurrency_control project_id:        ARGV.shift,
                                                 subscription_name: ARGV.shift
  else
    puts <<~USAGE
      Usage: bundle exec ruby subscriptions.rb [command] [arguments]

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
    USAGE
  end
end
