# Copyright 2019 Google LLC
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

# DO NOT EDIT! This is a generated sample ("Request",  "job_search_create_company")

require "google/cloud/talent"

# [START job_search_create_company]

# Create Company
def sample_create_company(project_id, tenant_id, display_name, external_id)
  # [START job_search_create_company_core]
  # Instantiate a client
  company_client = Google::Cloud::Talent::CompanyService.new version: :v4beta1

  # project_id = "Your Google Cloud Project ID"
  # tenant_id = "Your Tenant ID (using tenancy is optional)"
  # display_name = "My Company Name"
  # external_id = "Identifier of this company in my system"
  formatted_parent = company_client.class.tenant_path(project_id, tenant_id)
  company = { display_name: display_name, external_id: external_id }

  response = company_client.create_company(formatted_parent, company)
  puts "Created Company"
  puts "Name: #{response.name}"
  puts "Display Name: #{response.display_name}"
  puts "External ID: #{response.external_id}"

  # [END job_search_create_company_core]
end
# [END job_search_create_company]


require "optparse"

if $0 == __FILE__

  project_id = "Your Google Cloud Project ID"
  tenant_id = "Your Tenant ID (using tenancy is optional)"
  display_name = "My Company Name"
  external_id = "Identifier of this company in my system"

  ARGV.options do |opts|
    opts.on("--project_id=val") { |val| project_id = val }
    opts.on("--tenant_id=val") { |val| tenant_id = val }
    opts.on("--display_name=val") { |val| display_name = val }
    opts.on("--external_id=val") { |val| external_id = val }
    opts.parse!
  end


  sample_create_company(project_id, tenant_id, display_name, external_id)
end