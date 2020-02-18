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

# DO NOT EDIT! This is a generated sample ("Request",  "job_search_get_company")

# sample-metadata
#   title:
#   description: Get Company
#   bundle exec ruby samples/v4beta1/job_search_get_company.rb [--project_id "Your Google Cloud Project ID"] [--tenant_id "Your Tenant ID (using tenancy is optional)"] [--company_id "Company ID"]

require "google/cloud/talent"

# [START job_search_get_company]

# Get Company
def sample_get_company project_id, tenant_id, company_id
  # Instantiate a client
  company_client = Google::Cloud::Talent::CompanyService.new version: :v4beta1

  # project_id = "Your Google Cloud Project ID"
  # tenant_id = "Your Tenant ID (using tenancy is optional)"
  # company_id = "Company ID"
  formatted_name = company_client.class.company_path(project_id, tenant_id, company_id)

  response = company_client.get_company(formatted_name)
  puts "Company name: #{response.name}"
  puts "Display name: #{response.display_name}"
end
# [END job_search_get_company]


require "optparse"

if $PROGRAM_NAME == __FILE__

  project_id = "Your Google Cloud Project ID"
  tenant_id = "Your Tenant ID (using tenancy is optional)"
  company_id = "Company ID"

  ARGV.options do |opts|
    opts.on("--project_id=val") { |val| project_id = val }
    opts.on("--tenant_id=val") { |val| tenant_id = val }
    opts.on("--company_id=val") { |val| company_id = val }
    opts.parse!
  end


  sample_get_company(project_id, tenant_id, company_id)
end
