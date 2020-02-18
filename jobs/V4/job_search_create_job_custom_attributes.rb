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

# DO NOT EDIT! This is a generated sample ("Request",  "job_search_create_job_custom_attributes")

# sample-metadata
#   title:
#   description: Create Job with Custom Attributes
#   bundle exec ruby samples/v4beta1/job_search_create_job_custom_attributes.rb [--project_id "Your Google Cloud Project ID"] [--tenant_id "Your Tenant ID (using tenancy is optional)"] [--company_name "Company name, e.g. projects/your-project/companies/company-id"] [--requisition_id "Job requisition ID, aka Posting ID. Unique per job."] [--language_code "en-US"]

require "google/cloud/talent"

# [START job_search_create_job_custom_attributes]

# Create Job with Custom Attributes
#
# @param project_id {String} Your Google Cloud Project ID
# @param tenant_id {String} Identifier of the Tenantd
def sample_create_job project_id, tenant_id, company_name, requisition_id, language_code
  # Instantiate a client
  job_client = Google::Cloud::Talent::JobService.new version: :v4beta1

  # project_id = "Your Google Cloud Project ID"
  # tenant_id = "Your Tenant ID (using tenancy is optional)"
  # company_name = "Company name, e.g. projects/your-project/companies/company-id"
  # requisition_id = "Job requisition ID, aka Posting ID. Unique per job."
  # language_code = "en-US"
  formatted_parent = job_client.class.tenant_path(project_id, tenant_id)
  job = {
    company: company_name,
    requisition_id: requisition_id,
    language_code: language_code
  }

  response = job_client.create_job(formatted_parent, job)
  puts "Created job: #{response.name}"
end
# [END job_search_create_job_custom_attributes]


require "optparse"

if $PROGRAM_NAME == __FILE__

  project_id = "Your Google Cloud Project ID"
  tenant_id = "Your Tenant ID (using tenancy is optional)"
  company_name = "Company name, e.g. projects/your-project/companies/company-id"
  requisition_id = "Job requisition ID, aka Posting ID. Unique per job."
  language_code = "en-US"

  ARGV.options do |opts|
    opts.on("--project_id=val") { |val| project_id = val }
    opts.on("--tenant_id=val") { |val| tenant_id = val }
    opts.on("--company_name=val") { |val| company_name = val }
    opts.on("--requisition_id=val") { |val| requisition_id = val }
    opts.on("--language_code=val") { |val| language_code = val }
    opts.parse!
  end


  sample_create_job(project_id, tenant_id, company_name, requisition_id, language_code)
end
