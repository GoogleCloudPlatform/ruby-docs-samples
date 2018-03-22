# Copyright 2018 Google LLC
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
require "google/cloud/bigquery/data_transfer"

describe "BigQuery Data Transfer Quickstart" do

  it "lists data sources" do
    data_transfer = Google::Cloud::Bigquery::DataTransfer.new
    project_path = Google::Cloud::Bigquery::DataTransfer::V1::DataTransferServiceClient.project_path(
      ENV["GOOGLE_CLOUD_PROJECT"])

    expect(Google::Cloud::Bigquery::DataTransfer::V1::DataTransferServiceClient).to(
      receive(:project_path).
      with("YOUR_PROJECT_ID").
      and_return(project_path))

    expect {
      load File.expand_path("../quickstart.rb", __dir__)
    }.to output(
      /Supported Data Sources:\n/
    ).to_stdout
   end

end

