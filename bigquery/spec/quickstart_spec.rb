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
require "google/cloud/bigquery"

describe "BigQuery Quickstart" do

  it "creates a new dataset" do
    bigquery     = Google::Cloud::Bigquery.new
    dataset_name = "my_new_dataset_#{Time.now.to_i}"

    expect(bigquery.dataset dataset_name).to be nil
    expect(Google::Cloud::Bigquery).to receive(:new).
                                       with(project: "YOUR_PROJECT_ID").
                                       and_return(bigquery)
    expect(bigquery).to receive(:create_dataset).
                        with("my_new_dataset").
                        and_wrap_original do |m, *args|
      m.call(dataset_name)
    end

    expect {
      load File.expand_path("../quickstart.rb", __dir__)
    }.to output(
      "Dataset #{dataset_name} created\.\n"
    ).to_stdout

    expect(bigquery.dataset dataset_name).not_to be nil

    bigquery.dataset(dataset_name).delete
   end

end

