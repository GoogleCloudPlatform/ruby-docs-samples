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

# DO NOT EDIT! This is a generated sample ("Request",  "job_search_batch_delete_job")

require "google/cloud/talent"

# [START job_search_batch_delete_job]

 # Batch delete jobs using a filter
 #
 # @param project_id {String} Your Google Cloud Project ID
 # @param tenant_id {String} Identifier of the Tenantd
 # @param filter {String} The filter string specifies the jobs to be deleted.
 # For example:
 # companyName = "projects/api-test-project/companies/123" AND equisitionId = "req-1"
def sample_batch_delete_jobs(project_id, tenant_id, filter)
  # [START job_search_batch_delete_job_core]
  # Instantiate a client
  job_client = Google::Cloud::Talent::JobService.new version: :v4beta1

  # project_id = "Your Google Cloud Project ID"
  # tenant_id = "Your Tenant ID (using tenancy is optional)"
  # filter = "[Query]"
  formatted_parent = job_client.class.tenant_path(project_id, tenant_id)

  job_client.batch_delete_jobs(formatted_parent, filter)

  puts "Batch deleted jobs from filter"

  # [END job_search_batch_delete_job_core]
end
# [END job_search_batch_delete_job]


require "optparse"

if $0 == __FILE__

  project_id = "Your Google Cloud Project ID"
  tenant_id = "Your Tenant ID (using tenancy is optional)"
  filter = "[Query]"

  ARGV.options do |opts|
    opts.on("--project_id=val") { |val| project_id = val }
    opts.on("--tenant_id=val") { |val| tenant_id = val }
    opts.on("--filter=val") { |val| filter = val }
    opts.parse!
  end


  sample_batch_delete_jobs(project_id, tenant_id, filter)
end