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

# [START kms_quickstart]
# Imports the Google Cloud KMS API client
require "google/cloud/kms/v1"
CloudKMS = Google::Cloud::Kms::V1

# Your Google Cloud Platform project ID
project_id = "YOUR_PROJECT_ID"

# Lists keys in the "global" location.
location_id = "global"

# Instantiate the client
client = CloudKMS::KeyManagementServiceClient.new

# The resource name of the location associated with the key rings
parent = CloudKMS::KeyManagementServiceClient.location_path project_id, location_id

# Request list of key rings
response = client.list_key_rings parent

# List all key rings for your project
puts "Key Rings: "
response.each do |key_ring|
  puts key_ring.name
end
# [END kms_quickstart]
