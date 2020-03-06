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

# DO NOT EDIT! This is a generated sample ("RequestPagedAll",  "job_search_list_companies")

# sample-metadata
#   title:
#   description: List Companies
#   bundle exec ruby samples/v4beta1/job_search_list_companies.rb [--project_id "Your Google Cloud Project ID"] [--tenant_id "Your Tenant ID (using tenancy is optional)"]

require "google/cloud/talent"

# [START job_search_list_companies]

# List Companies
#
# @param project_id {String} Your Google Cloud Project ID
# @param tenant_id {String} Identifier of the Tenant
def sample_list_companies project_id, tenant_id
  # Instantiate a client
  company_client = Google::Cloud::Talent::CompanyService.new version: :v4beta1

  # project_id = "Your Google Cloud Project ID"
  # tenant_id = "Your Tenant ID (using tenancy is optional)"
  formatted_parent = company_client.class.tenant_path(project_id, tenant_id)

  # Iterate over all results.
  company_client.list_companies(formatted_parent).each do |element|
    puts "Company Name: #{element.name}"
    puts "Display Name: #{element.display_name}"
    puts "External ID: #{element.external_id}"
  end
end
# [END job_search_list_companies]


require "optparse"

if $PROGRAM_NAME == __FILE__

  project_id = "Your Google Cloud Project ID"
  tenant_id = "Your Tenant ID (using tenancy is optional)"

  ARGV.options do |opts|
    opts.on("--project_id=val") { |val| project_id = val }
    opts.on("--tenant_id=val") { |val| tenant_id = val }
    opts.parse!
  end


  sample_list_companies(project_id, tenant_id)
end
