# Copyright 2020 Google LLC
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

# DO NOT EDIT! This is a generated sample ("Request",  "job_search_get_job")

# sample-metadata
#   title:
#   description: Get Job
#   bundle exec ruby samples/v4beta1/job_search_get_job.rb [--project_id "Your Google Cloud Project ID"] [--tenant_id "Your Tenant ID (using tenancy is optional)"] [--job_id "Job ID"]

require "google/cloud/talent"

# [START job_search_get_job]

# Get Job
def sample_get_job project_id, tenant_id, job_id
  # Instantiate a client
  job_client = Google::Cloud::Talent::JobService.new version: :v4beta1

  # project_id = "Your Google Cloud Project ID"
  # tenant_id = "Your Tenant ID (using tenancy is optional)"
  # job_id = "Job ID"
  formatted_name = job_client.class.job_path(project_id, tenant_id, job_id)

  response = job_client.get_job(formatted_name)
  puts "Job name: #{response.name}"
  puts "Requisition ID: #{response.requisition_id}"
  puts "Title: #{response.title}"
  puts "Description: #{response.description}"
  puts "Posting language: #{response.language_code}"
  response.addresses.each do |address|
    puts "Address: #{address}"
  end
  response.application_info.emails.each do |email|
    puts "Email: #{email}"
  end
  response.application_info.uris.each do |website_uri|
    puts "Website: #{website_uri}"
  end
end
# [END job_search_get_job]


require "optparse"

if $PROGRAM_NAME == __FILE__

  project_id = "Your Google Cloud Project ID"
  tenant_id = "Your Tenant ID (using tenancy is optional)"
  job_id = "Job ID"

  ARGV.options do |opts|
    opts.on("--project_id=val") { |val| project_id = val }
    opts.on("--tenant_id=val") { |val| tenant_id = val }
    opts.on("--job_id=val") { |val| job_id = val }
    opts.parse!
  end


  sample_get_job(project_id, tenant_id, job_id)
end
