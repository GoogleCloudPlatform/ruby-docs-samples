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

# DO NOT EDIT! This is a generated sample ("RequestPagedAll",  "job_search_list_tenants")

# sample-metadata
#   title:
#   description: List Tenants
#   bundle exec ruby samples/v4beta1/job_search_list_tenants.rb [--project_id "Your Google Cloud Project ID"]

require "google/cloud/talent"

# [START job_search_list_tenants]

# List Tenants
def sample_list_tenants project_id
  # Instantiate a client
  tenant_client = Google::Cloud::Talent::TenantService.new version: :v4beta1

  # project_id = "Your Google Cloud Project ID"
  formatted_parent = tenant_client.class.project_path(project_id)

  # Iterate over all results.
  tenant_client.list_tenants(formatted_parent).each do |element|
    puts "Tenant Name: #{element.name}"
    puts "External ID: #{element.external_id}"
  end
end
# [END job_search_list_tenants]


require "optparse"

if $PROGRAM_NAME == __FILE__

  project_id = "Your Google Cloud Project ID"

  ARGV.options do |opts|
    opts.on("--project_id=val") { |val| project_id = val }
    opts.parse!
  end


  sample_list_tenants(project_id)
end
