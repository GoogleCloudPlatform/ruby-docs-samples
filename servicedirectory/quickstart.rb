# Copyright 2020 Google, Inc
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

# [START servicedirectory_quickstart]
# Imports the Google Cloud client library
require "google/cloud/service_directory/v1beta1"
ServiceDirectory = Google::Cloud::ServiceDirectory::V1beta1

# Your Google Cloud Platform project ID
project = "YOUR_PROJECT_ID"

# Location of the Service Directory Namespace
location = "us-central1"

# Initialize a client
client = ServiceDirectory::RegistrationService::Client.new

# The resource name of the project
location_name = ServiceDirectory::RegistrationService::Paths.location_path(
  project: project, location: location)

request = ServiceDirectory::ListNamespacesRequest.new(parent:location_name)

# Request list of namespaces in the project
response = client.list_namespaces request

# List all namespaces for your project
puts "Namespaces: "
response.each do |namespace|
  puts namespace.name
end
# [END servicedirectory_quickstart]
