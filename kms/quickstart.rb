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

# Imports the Google Cloud KMS api client
require "google/apis/cloudkms_v1beta1"

# Your Google Cloud Platform project ID
project_id = "YOUR_PROJECT_ID"

# Lists keys in the "global" location.
location = "global"

# Instantiate the client
Cloudkms = Google::Apis::CloudkmsV1beta1 # Alias the module
kms_client = Cloudkms::CloudKMSService.new

# https://developers.google.com/identity/protocols/application-default-credentials#callingruby
# Set the required scopes to access the Key Management Service API
kms_client.authorization = Google::Auth.get_application_default(
  "https://www.googleapis.com/auth/cloud-platform"
)

# The resource name of the location associated with the KeyRings
parent = "projects/#{project_id}/locations/#{location}"

# Request list of key rings
response = kms_client.list_project_location_key_rings parent

# list all key rings for your project
puts "Key Rings: "
response.key_rings.each do |ring|
  puts ring.name
end

# [END kms_quickstart]

