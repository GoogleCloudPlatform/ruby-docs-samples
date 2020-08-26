# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# [START functions_pubsub_unit_test]
require "minitest/autorun"
require "functions_framework/testing"
require "base64"

describe "functions_helloworld_pubsub" do
  include FunctionsFramework::Testing

  let(:resource_type) { "type.googleapis.com/google.pubsub.v1.PubsubMessage" }
  let(:source) { "//pubsub.googleapis.com/projects/sample-project/topics/gcf-test" }
  let(:type) { "google.cloud.pubsub.topic.v1.messagePublished" }

  it "prints a name" do
    load_temporary "helloworld/pubsub/app.rb" do
      payload = { "@type" => resource_type, "message" => { "data" => Base64.encode64("Ruby") } }
      event = make_cloud_event payload, source: source, type: type
      _out, err = capture_subprocess_io do
        # Call tested function
        call_event "hello_pubsub", event
      end
      assert_match(/Hello, Ruby!/, err)
    end
  end

  it "prints hello world" do
    load_temporary "helloworld/pubsub/app.rb" do
      payload = { "@type" => resource_type, "message" => { "data" => nil } }
      event = make_cloud_event payload, source: source, type: type
      _out, err = capture_subprocess_io do
        # Call tested function
        call_event "hello_pubsub", event
      end
      assert_match(/Hello, World!/, err)
    end
  end
end
# [END functions_pubsub_unit_test]
