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

# DO NOT EDIT! This is a generated sample ("Request",  "job_search_create_tenant")

# sample-metadata
#   title:
#   description: Create Tenant for scoping resources, e.g. companies and jobs
#   bundle exec ruby samples/v4beta1/job_search_create_tenant.rb [--project_id "Your Google Cloud Project ID"] [--external_id "Your Unique Identifier for Tenant"]

require "google/cloud/talent"

# [START job_search_create_tenant]

# Create Tenant for scoping resources, e.g. companies and jobs
def sample_create_tenant project_id, external_id
  # Instantiate a client
  tenant_client = Google::Cloud::Talent::TenantService.new version: :v4beta1

  # project_id = "Your Google Cloud Project ID"
  # external_id = "Your Unique Identifier for Tenant"
  formatted_parent = tenant_client.class.project_path(project_id)
  tenant = { external_id: external_id }

  response = tenant_client.create_tenant(formatted_parent, tenant)
  puts "Created Tenant"
  puts "Name: #{response.name}"
  puts "External ID: #{response.external_id}"
end
# [END job_search_create_tenant]


require "optparse"

if $PROGRAM_NAME == __FILE__

  project_id = "Your Google Cloud Project ID"
  external_id = "Your Unique Identifier for Tenant"

  ARGV.options do |opts|
    opts.on("--project_id=val") { |val| project_id = val }
    opts.on("--external_id=val") { |val| external_id = val }
    opts.parse!
  end


  sample_create_tenant(project_id, external_id)
end
