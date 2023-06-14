# Copyright 2023 Google LLC
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

# [START functions_response_streaming]
require "functions_framework"
require "google/cloud/bigquery"

FunctionsFramework.http "stream_big_query" do |_request|
  # Provide the Project ID by setting the env variable or specifying directly.
  # project_id = "Your Google Cloud project ID"
  project_id = ENV["CLOUD_PROJECT_ID"]
  bigquery = Google::Cloud::Bigquery.new project: project_id
  # Example to retrieve a large payload from public BigQuery dataset.
  sql = "SELECT abstract FROM `bigquery-public-data.breathe.bioasq` LIMIT 1000"

  results = bigquery.query sql do |config|
    config.location = "US"
  end

  # Stream out the large payload by iterating rows.
  body = Enumerator.new do |y|
    results.each do |row|
      y << "#{row}\n"
    end
  end
  [200, {}, body]
end
# [END functions_response_streaming]
