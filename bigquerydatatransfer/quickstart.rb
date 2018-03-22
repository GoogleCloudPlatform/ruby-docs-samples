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

# [START bigquerydatatransfer_quickstart]
# Imports the Google Cloud client library
require "google/cloud/bigquery/data_transfer"

project_id = "YOUR_PROJECT_ID"  # TODO: Update to your project ID.

# Instantiate a client
BigQueryDataTransfer = Google::Cloud::Bigquery::DataTransfer # Alias the module
data_transfer = BigQueryDataTransfer.new

# Get the full path to your project.
project_path = BigQueryDataTransfer::V1::DataTransferServiceClient.project_path(
  project_id)

puts "Supported Data Sources:"

# Iterate over all possible data sources.
data_transfer.list_data_sources(project_path).each do |data_source|
  puts "#{data_source.display_name}:"
  puts "\tID: #{data_source.data_source_id}"
  puts "\tFull path: #{data_source.name}"
  puts "\tDescription: #{data_source.description}"
end
# [END bigquerydatatransfer_quickstart]

