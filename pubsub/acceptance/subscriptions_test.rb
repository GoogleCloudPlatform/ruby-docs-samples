# Copyright 2020 Google LLC
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

require_relative "helper"
require_relative "../subscriptions.rb"

describe "subscriptions" do
  let(:pubsub) { Google::Cloud::Pubsub.new }
  let(:topic_name) { random_topic_name }
  let(:subscription_name) { random_subscription_name }
  let(:endpoint) { "https://#{pubsub.project}.appspot.com/push" }
  let(:role) { "roles/pubsub.subscriber" }
  let(:service_account_email) { "serviceAccount:acceptance-tests@#{pubsub.project}.iam.gserviceaccount.com" }

  before :all do
    @topic = pubsub.create_topic topic_name
  end

  after :all do
    @topic.delete
  end

  before do
    @subscription = @topic.subscribe subscription_name
  end

  after do
    @subscription.delete if @subscription
  end

  it "pubsub_update_push_configuration, pubsub_list_subscriptions, pubsub_set_subscription_policy, pubsub_get_subscription_policy, pubsub_test_subscription_permissions, pubsub_delete_subscription" do
    # pubsub_update_push_configuration
    assert_output "Push endpoint updated.\n" do
      update_push_configuration subscription_name: subscription_name, new_endpoint: endpoint
    end
    subscription = @topic.subscription subscription_name
    assert subscription
    assert_equal endpoint, subscription.endpoint
    assert subscription.push_config
    assert_equal endpoint, subscription.push_config.endpoint

    # pubsub_list_subscriptions
    out, _err = capture_io do
      list_subscriptions
    end
    assert_includes out, "Subscriptions:"
    assert_includes out, "projects/#{pubsub.project}/subscriptions/"

    # pubsub_set_subscription_policy
    set_subscription_policy subscription_name: subscription.name, role: role, service_account_email: service_account_email
    subscription.reload!
    assert_equal [service_account_email], subscription.policy.roles[role]

    # pubsub_get_subscription_policy
    assert_output "Subscription policy:\n#{subscription.policy.roles}\n" do
      get_subscription_policy subscription_name: subscription_name
    end

    # pubsub_test_subscription_permissions
    assert_output "Permission to consume\nPermission to update\n" do
      test_subscription_permissions subscription_name: subscription_name
    end

    # pubsub_delete_subscription
    assert_output "Subscription #{subscription_name} deleted.\n" do
      delete_subscription subscription_name: subscription_name
    end
    @subscription = @topic.subscription subscription_name
    refute @subscription
  end

  it "pubsub_subscriber_sync_pull" do
    @topic.publish "This is a test message."

    # pubsub_subscriber_sync_pull
    expect_with_retry "pubsub_subscriber_sync_pull" do
      assert_output "Message pulled: This is a test message.\n" do
        pull_messages subscription_name: subscription_name
      end
    end
  end

  it "pubsub_subscriber_async_pull, pubsub_quickstart_subscriber" do
    @topic.publish "This is a test message."

    # pubsub_subscriber_async_pull
    # pubsub_quickstart_subscriber
    expect_with_retry "pubsub_subscriber_async_pull" do
      assert_output "Received message: This is a test message.\n" do
        listen_for_messages subscription_name: subscription_name
      end
    end
  end

  it "pubsub_subscriber_sync_pull_custom_attributes, pubsub_subscriber_async_pull_custom_attributes" do
    @topic.publish "This is a test message.", origin: "ruby-sample"

    # pubsub_subscriber_sync_pull_custom_attributes
    # pubsub_subscriber_async_pull_custom_attributes
    expect_with_retry "pubsub_spubsub_subscriber_sync_pull_custom_attributesubscriber_sync_pull" do
      out, _err = capture_io do
        listen_for_messages_with_custom_attributes subscription_name: subscription_name
      end
      assert_includes out, "Received message: This is a test message."
      assert_includes out, "Attributes:"
      assert_includes out, "origin: ruby-sample"
    end
  end

  it "pubsub_subscriber_flow_settings" do
    @topic.publish "This is a test message."

    # pubsub_subscriber_flow_settings
    expect_with_retry "pubsub_subscriber_flow_settings" do
      assert_output "Received message: This is a test message.\n" do
        listen_for_messages_with_flow_control subscription_name: subscription_name
      end
    end
  end

  it "pubsub_subscriber_concurrency_control" do
    @topic.publish "This is a test message."

    # pubsub_subscriber_concurrency_control
    expect_with_retry "pubsub_subscriber_concurrency_control" do
      assert_output "Received message: This is a test message.\n" do
        listen_for_messages_with_concurrency_control subscription_name: subscription_name
      end
    end
  end

  # Pub/Sub calls may not respond immediately.
  # Wrap expectations that may require multiple attempts with this method.
  def expect_with_retry sample_name, attempts: 2
    @attempt_number ||= 0
    yield
    @attempt_number = nil
  rescue Minitest::Assertion => e
    @attempt_number += 1
    puts "failed attempt #{@attempt_number} for #{sample_name}"
    retry if @attempt_number < attempts
    @attempt_number = nil
    raise e
  end
end
