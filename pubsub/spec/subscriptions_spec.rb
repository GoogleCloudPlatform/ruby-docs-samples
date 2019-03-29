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

require_relative "../subscriptions"
require "spec_helper"
require "rspec/retry"

RSpec.configure do |config|
  # show retry status in spec process
  config.verbose_retry = true
  # show exception that triggers a retry if verbose_retry is set to true
  config.display_try_failure_messages = true

  # set retry count and retry sleep interval to 30 seconds
  config.default_retry_count = 5
  config.default_sleep_interval = 30
end

describe "Pub/Sub subscriptions sample" do
  before do
    @pubsub                 = Google::Cloud::Pubsub.new
    @project_id             = ENV["GOOGLE_CLOUD_PROJECT"]
    @topic_name             = "my-topic"
    @pull_subscription_name = "my-pull-subscription"
    @push_subscription_name = "my-push-subscription"
    @service_account        =
      "serviceAccount:test-account@#{@pubsub.project}" +
      ".iam.gserviceaccount.com"
    cleanup!
  end

  after do
    cleanup!
  end

  def cleanup!
    topic = @pubsub.topic @topic_name
    topic&.delete
    pull_subscription = @pubsub.subscription @pull_subscription_name
    pull_subscription&.delete
    push_subscription = @pubsub.subscription @push_subscription_name
    push_subscription&.delete
  end

  # Pub/Sub calls may not respond immediately.
  # Wrap expectations that may require multiple attempts with this method.
  def expect_with_retry attempts: 5
    attempt_number ||= 0
    yield
  rescue RSpec::Expectations::ExpectationNotMetError
    attempt_number += 1
    retry if attempt_number < attempts
    raise
  end

  it "lists subscriptions" do
    topic = @pubsub.create_topic @topic_name
    topic.subscribe @pull_subscription_name

    expect {
      list_subscriptions project_id: @project_id
    }.to output(/#{@pull_subscription_name}/).to_stdout
  end

  it "updates push configuration" do
    topic = @pubsub.create_topic @topic_name
    topic.subscribe @push_subscription_name,
                    endpoint: "https://#{@pubsub.project}.appspot.com/push"

    expect(@pubsub.subscription(@push_subscription_name)).not_to be nil

    expect {
      update_push_configuration project_id:        @project_id,
                                subscription_name: @push_subscription_name,
                                new_endpoint:      "https://#{@pubsub.project}.appspot.com/push_2"
    }.to output(/Push endpoint updated/).to_stdout
  end

  it "gets subscription policy" do
    topic = @pubsub.create_topic @topic_name
    topic.subscribe @pull_subscription_name

    expect {
      get_subscription_policy project_id:        @project_id,
                              subscription_name: @pull_subscription_name
    }.to output(/Subscription policy/).to_stdout
  end

  it "sets subscription policy" do
    topic = @pubsub.create_topic @topic_name
    topic.subscribe @pull_subscription_name

    expect_any_instance_of(Google::Cloud::Pubsub::Policy).to \
      receive(:add).with(
        "roles/pubsub.subscriber",
        "serviceAccount:account-name@project-name.iam.gserviceaccount.com"
      ).and_wrap_original do |m|
        m.call "roles/pubsub.subscriber", @service_account
      end

    expect {
      set_subscription_policy project_id:        @project_id,
                              subscription_name: @pull_subscription_name
    }.not_to raise_error


    expect(@pubsub.subscription(@pull_subscription_name).policy.roles).to \
      include("roles/pubsub.subscriber" => [@service_account])
  end

  it "tests subscription permission" do
    topic = @pubsub.create_topic @topic_name
    topic.subscribe @pull_subscription_name

    expect {
      test_subscription_permissions project_id:        @project_id,
                                    subscription_name: @pull_subscription_name
    }.to output(/Permission to consume\nPermission to update/).to_stdout
  end

  it "pulls message" do
    topic = @pubsub.create_topic @topic_name
    topic.subscribe @pull_subscription_name

    topic.publish "This is a test message."

    sleep 5

    expect_with_retry do
      expect {
        pull_messages project_id:        @project_id,
                      subscription_name: @pull_subscription_name
      }.to output(/Message pulled: This is a test message/).to_stdout
    end
  end

  it "listens for messages" do
    topic = @pubsub.create_topic @topic_name
    topic.subscribe @pull_subscription_name

    topic.publish "This is a test message."

    expect {
      listen_for_messages project_id:        @project_id,
                          subscription_name: @pull_subscription_name
    }.to output(/Received message: This is a test message/).to_stdout
  end

  it "listens for messages with custom attributes" do
    topic = @pubsub.create_topic @topic_name
    topic.subscribe @pull_subscription_name

    topic.publish "This is a test message.",
                  origin: "ruby-sample"

    expect {
      listen_for_messages_with_custom_attributes project_id:        @project_id,
                                                 subscription_name: @pull_subscription_name
    }.to output(/origin: ruby-sample/).to_stdout
  end

  it "listens for messages with flow control" do
    topic = @pubsub.create_topic @topic_name
    topic.subscribe @pull_subscription_name

    topic.publish "This is a test message."

    expect {
      listen_for_messages_with_flow_control project_id:        @project_id,
                                            subscription_name: @pull_subscription_name
    }.to output(/Received message: This is a test message/).to_stdout
  end

  it "listens for messages with concurrency control" do
    topic = @pubsub.create_topic @topic_name
    topic.subscribe @pull_subscription_name

    topic.publish "This is a test message."

    expect {
      listen_for_messages_with_concurrency_control project_id:        @project_id,
                                                   subscription_name: @pull_subscription_name
    }.to output(/Received message: This is a test message/).to_stdout
  end

  it "deletes subscription" do
    topic = @pubsub.create_topic @topic_name
    topic.subscribe @pull_subscription_name

    expect {
      delete_subscription project_id:        @project_id,
                          subscription_name: @pull_subscription_name
    }.to output(/Subscription #{@pull_subscription_name} deleted/).to_stdout
  end
end
