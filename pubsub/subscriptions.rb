# Copyright 2019 Google, Inc
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

def update_push_configuration subscription_name:, new_endpoint:
  # [START pubsub_update_push_configuration]
  # subscription_name = "Your Pubsub subscription name"
  # new_endpoint      = "Endpoint where your app receives messages""
  require "google/cloud/pubsub"

  pubsub = Google::Cloud::Pubsub.new

  subscription          = pubsub.subscription subscription_name
  subscription.endpoint = new_endpoint

  puts "Push endpoint updated."
  # [END pubsub_update_push_configuration]
end

def list_subscriptions
  # [START pubsub_list_subscriptions]
  require "google/cloud/pubsub"

  pubsub = Google::Cloud::Pubsub.new

  subscriptions = pubsub.list_subscriptions

  puts "Subscriptions:"
  subscriptions.each do |subscription|
    puts subscription.name
  end
  # [END pubsub_list_subscriptions]
end

def delete_subscription subscription_name:
  # [START pubsub_delete_subscription]
  # subscription_name = "Your Pubsub subscription name"
  require "google/cloud/pubsub"

  pubsub = Google::Cloud::Pubsub.new

  subscription = pubsub.subscription subscription_name
  subscription.delete

  puts "Subscription #{subscription_name} deleted."
  # [END pubsub_delete_subscription]
end

def get_subscription_policy subscription_name:
  # [START pubsub_get_subscription_policy]
  # subscription_name = "Your Pubsub subscription name"
  require "google/cloud/pubsub"

  pubsub = Google::Cloud::Pubsub.new

  subscription = pubsub.subscription subscription_name
  policy       = subscription.policy

  puts "Subscription policy:"
  puts policy.roles
  # [END pubsub_get_subscription_policy]
end

def set_subscription_policy subscription_name:, role:, service_account_email:
  # [START pubsub_set_subscription_policy]
  # subscription_name = "Your Pubsub subscription name"
  # role = "roles/pubsub.publisher"
  # service_account_email = "serviceAccount:account_name@project_name.iam.gserviceaccount.com"
  require "google/cloud/pubsub"

  pubsub = Google::Cloud::Pubsub.new

  subscription = pubsub.subscription subscription_name
  subscription.policy do |policy|
    policy.add role, service_account_email
  end
  # [END pubsub_set_subscription_policy]
end

def test_subscription_permissions subscription_name:
  # [START pubsub_test_subscription_permissions]
  # subscription_name = "Your Pubsub subscription name"
  require "google/cloud/pubsub"

  pubsub = Google::Cloud::Pubsub.new

  subscription = pubsub.subscription subscription_name
  permissions  = subscription.test_permissions "pubsub.subscriptions.consume",
                                               "pubsub.subscriptions.update"

  puts "Permission to consume" if permissions.include? "pubsub.subscriptions.consume"
  puts "Permission to update" if permissions.include? "pubsub.subscriptions.update"
  # [END pubsub_test_subscription_permissions]
end

def dead_letter_update_subscription subscription_name:
  # [START pubsub_dead_letter_update_subscription]
  # subscription_name = "Your Pubsub subscription name"
  # role = "roles/pubsub.publisher"
  # service_account_email = "serviceAccount:account_name@project_name.iam.gserviceaccount.com"
  require "google/cloud/pubsub"

  pubsub = Google::Cloud::Pubsub.new

  subscription = pubsub.subscription subscription_name
  subscription.dead_letter_max_delivery_attempts = 20
  puts "Max delivery attempts is now #{subscription.dead_letter_max_delivery_attempts}."
  # [END pubsub_dead_letter_update_subscription]
end

def listen_for_messages subscription_name:
  # [START pubsub_subscriber_async_pull]
  # [START pubsub_quickstart_subscriber]
  # subscription_name = "Your Pubsub subscription name"
  require "google/cloud/pubsub"

  pubsub = Google::Cloud::Pubsub.new

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
  # [END pubsub_subscriber_async_pull]
  # [END pubsub_quickstart_subscriber]
end

def listen_for_messages_with_custom_attributes subscription_name:
  # [START pubsub_subscriber_sync_pull_custom_attributes]
  # [START pubsub_subscriber_async_pull_custom_attributes]
  # subscription_name = "Your Pubsub subscription name"
  require "google/cloud/pubsub"

  pubsub = Google::Cloud::Pubsub.new

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
  # [END pubsub_subscriber_async_pull_custom_attributes]
  # [END pubsub_subscriber_sync_pull_custom_attributes]
