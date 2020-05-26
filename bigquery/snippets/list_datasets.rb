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
# [START bigquery_list_datasets]
require "google/cloud/bigquery"

def list_datasets project_id = "your-project-id"
  bigquery = Google::Cloud::Bigquery.new project: project_id

  puts "Datasets in project #{project_id}:"
  bigquery.datasets.each do |dataset|
    puts "\t#{dataset.dataset_id}"
  end
end
# [END bigquery_list_datasets]
