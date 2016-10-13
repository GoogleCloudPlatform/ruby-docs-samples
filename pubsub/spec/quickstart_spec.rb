# Copyright 2016 Google, Inc
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
require "google/cloud"

describe "PubSub Quickstart" do

  it "creates a new topic" do
    gcloud = Google::Cloud.new ENV["GOOGLE_CLOUD_PROJECT"]
    pubsub = gcloud.pubsub

    if pubsub.topic "my-new-topic"
      pubsub.topic("my-new-topic").delete
    end

    expect(pubsub.topic "my-new-topic").to be nil
    expect(Google::Cloud).to receive(:new).
                             with("YOUR_PROJECT_ID").
                             and_return(gcloud)

    expect {
      load File.expand_path("../quickstart.rb", __dir__)
    }.to output(
      "Topic projects/#{ENV["GOOGLE_CLOUD_PROJECT"]}/" +
      "topics/my-new-topic created.\n"
    ).to_stdout

    expect(pubsub.topic "my-new-topic").not_to be nil
   end

end
