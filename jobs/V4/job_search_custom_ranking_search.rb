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

# DO NOT EDIT! This is a generated sample ("RequestPagedAll",  "job_search_custom_ranking_search")

# sample-metadata
#   title:
#   description: Search Jobs using custom rankings
#   bundle exec ruby samples/v4beta1/job_search_custom_ranking_search.rb [--project_id "Your Google Cloud Project ID"] [--tenant_id "Your Tenant ID (using tenancy is optional)"]

require "google/cloud/talent"

# [START job_search_custom_ranking_search]

# Search Jobs using custom rankings
#
# @param project_id {String} Your Google Cloud Project ID
# @param tenant_id {String} Identifier of the Tenantd
def sample_search_jobs project_id, tenant_id
  # Instantiate a client
  job_client = Google::Cloud::Talent::JobService.new version: :v4beta1

  # project_id = "Your Google Cloud Project ID"
  # tenant_id = "Your Tenant ID (using tenancy is optional)"
  formatted_parent = job_client.class.tenant_path(project_id, tenant_id)
  domain = "www.example.com"
  session_id = "Hashed session identifier"
  user_id = "Hashed user identifier"
  request_metadata = {
    domain: domain,
    session_id: session_id,
    user_id: user_id
  }
  importance_level = :EXTREME
  ranking_expression = "(someFieldLong + 25) * 0.25"
  custom_ranking_info = { importance_level: importance_level, ranking_expression: ranking_expression }
  order_by = "custom_ranking desc"

  # Iterate over all results.
  job_client.search_jobs(formatted_parent, request_metadata, custom_ranking_info: custom_ranking_info, order_by: order_by).each do |element|
    puts "Job summary: #{element.job_summary}"
    puts "Job title snippet: #{element.job_title_snippet}"
    job = element.job
    puts "Job name: #{job.name}"
    puts "Job title: #{job.title}"
  end
end
# [END job_search_custom_ranking_search]


require "optparse"

if $PROGRAM_NAME == __FILE__

  project_id = "Your Google Cloud Project ID"
  tenant_id = "Your Tenant ID (using tenancy is optional)"

  ARGV.options do |opts|
    opts.on("--project_id=val") { |val| project_id = val }
    opts.on("--tenant_id=val") { |val| tenant_id = val }
    opts.parse!
  end


  sample_search_jobs(project_id, tenant_id)
end
