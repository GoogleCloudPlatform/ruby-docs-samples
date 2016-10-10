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

describe "BigQuery Quickstart" do

  it "creates a new dataset" do
    # Initialize test objects
    gcloud   = Google::Cloud.new ENV["GOOGLE_CLOUD_PROJECT"]
    bigquery = gcloud.bigquery

    # Prime BigQuery for test
    if bigquery.dataset "my_new_dataset"
      bigquery.dataset("my_new_dataset").delete
    end

    expect(bigquery.dataset "my_new_dataset").to be nil
    expect(Google::Cloud).to receive(:new).
                             with("YOUR_PROJECT_ID").
                             and_return(gcloud)

    # Run quickstart
    expect {
      load File.expand_path("../quickstart.rb", __dir__)
    }.to output(
      "Dataset my_new_dataset created\.\n"
    ).to_stdout

    expect(bigquery.dataset "my_new_dataset").not_to be nil
   end

end

