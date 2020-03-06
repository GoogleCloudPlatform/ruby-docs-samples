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

# DO NOT EDIT! This is a generated sample ("Request",  "job_search_get_tenant")

# sample-metadata
#   title:
#   description: Get Tenant by name
#   bundle exec ruby samples/v4beta1/job_search_get_tenant.rb [--project_id "Your Google Cloud Project ID"] [--tenant_id "Your Tenant ID"]

require "google/cloud/talent"

# [START job_search_get_tenant]

# Get Tenant by name
def sample_get_tenant project_id, tenant_id
  # Instantiate a client
  tenant_client = Google::Cloud::Talent::TenantService.new version: :v4beta1

  # project_id = "Your Google Cloud Project ID"
  # tenant_id = "Your Tenant ID"
  formatted_name = tenant_client.class.tenant_path(project_id, tenant_id)

  response = tenant_client.get_tenant(formatted_name)
  puts "Name: #{response.name}"
  puts "External ID: #{response.external_id}"
end
# [END job_search_get_tenant]


require "optparse"

if $PROGRAM_NAME == __FILE__

  project_id = "Your Google Cloud Project ID"
  tenant_id = "Your Tenant ID"

  ARGV.options do |opts|
    opts.on("--project_id=val") { |val| project_id = val }
    opts.on("--tenant_id=val") { |val| tenant_id = val }
    opts.parse!
  end


  sample_get_tenant(project_id, tenant_id)
end
