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

require "rspec"
require "google/cloud/pubsub"
require "rack/test"

describe "PubSub", type: :feature do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  before :all do
    ENV["PUBSUB_TOPIC"] = "flexible-topic" unless ENV["PUBSUB_TOPIC"]
    @topic_name = ENV["PUBSUB_TOPIC"]
    @pubsub = Google::Cloud::Pubsub.new

    topic = @pubsub.topic @topic_name
    @pubsub.create_topic @topic_name if topic.nil?
    require_relative "../app.rb"
  end

  it "returns what we expect" do
    get "/"

    expect(last_response.body).to include(
      "Messages received by this instance:"
    )
  end

  it "accepts a publish" do
    post "/publish", payload: "A Message"

    expect(last_response.status).to eq 303
  end

  after :all do
    topic = @pubsub.topic @topic_name
    topic&.delete
  end
end
