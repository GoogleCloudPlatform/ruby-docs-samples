# Copyright 2019 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

def delete_dataset actual_project_id:, actual_dataset_id:
  # Delete a dataset.
  # [START automl_delete_dataset]
  require "google/cloud/automl"

  project_id = "YOUR_PROJECT_ID"
  dataset_id = "YOUR_DATASET_ID"
  # [END automl_delete_dataset]
  # Set the real values for these variables from the method arguments.
  project_id = actual_project_id
  dataset_id = actual_dataset_id
  # [START automl_delete_dataset]

  client = Google::Cloud::AutoML::AutoML.new

  # Get the full path of the dataset
  dataset_full_id = client.class.dataset_path project_id, "us-central1", dataset_id

  operation = client.delete_dataset dataset_full_id

  # Wait until the long running operation is done
  operation.wait_until_done!

  puts "Dataset deleted."
  # [END automl_delete_dataset]
end
