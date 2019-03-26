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

require_relative "../topics"
require "spec_helper"
require "rspec/retry"

RSpec.configure do |config|
  # show retry status in spec process
  config.verbose_retry = true
  # show exception that triggers a retry if verbose_retry is set to true
  config.display_try_failure_messages = true

  # set retry count and retry sleep interval to 60 seconds
  config.default_retry_count = 5
  config.default_sleep_interval = 60
end

describe "Pub/Sub topics sample" do
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
    sleep 60
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

  it "creates topic" do
    expect {
      create_topic project_id: @project_id,
                   topic_name: @topic_name
    }.to output(/#{@topic_name} created/).to_stdout

    topic = @pubsub.topic @topic_name
    expect(topic.nil?).to eq(false)
    expect(topic.exists?).to eq(true)
    expect(topic.name).to include(@topic_name)
  end

  it "lists topic" do
    @pubsub.create_topic @topic_name

    expect_with_retry do
      expect {
        list_topics project_id: @project_id
      }.to output(/#{@topic_name}/).to_stdout
    end
  end

  it "creates pull subscription" do
    @pubsub.create_topic @topic_name

    expect {
      create_pull_subscription project_id:        @project_id,
                               topic_name:        @topic_name,
                               subscription_name: @pull_subscription_name
    }.to output(/#{@pull_subscription_name} created/).to_stdout

    subscription = @pubsub.subscription @pull_subscription_name
    expect(subscription.nil?).to eq(false)
    expect(subscription.exists?).to eq(true)
    expect(subscription.name).to include(@pull_subscription_name)
    expect(subscription.topic.name).to include(@topic_name)
  end

  it "creates push subscription" do
    @pubsub.create_topic @topic_name

    expect {
      create_push_subscription project_id:        @project_id,
                               topic_name:        @topic_name,
                               subscription_name: @push_subscription_name,
                               endpoint:          "https://#{@pubsub.project}.appspot.com/push"
    }.to output(/#{@push_subscription_name} created/).to_stdout

    subscription = @pubsub.subscription @push_subscription_name
    expect(subscription.nil?).to eq(false)
    expect(subscription.exists?).to eq(true)
    expect(subscription.name).to include(@push_subscription_name)
    expect(subscription.topic.name).to include(@topic_name)
    subscription.delete
  end

  it "gets topic policy" do
    @pubsub.create_topic @topic_name

    expect {
      get_topic_policy project_id: @project_id,
                       topic_name: @topic_name
    }.to output(/Topic policy:/).to_stdout
  end

  it "sets topic policy" do
    @pubsub.create_topic @topic_name

    expect_any_instance_of(Google::Cloud::Pubsub::Policy).to \
      receive(:add).with(
        "roles/pubsub.publisher",
        "serviceAccount:account_name@project_name.iam.gserviceaccount.com"
      ).and_wrap_original do |m|
        m.call "roles/pubsub.publisher", @service_account
      end

    expect {
      set_topic_policy project_id: @project_id,
                       topic_name: @topic_name
    }.not_to raise_error

    expect(@pubsub.topic(@topic_name).policy.roles).to \
      include("roles/pubsub.publisher" => [@service_account])
  end

  it "tests topic permissions" do
    @pubsub.create_topic @topic_name

    expect {
      test_topic_permissions project_id: @project_id,
                             topic_name: @topic_name
    }.to output(/Permission to attach subscription\nPermission to publish\nPermission to update/).to_stdout
  end

  it "publishes message" do
    topic = @pubsub.create_topic @topic_name
    subscription = topic.subscribe @pull_subscription_name

    expect {
      publish_message project_id: @project_id,
                      topic_name: @topic_name
    }.to output(/Message published/).to_stdout

    expect_with_retry do
      subscription.pull(max: 10).each do |message|
        expect(message.data).to eq("This is a test message.")
        message.acknowledge!
      end
    end
  end

  it "publishes messages with batch settings" do
    topic = @pubsub.create_topic @topic_name
    subscription = topic.subscribe @pull_subscription_name

    expect {
      publish_messages_with_batch_settings project_id: @project_id,
                                           topic_name: @topic_name
    }.to output(/Messages published in batch/).to_stdout

    messages = []
    expect_with_retry do
      subscription.pull(max: 20).each do |message|
        messages << message
        message.acknowledge!
      end
      expect(messages.length).to eq(10)
    end
    received_time_counter = Hash.new 0
    messages.each do |message|
      received_time_counter[message.publish_time] += 1
    end
    expect(received_time_counter.length).to eq(1)
  end

  it "publishes messages asynchronously" do
    topic = @pubsub.create_topic @topic_name
    subscription = topic.subscribe @pull_subscription_name

    expect {
      publish_message_async project_id: @project_id,
                            topic_name: @topic_name
    }.not_to raise_error

    expect_with_retry do
      subscription.pull(max: 1).each do |message|
        expect(message.data).to eq("This is a test message.")
        message.acknowledge!
      end
    end
  end

  it "publishes messages with custom attributes asynchronously" do
    topic = @pubsub.create_topic @topic_name
    subscription = topic.subscribe @pull_subscription_name

    expect {
      publish_message_async_with_custom_attributes project_id: @project_id,
                                                   topic_name: @topic_name
    }.not_to raise_error

    expect_with_retry do
      subscription.pull(max: 1).each do |message|
        expect(message.data).to eq("This is a test message.")
        expect(message.attributes).to include("origin" => "ruby-sample")
        expect(message.attributes).to include("username" => "gcp")
      end
    end
  end

  it "publishes messages with batch settings asynchronously" do
    topic = @pubsub.create_topic @topic_name
    subscription = topic.subscribe @pull_subscription_name

    expect {
      publish_messages_async_with_batch_settings project_id: @project_id,
                                                 topic_name: @topic_name
    }.not_to raise_error

    messages = []
    expect_with_retry do
      subscription.pull(max: 20).each do |message|
        messages << message
        message.acknowledge!
      end
      expect(messages.length).to eq(10)
    end
    received_time_counter = Hash.new 0
    messages.each do |message|
      received_time_counter[message.publish_time] += 1
    end
    expect(received_time_counter.length).to eq(1)
  end

  it "publishes messages with concurrency control asynchronously" do
    topic = @pubsub.create_topic @topic_name
    subscription = topic.subscribe @pull_subscription_name

    expect {
      publish_messages_async_with_concurrency_control project_id: @project_id,
                                                      topic_name: @topic_name
    }.not_to raise_error

    expect_with_retry do
      subscription.pull(max: 1).each do |message|
        expect(message.data).to eq("This is a test message.")
        message.acknowledge!
      end
    end
  end

  it "deletes topic" do
    topic = @pubsub.create_topic @topic_name

    expect {
      delete_topic project_id: @project_id,
                   topic_name: @topic_name
    }.to output(/Topic #{@topic_name} deleted/).to_stdout

    expect(@pubsub.topic(@topic_name)).to be nil
  end
end
