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

  before do
    @pubsub            = Google::Cloud::Pubsub.new
    @topic_name        = "my-topic"
    @subscription_name = "my-subscription"
    @service_account   =
      "serviceAccount:test-account@#{@pubsub.project}" +
      ".iam.gserviceaccount.com"

    cleanup!

    allow(Google::Cloud::Pubsub).to receive(:new).
                                    with(project: "my-gcp-project-id").
                                    and_return(@pubsub)
  end

  def cleanup!
    topic = @pubsub.topic @topic_name
    topic.delete if topic
    subscription = @pubsub.subscription @subscription_name
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

  it "creates topic" do
    expect(@pubsub.topic(@topic_name)).to be nil

    expect { create_topic }.to output(/#{@topic_name}/).to_stdout

    topic = @pubsub.topic @topic_name
    expect(topic.nil?).to eq(false)
    expect(topic.exists?).to eq(true)
    expect(topic.name).to include(@topic_name)
  end

  it "deletes topic" do
    @pubsub.create_topic @topic_name
    expect(@pubsub.topic @topic_name).not_to be nil

    expect { delete_topic }.to output("Deleted topic #{@topic_name}\n").to_stdout

    expect(@pubsub.topic @topic_name).to be nil
  end

  it "creates subscription" do
    expect(@pubsub.subscription(@subscription_name)).to be nil
    @pubsub.create_topic @topic_name

    expect { create_subscription }.to output(/#{@subscription_name}/).to_stdout

    subscription = @pubsub.subscription @subscription_name
    expect(subscription.nil?).to eq(false)
    expect(subscription.exists?).to eq(true)
    expect(subscription.name).to include(@subscription_name)
    expect(subscription.topic.name).to include(@topic_name)
  end

  it "deletes subscription" do
    topic = @pubsub.create_topic @topic_name
    topic.subscribe @subscription_name

    expect(topic.subscription @subscription_name).not_to be nil

    expect { delete_subscription }.to output(
      "Deleted subscription #{@subscription_name}\n"
    ).to_stdout

    expect(topic.subscription @subscription_name).to be nil
  end

  it "creates push subscription" do
    subscription_name = "my-subscription-push"

    subscription = @pubsub.subscription subscription_name
    subscription.delete if subscription

    @pubsub.create_topic @topic_name

    expect_any_instance_of(Google::Cloud::Pubsub::Topic).to \
      receive(:subscribe).with(
        subscription_name,
        endpoint: "https://my-gcp-project-id.appspot.com/push"
      ).and_return(
        @pubsub.topic(@topic_name).subscribe(
          subscription_name,
          endpoint: "https://#{@pubsub.project}.appspot.com/push"
        ))

    expect { create_push_subscription }.to \
      output(/#{subscription_name}/).to_stdout

    subscription = @pubsub.subscription subscription_name
    expect(subscription.nil?).to eq(false)
    expect(subscription.exists?).to eq(true)
    expect(subscription.name).to include(subscription_name)
    expect(subscription.topic.name).to include(@topic_name)
    subscription.delete
  end

  it "publishes a message" do
    @pubsub.create_topic @topic_name

    expect { publish_message }.not_to raise_error
  end

  it "pulls a message" do
    message = "Test Message"

    topic = @pubsub.create_topic @topic_name
    subscription = topic.subscribe @subscription_name

    @pubsub.topic(@topic_name).publish message

    expect_with_retry do
      expect { pull_messages }.to output(/#{message}/).to_stdout
    end
  end

  it "lists topics" do
    @pubsub.create_topic @topic_name

    expect_with_retry do
      expect { list_topics }.to output(/#{@topic_name}/).to_stdout
    end
  end

  it "lists subscriptions" do
    topic = @pubsub.create_topic @topic_name
    subscription = topic.subscribe @subscription_name

    expect_with_retry do
      expect { list_subscriptions }.to output(/#{@subscription_name}/).to_stdout
    end
  end

  it "gets topic policy" do
    @pubsub.create_topic @topic_name

    expect { get_topic_policy }.to output(/{}/).to_stdout
  end

  it "gets subscription policy" do
    topic = @pubsub.create_topic @topic_name
    subscription = topic.subscribe @subscription_name

    expect { get_subscription_policy }.to output(/{}/).to_stdout
  end

  it "sets topic policy" do
    @pubsub.create_topic @topic_name

    expect_any_instance_of(Google::Cloud::Pubsub::Policy).to \
      receive(:add).with(
        "roles/pubsub.publisher",
        "serviceAccount:account-name@other-project.iam.gserviceaccount.com"
      ).and_wrap_original do |m|
        m.call "roles/pubsub.publisher", @service_account
      end

    expect { set_topic_policy }.to output(/roles/).to_stdout

    expect(@pubsub.topic(@topic_name).policy.roles).to \
      include("roles/pubsub.publisher" => [@service_account])
  end

  it "sets subscription policy" do
    topic = @pubsub.create_topic @topic_name
    subscription = topic.subscribe @subscription_name

    expect_any_instance_of(Google::Cloud::Pubsub::Policy).to \
      receive(:add).with(
        "roles/pubsub.subscriber",
        "serviceAccount:account-name@other-project.iam.gserviceaccount.com"
      ).and_wrap_original do |m|
        m.call "roles/pubsub.subscriber", @service_account
      end

    expect { set_subscription_policy }.to output(/roles/).to_stdout

    expect(@pubsub.subscription(@subscription_name).policy.roles).to \
      include("roles/pubsub.subscriber" => [@service_account])
  end

  it "tests topic permissions" do
    @pubsub.create_topic @topic_name
    expect { test_topic_permissions }.to output(/true\ntrue/).to_stdout
  end

  it "tests subscription permissions" do
    topic = @pubsub.create_topic @topic_name
    subscription = topic.subscribe @subscription_name

    expect { test_subscription_permissions }.to output(/true\ntrue/).to_stdout
  end
end
