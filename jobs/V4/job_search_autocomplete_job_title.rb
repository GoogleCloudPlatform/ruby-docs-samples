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

# DO NOT EDIT! This is a generated sample ("Request",  "job_search_autocomplete_job_title")

# sample-metadata
#   title:
#   description: Complete job title given partial text (autocomplete)
#   bundle exec ruby samples/v4beta1/job_search_autocomplete_job_title.rb [--project_id "Your Google Cloud Project ID"] [--tenant_id "Your Tenant ID (using tenancy is optional)"] [--query "[partially typed job title]"] [--num_results 5] [--language_code "en-US"]

require "google/cloud/talent"

# [START job_search_autocomplete_job_title]

# Complete job title given partial text (autocomplete)
#
# @param project_id {String} Your Google Cloud Project ID
# @param tenant_id {String} Identifier of the Tenantd
def sample_complete_query project_id, tenant_id, query, num_results, language_code
  # Instantiate a client
  completion_client = Google::Cloud::Talent::Completion.new version: :v4beta1

  # project_id = "Your Google Cloud Project ID"
  # tenant_id = "Your Tenant ID (using tenancy is optional)"
  # query = "[partially typed job title]"
  # num_results = 5
  # language_code = "en-US"
  formatted_parent = completion_client.class.tenant_path(project_id, tenant_id)
  language_codes = [language_code]

  response = completion_client.complete_query(formatted_parent, query, num_results, language_codes: language_codes)
  response.completion_results.each do |result|
    puts "Suggested title: #{result.suggestion}"
    # Suggestion type is JOB_TITLE or COMPANY_TITLE
    puts "Suggestion type: #{result.type}"
  end
end
# [END job_search_autocomplete_job_title]


require "optparse"

if $PROGRAM_NAME == __FILE__

  project_id = "Your Google Cloud Project ID"
  tenant_id = "Your Tenant ID (using tenancy is optional)"
  query = "[partially typed job title]"
  num_results = 5
  language_code = "en-US"

  ARGV.options do |opts|
    opts.on("--project_id=val") { |val| project_id = val }
    opts.on("--tenant_id=val") { |val| tenant_id = val }
    opts.on("--query=val") { |val| query = val }
    opts.on("--num_results=val") { |val| num_results = val }
    opts.on("--language_code=val") { |val| language_code = val }
    opts.parse!
  end


  sample_complete_query(project_id, tenant_id, query, num_results, language_code)
end
