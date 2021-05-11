# Copyright 2018 Google, Inc
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

# [START quickstart]
require "google/apis/jobs_v3"
require "rails"

# Instantiate the client
Jobs = Google::Apis::JobsV3
jobs_client = Jobs::CloudTalentSolutionService.new

# @see https://developers.google.com/identity/protocols/application-default-credentials#callingruby
jobs_client.authorization = Google::Auth.get_application_default(
  "https://www.googleapis.com/auth/jobs"
)

# ProjectId to get company list
DEFAULT_PROJECT_ID = "projects/#{ENV['GOOGLE_CLOUD_PROJECT']}".freeze
# Request list of companies
response = jobs_client.list_project_companies DEFAULT_PROJECT_ID

# Print the request id
puts "Request id : #{response.metadata.request_id}"

# List all companies for your project
puts "Companies: "
if response.companies
  response.companies.each do |company|
    puts company.name
  end
else
  puts "No companies found"
end
# [END quickstart]
