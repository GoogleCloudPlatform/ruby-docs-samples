# Copyright 2018 Google, Inc
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

def job_discovery_job_title_auto_complete project_id:, company_name:, query:
  # [START job_discovery_job_title_auto_complete]
  # project_id     = "Project id required"
  # company_name   = "The resource name of the company listing the job. The format is "projects/{project_id}/companies/{company_id}""
  # query          = "Job title prefix as auto complete query"

  require "google/apis/jobs_v3"

  jobs = Google::Apis::JobsV3
  talent_solution_client = jobs::CloudTalentSolutionService.new
  talent_solution_client.authorization = Google::Auth.get_application_default(
    "https://www.googleapis.com/auth/jobs"
  )

  page_size = 10
  type = "JOB_TITLE"
  language_code = "en-US"
  talent_solution_client.complete_project(
    project_id, company_name: company_name, page_size: page_size, query: query,
      language_code: language_code, type: type
  ) do |result, err|
    if err.nil?
      puts "Job title auto complete result: #{result.to_json}"
    else
      puts "Error when auto completing job title. Error message: #{err.to_json}"
    end
  end
  # [END job_discovery_job_title_auto_complete]
end

def job_discovery_default_auto_complete project_id:, company_name:, query:
  # [START job_discovery_default_auto_complete]
  # project_id     = "Project id required"
  # company_name   = "The company's name which the job belongs to. The format is "projects/{project_id}/companies/{company_id}""
  # query          = "Keyword prefix as auto complete query"

  require "google/apis/jobs_v3"

  jobs = Google::Apis::JobsV3
  talent_solution_client = jobs::CloudTalentSolutionService.new
  talent_solution_client.authorization = Google::Auth.get_application_default(
    "https://www.googleapis.com/auth/jobs"
  )

  page_size = 10
  language_code = "en-US"
  result = talent_solution_client.complete_project(
    project_id, company_name: company_name, page_size: page_size, query: query,
    language_code: language_code
  ) do |result, err|
    if err.nil?
      puts "Default auto complete result: #{result.to_json}"
    else
      puts "Error when auto completing. Error message: #{err.to_json}"
    end
  end
  # [END job_discovery_default_auto_complete]
end

def run_auto_complete_sample arguments
  command = arguments.shift
  default_project_id = "projects/#{ENV['GOOGLE_CLOUD_PROJECT']}"
  company_name = "#{default_project_id}/companies/#{arguments.shift}"

  case command
  when "job_title_auto_complete"
    job_discovery_job_title_auto_complete company_name: company_name,
                                          query:        arguments.shift,
                                          project_id:   default_project_id
  when "default_auto_complete"
    job_discovery_default_auto_complete company_name: company_name,
                                        query:        arguments.shift,
                                        project_id:   default_project_id
  else
    puts <<~USAGE
      Usage: bundle exec ruby auto_complete_sample.rb [command] [arguments]
      Commands:
        job_title_auto_complete     <company_id> <title_prefix>     Auto completes job titles within given company_name and title prefix
        default_auto_complete       <company_id> <keyword_prefix>   Default auto completes within given company_name and keyword prefix
      Environment variables:
        GOOGLE_CLOUD_PROJECT must be set to your Google Cloud project ID
    USAGE
  end
end

if $PROGRAM_NAME == __FILE__
  run_auto_complete_sample ARGV
end
