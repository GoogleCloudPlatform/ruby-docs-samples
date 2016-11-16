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
require "google/cloud/datastore"

describe "Datastore Quickstart" do

  it "creates a new entity" do
    datastore = Google::Cloud::Datastore.new
    task_key  = datastore.key "Task", "sampletask1"

    if datastore.find task_key
      task = datastore.find task_key
      datastore.delete task
    end

    expect(datastore.find task_key).to be nil
    expect(Google::Cloud::Datastore).to receive(:new).with("YOUR_PROJECT_ID").
                                           and_return(datastore)

    expect {
      load File.expand_path("../quickstart.rb", __dir__)
    }.to output {
      "Saved Task: Buy milk\n"
    }.to_stdout

    task_key = datastore.find(task_key)
    expect(task_key).not_to be nil
    expect(task_key["description"]).to eq "Buy milk"
  end

end
