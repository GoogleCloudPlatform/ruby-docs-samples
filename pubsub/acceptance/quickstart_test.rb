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
require_relative "../quickstart.rb"

describe "quickstart" do
  let(:pubsub) { Google::Cloud::Pubsub.new }
  let(:topic_name) { "my-new-topic" }

  before do
    if (t = pubsub.topic topic_name)
      t.delete
    end

    refute pubsub.topic(topic_name)
  end
focus
  it "quickstart_create_topic" do
    assert_output "Topic projects/#{pubsub.project}/topics/#{topic_name} created.\n" do
      quickstart topic_name: topic_name
    end

    assert pubsub.topic(topic_name)
  end
end
