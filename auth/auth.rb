# Copyright 2017 Google, Inc
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

def implicit project_id:
  # [START auth_cloud_implicit]
  # project_id = "Your Google Cloud project ID"

  require "google/cloud/storage"

  # If you don't specify credentials when constructing the client, the client
  # library will look for credentials in the environment.
  storage = Google::Cloud::Storage.new project: project_id

  # Make an authenticated API request
  storage.buckets.each do |bucket|
    puts bucket.name
  end
  # [END auth_cloud_implicit]
end

def explicit project_id:, key_file:
  # [START auth_cloud_explicit]
  # project_id = "Your Google Cloud project ID"
  # key_file   = "path/to/service-account.json"
  require "google/cloud/storage"

  # Explicitly use service account credentials by specifying the private key
  # file.
  storage = Google::Cloud::Storage.new project: project_id, keyfile: key_file

  # Make an authenticated API request
  storage.buckets.each do |bucket|
    puts bucket.name
  end
  # [END auth_cloud_explicit]
end

def explicit_compute_engine
  # [START auth_cloud_explicit_compute_engine]
  require "googleauth"
  require "google/cloud/env"
  require "google/cloud/storage"

  # Explicitly use Compute Engine credentials and a project ID to create a new
  # Cloud Storage client. These credentials are available on Compute Engine,
  # App Engine Flexible, and Container Engine.
  storage = Google::Cloud::Storage.new project: Google::Cloud.env.project_id,
                                       keyfile: Google::Auth::GCECredentials.new

  # Make an authenticated API request
  storage.buckets.each do |bucket|
    puts bucket.name
  end
  # [END auth_cloud_explicit_compute_engine]
end
