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

def implicit project_id:
  # [START implicit]
  # project_id = "Your Google Cloud project ID"

  require "google/cloud/storage"

  # If you don't specify credentials when constructing the client, the client
  # library will look for credentials in the environment.
  storage = Google::Cloud::Storage.new project: project_id

  # Make an authenticated API request
  storage.buckets.each do |bucket|
    puts bucket.name
  end
  # [END implicit]
end

def explicit project_id: # NOT DONE
  # Need to include a bit about keyfile: being available in all google-cloud-ruby .. what about GAPIC? (Ask Jon)
  # [START explicit]
  # project_id = "Your Google Cloud project ID"

  require "google/cloud/storage"

  # Explicitly use service account credentials by specifying the private key
  # file. All client in google-cloud-ruby have this helper,
  # https://github.com/GoogleCloudPlatform/google-cloud-ruby/blob/google-cloud/v0.32.0/google-cloud-core/lib/google/cloud.rb#L60
  storage = Google::Cloud::Storage.new project: project_id, keyfile: "service-account.json"

  # Make an authenticated API request
  storage.buckets.each do |bucket|
    puts bucket.name
  end
  # [END explicit]
end

def explicit_compute_engine project_id: # NOT DONE
  # Using compute engine credentials??? (Ask Remi)
  # [START explicit_compute_engine]
  # project_id = "Your Google Cloud project ID"

  # https://github.com/google/google-auth-library-ruby/blob/master/lib/googleauth.rb
  require "google/cloud/storage"

  # Explicitly use service account credentials by specifying the private key
  # file. All client in google-cloud-ruby have this helper,
  # https://github.com/GoogleCloudPlatform/google-cloud-ruby/blob/google-cloud/v0.32.0/google-cloud-core/lib/google/cloud.rb#L60
  storage = Google::Cloud::Storage.new project: project_id, keyfile: "service-account.json"

  # Make an authenticated API request
  storage.buckets.each do |bucket|
    puts bucket.name
  end
  # [END explicit_compute_engine]
end

