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

describe "Datastore Quickstart" do

  it "creates a new entity" do
    # Initalize test objects
    gcloud_test_client = Google::Cloud.new ENV["GOOGLE_CLOUD_PROJECT"]
    datastore_test_client = gcloud_test_client.datastore
    task_key_test_client = datastore_test_client.key "Task", "sampletask1"

    # Prime DataStore for test
    if datastore_test_client.find task_key_test_client
      task = datastore_test_client.find task_key_test_client
      datastore_test_client.delete task
    end

    expect(datastore_test_client.find(task_key_test_client)).to be nil
    expect(Google::Cloud).to receive(:new).with("YOUR_PROJECT_ID").
                                           and_return(gcloud_test_client)

    # Run quickstart
    expect {
      load File::expand_path("quickstart.rb")
    }.to output {
      "Saved Task: Buy milk\n"
    }.to_stdout

    expect(datastore_test_client.find(task_key_test_client)).not_to be nil

    # Clean up
    task = datastore_test_client.find task_key_test_client
    datastore_test_client.delete task
  end

end
