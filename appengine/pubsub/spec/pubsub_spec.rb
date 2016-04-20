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

require File.expand_path("../../../../spec/e2e", __FILE__)
require "rspec"
require "net/http"
require "gcloud"

RSpec.describe "PubSub E2E test" do
  before :all do
    @topic_name = "flexible-topic"

    gcloud = Gcloud.new
    @pubsub = gcloud.pubsub
    topic = @pubsub.topic @topic_name
    @pubsub.create_topic @topic_name unless topic

    app_yaml = File.expand_path("../../app.yaml", __FILE__)
    configuration = File.read(app_yaml)
                        .sub("<your-topic-name>", @topic_name)
                        .sub("<your-token>", "asdf1234")
    File.write(app_yaml, configuration)

    @url = E2E.url
  end

  it "returns what we expect" do
    uri = URI.parse(@url)
    response = Net::HTTP.get(uri)

    expect(response).to include("Messages received by this instance:")
  end

  it "accepts a publish" do
    uri = URI.parse(@url + "/publish")
    response = Net::HTTP.post_form(uri, "payload" => "A Message")

    expect(response.code).to eq("303")
  end

  after :all do
    topic = @pubsub.topic @topic_name
    topic.delete if topic
  end
end