end

def pull_messages subscription_name:
  # [START pubsub_subscriber_sync_pull]
  # subscription_name = "Your Pubsub subscription name"
  require "google/cloud/pubsub"

  pubsub = Google::Cloud::Pubsub.new

  subscription = pubsub.subscription subscription_name
  subscription.pull.each do |message|
    puts "Message pulled: #{message.data}"
    message.acknowledge!
  end
  # [END pubsub_subscriber_sync_pull]
end

def listen_for_messages_with_error_handler subscription_name:
  # [START pubsub_subscriber_error_listener]
  # subscription_name = "Your Pubsub subscription name"
  require "google/cloud/pubsub"

  pubsub = Google::Cloud::Pubsub.new

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
  rescue Exception => e
    puts "Exception #{e.inspect}: #{e.message}"
    raise "Stopped listening for messages."
  end
  # [END pubsub_subscriber_error_listener]
end

def listen_for_messages_with_flow_control subscription_name:
  # [START pubsub_subscriber_flow_settings]
  # subscription_name = "Your Pubsub subscription name"
  require "google/cloud/pubsub"

  pubsub = Google::Cloud::Pubsub.new

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

def listen_for_messages_with_concurrency_control subscription_name:
  # [START pubsub_subscriber_concurrency_control]
  # subscription_name = "Your Pubsub subscription name"
  require "google/cloud/pubsub"

  pubsub = Google::Cloud::Pubsub.new

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

def dead_letter_delivery_attempt subscription_name:
  # [START pubsub_dead_letter_delivery_attempt]
  # subscription_name = "Your Pubsub subscription name"
  require "google/cloud/pubsub"

  pubsub = Google::Cloud::Pubsub.new

  subscription = pubsub.subscription subscription_name
  subscription.pull.each do |message|
    puts "Received message: #{message.data}"
    puts "Delivery Attempt: #{message.delivery_attempt}"
    message.acknowledge!
  end
  # [END pubsub_dead_letter_delivery_attempt]
end

if $PROGRAM_NAME == __FILE__
  case ARGV.shift
  when "update_push_configuration"
    update_push_configuration subscription_name: ARGV.shift,
                              new_endpoint:      ARGV.shift
  when "list_subscriptions"
    list_subscriptions
  when "delete_subscription"
    delete_subscription subscription_name: ARGV.shift
  when "get_subscription_policy"
    get_subscription_policy psubscription_name: ARGV.shift
  when "set_subscription_policy"
    set_subscription_policy subscription_name: ARGV.shift
  when "test_subscription_permissions"
    test_subscription_permissions subscription_name: ARGV.shift
  when "listen_for_messages"
    listen_for_messages subscription_name: ARGV.shift
  when "listen_for_messages_with_custom_attributes"
    listen_for_messages_with_custom_attributes subscription_name: ARGV.shift
  when "pull_messages"
    pull_messages subscription_name: ARGV.shift
  when "listen_for_messages_with_error_handler"
    listen_for_messages_with_error_handler subscription_name: ARGV.shift
  when "listen_for_messages_with_flow_control"
    listen_for_messages_with_flow_control subscription_name: ARGV.shift
  when "listen_for_messages_with_concurrency_control"
    listen_for_messages_with_concurrency_control subscription_name: ARGV.shift
  else
    puts <<~USAGE
      Usage: bundle exec ruby subscriptions.rb [command] [arguments]

      Commands:
        update_push_configuration                    <subscription_name> <endpoint> Update the endpoint of a push subscription
        list_subscriptions                                                          List subscriptions of a project
        delete_subscription                          <subscription_name>            Delete a subscription
        get_subscription_policy                      <subscription_name>            Get policies of a subscription
        set_subscription_policy                      <subscription_name>            Set policies of a subscription
        test_subscription_policy                     <subscription_name>            Test policies of a subscription
        listen_for_messages                          <subscription_name>            Listen for messages
        listen_for_messages_with_custom_attributes   <subscription_name>            Listen for messages with custom attributes
        pull_messages                                <subscription_name>            Pull messages
        listen_for_messages_with_error_handler       <subscription_name>            Listen for messages with an error handler
        listen_for_messages_with_flow_control        <subscription_name>            Listen for messages with flow control
        listen_for_messages_with_concurrency_control <subscription_name>            Listen for messages with concurrency control
    USAGE
  end
end
