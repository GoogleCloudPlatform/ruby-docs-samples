# Copyright 2015 Google, Inc
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

require_relative "../sample"
require "spec_helper"

describe "Pub/Sub sample" do
  TOPIC_NAME = "my-topic"
  SUBSCRIPTION_NAME = "my-subscription"

  before :all do
    @gcloud = Gcloud.new ENV["GOOGLE_PROJECT_ID"]
    @pubsub = @gcloud.pubsub
  end

  def cleanup!
    topic = @pubsub.topic TOPIC_NAME
    topic.delete if topic
    subscription = @pubsub.subscription SUBSCRIPTION_NAME
    subscription.delete if subscription
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

  before :each do
    cleanup!
    allow(Gcloud).to receive(:new).with("my-gcp-project-id").and_return(@gcloud)
  end

  it "creates topic" do
    expect(@pubsub.topic(TOPIC_NAME)).to be nil

    expect { create_topic }.to output(/#{TOPIC_NAME}/).to_stdout

    topic = @pubsub.topic TOPIC_NAME
    expect(topic.nil?).to eq(false)
    expect(topic.exists?).to eq(true)
    expect(topic.name).to include(TOPIC_NAME)
  end

  it "creates subscription" do
    expect(@pubsub.subscription(SUBSCRIPTION_NAME)).to be nil
    @pubsub.create_topic TOPIC_NAME

    expect { create_subscription }.to output(/#{SUBSCRIPTION_NAME}/).to_stdout

    subscription = @pubsub.subscription SUBSCRIPTION_NAME
    expect(subscription.nil?).to eq(false)
    expect(subscription.exists?).to eq(true)
    expect(subscription.name).to include(SUBSCRIPTION_NAME)
    expect(subscription.topic.name).to include(TOPIC_NAME)
  end

  it "creates push subscription" do
    subscription_name = "my-subscription-push"

    subscription = @pubsub.subscription subscription_name
    subscription.delete if subscription

    @pubsub.create_topic TOPIC_NAME

    expect_any_instance_of(Gcloud::Pubsub::Topic).to \
      receive(:subscribe).with(
        subscription_name,
        endpoint: "https://my-gcp-project-id.appspot.com/push"
      ).and_return(
        @pubsub.topic(TOPIC_NAME).subscribe(
          subscription_name,
          endpoint: "https://#{ENV['GOOGLE_PROJECT_ID']}.appspot.com/push"
        ))

    expect { create_push_subscription }.to \
      output(/#{subscription_name}/).to_stdout

    subscription = @pubsub.subscription subscription_name
    expect(subscription.nil?).to eq(false)
    expect(subscription.exists?).to eq(true)
    expect(subscription.name).to include(subscription_name)
    expect(subscription.topic.name).to include(TOPIC_NAME)
    subscription.delete
  end

  it "publishes a message" do
    @pubsub.create_topic TOPIC_NAME

    expect { publish_message }.not_to raise_error
  end

  it "pulls a message" do
    message = "Test Message"

    @pubsub.create_subscription(
      TOPIC_NAME,
      SUBSCRIPTION_NAME,
      autocreate: true
    )
    @pubsub.topic(TOPIC_NAME).publish message

    expect_with_retry do
      expect { pull_messages }.to output(/#{message}/).to_stdout
    end
  end

  it "lists topics" do
    @pubsub.topic TOPIC_NAME, autocreate: true

    expect_with_retry do
      expect { list_topics }.to output(/#{TOPIC_NAME}/).to_stdout
    end
  end

  it "lists subscriptions" do
    @pubsub.create_subscription(
      TOPIC_NAME,
      SUBSCRIPTION_NAME,
      autocreate: true
    )

    expect_with_retry do
      expect { list_subscriptions }.to output(/#{SUBSCRIPTION_NAME}/).to_stdout
    end
  end

  after :all do
    cleanup!
  end
end
