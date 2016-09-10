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

def create_dataset project_id:, dataset_id:
  # [START create_dataset]
  # project_id = "Your Google Cloud project ID"
  # dataset_id = "ID of the dataset to create"

  require "google/cloud"

  gcloud   = Google::Cloud.new project_id
  bigquery = gcloud.bigquery

  bigquery.create_dataset dataset_id

  puts "Created dataset: #{dataset_id}"
  # [END create_dataset]
end

def list_datasets project_id:
  # [START list_datasets]
  # project_id = "Your Google Cloud project ID"

  require "google/cloud"

  gcloud   = Google::Cloud.new project_id
  bigquery = gcloud.bigquery

  bigquery.datasets.each do |dataset|
    puts dataset.dataset_id
  end
  # [END list_datasets]
end

def delete_dataset project_id:, dataset_id:
  # [START delete_dataset]
  # project_id = "Your Google Cloud project ID"
  # dataset_id = "ID of the dataset to delete"

  require "google/cloud"

  gcloud   = Google::Cloud.new project_id
  bigquery = gcloud.bigquery
  dataset  = bigquery.dataset dataset_id

  dataset.delete

  puts "Deleted dataset: #{dataset_id}"
  # [END delete_dataset]
end
