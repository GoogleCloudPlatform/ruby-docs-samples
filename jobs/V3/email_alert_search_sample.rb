# Copyright 2019 Google, Inc
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

def job_discovery_email_alert_search project_id:, company_name:
  # [START job_discovery_email_alert_search]
  # project_id      = "Id of the project"
  # company_name    = "The resource name of the company listing the job. The format is "projects/{project_id}/companies/{company_id}""

  require "google/apis/jobs_v3"

  # Instantiate the client
  jobs = Google::Apis::JobsV3
  talent_solution_client = jobs::CloudTalentSolutionService.new
  # @see
  # https://developers.google.com/identity/protocols/application-default-credentials#callingruby
  talent_solution_client.authorization = Google::Auth.get_application_default(
    "https://www.googleapis.com/auth/jobs"
  )
  # Make sure to set the request_metadata the same as the associated search request
  request_metadata = jobs::RequestMetadata.new user_id:    "HashedUserId",
                                               session_id: "HashedSessionId",
                                               domain:     "www.google.com"

  # Perform a search for analyst  related jobs
  job_query = jobs::JobQuery.new
  job_query.company_names = [company_name] unless company_name.nil?
  search_jobs_request = jobs::SearchJobsRequest.new request_metadata: request_metadata,
                                                    job_query:        job_query,
                                                    search_mode:      "JOB_SEARCH"
  search_jobs_response = talent_solution_client.search_project_job_for_alert(project_id,
                                                                             search_jobs_request)
  puts search_jobs_response.to_json
  search_jobs_response
  # [END job_discovery_email_alert_search]
end

def run_email_alert_search_sample arguments
  require_relative "basic_company_sample"
  require_relative "basic_job_sample"

  command = arguments.shift
  default_project_id = "projects/#{ENV['GOOGLE_CLOUD_PROJECT']}"
  company_name = "#{default_project_id}/companies/#{arguments.shift}"

  case command
  when "email_alert_search"
    job_discovery_email_alert_search company_name: company_name,
                                     project_id:   default_project_id
  else
    puts <<~USAGE
      Usage: bundle exec ruby email_alert_search_sample.rb [command] [arguments]
      Commands:
        email_alert_search           <company_id>      Search a job which has email alerts signed-up.
      Environment variables:
        GOOGLE_CLOUD_PROJECT must be set to your Google Cloud project ID
    USAGE
  end
end

if $PROGRAM_NAME == __FILE__
  run_email_alert_search_sample ARGV
end
