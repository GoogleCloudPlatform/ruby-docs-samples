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

# DO NOT EDIT! This is a generated sample ("Request",  "job_search_delete_job")

# sample-metadata
#   title:
#   description: Delete Job
#   bundle exec ruby samples/v4beta1/job_search_delete_job.rb [--project_id "Your Google Cloud Project ID"] [--tenant_id "Your Tenant ID (using tenancy is optional)"] [--job_id "Company ID"]

require "google/cloud/talent"

# [START job_search_delete_job]

# Delete Job
def sample_delete_job project_id, tenant_id, job_id
  # Instantiate a client
  job_client = Google::Cloud::Talent::JobService.new version: :v4beta1

  # project_id = "Your Google Cloud Project ID"
  # tenant_id = "Your Tenant ID (using tenancy is optional)"
  # job_id = "Company ID"
  formatted_name = job_client.class.job_path(project_id, tenant_id, job_id)

  job_client.delete_job(formatted_name)

  puts "Deleted job."
end
# [END job_search_delete_job]


require "optparse"

if $PROGRAM_NAME == __FILE__

  project_id = "Your Google Cloud Project ID"
  tenant_id = "Your Tenant ID (using tenancy is optional)"
  job_id = "Company ID"

  ARGV.options do |opts|
    opts.on("--project_id=val") { |val| project_id = val }
    opts.on("--tenant_id=val") { |val| tenant_id = val }
    opts.on("--job_id=val") { |val| job_id = val }
    opts.parse!
  end


  sample_delete_job(project_id, tenant_id, job_id)
end
