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

def job_discovery_generate_job company_name:, requisition_id:
  # [START job_discovery_generate_job]
  # company_name   = "The resource name of the company listing the job. The format is 'projects/{project_id}/companies/{company_id}'"
  # requisition_id = "The posting ID, assigned by the client to identify a job"

  require "google/apis/jobs_v3"

  jobs = Google::Apis::JobsV3

  application_info = jobs::ApplicationInfo.new uris: ["http://careers.google.com"]
  job_generated = jobs::Job.new requisition_id:   requisition_id,
                                title:            " Lab Technician",
                                company_name:     company_name,
                                employment_types: ["FULL_TIME"],
                                language_code:    "en-US",
                                application_info: application_info,
                                description:      "Design, develop, test, deploy, " +
                                                  "maintain and improve software."

  # set compensation to 12 USD/hour
  compensation_entry = jobs::CompensationEntry.new type:   "BASE",
                                                   unit:   "HOURLY",
                                                   amount: (jobs::Money.new currency_code: "USD",
                                                                            units:         12)
  compensation_info = jobs::CompensationInfo.new entries: [compensation_entry]

  job_generated.compensation_info = compensation_info
  puts "Job generated: #{job_generated.to_json}"
  job_generated
  # [END job_discovery_generate_job]
end

def job_discovery_create_job project_id:, job_to_be_created:
  # [START job_discovery_create_job]
  # project_id         = "Id of the project"
  # job_to_be_created  = "Job to be created"

  require "google/apis/jobs_v3"

  jobs = Google::Apis::JobsV3

  talent_solution_client = jobs::CloudTalentSolutionService.new
  talent_solution_client.authorization = Google::Auth.get_application_default(
    "https://www.googleapis.com/auth/jobs"
  )

  begin
    create_job_request = jobs::CreateJobRequest.new job: job_to_be_created
    job_created = talent_solution_client.create_job project_id, create_job_request
    puts "Job created: #{job_created.to_json}"
    job_created
  rescue StandardError => e
    puts "Exception occurred while creating job: #{e}"
  end
  # [END job_discovery_create_job]
end

def job_discovery_get_job job_name:
  # [START job_discovery_get_job]
  # job_name  = "The name of the job you want to get"
  require "google/apis/jobs_v3"

  jobs = Google::Apis::JobsV3

  talent_solution_client = jobs::CloudTalentSolutionService.new
  talent_solution_client.authorization = Google::Auth.get_application_default(
    "https://www.googleapis.com/auth/jobs"
  )

  begin
    job_got = talent_solution_client.get_project_job job_name
    puts "Job got: #{job_got.to_json}"
    job_got
  rescue StandardError => e
    puts "Exception occurred while getting job: #{e}"
  end
  # [END job_discovery_get_job]
end

def job_discovery_update_job job_name:, job_to_be_updated:
  # [START job_discovery_update_job]
  # job_name     = "The name of the job you want to update"
  # job_to_be_updated  = "The new job object to be updated"
  require "google/apis/jobs_v3"

  jobs = Google::Apis::JobsV3

  talent_solution_client = jobs::CloudTalentSolutionService.new
  talent_solution_client.authorization = Google::Auth.get_application_default(
    "https://www.googleapis.com/auth/jobs"
  )

  begin
    update_job_request = jobs::UpdateJobRequest.new job: job_to_be_updated
    job_updated = talent_solution_client.patch_project_job job_name, update_job_request
    puts "Job updated: #{job_updated.to_json}"
    job_updated
  rescue StandardError => e
    puts "Exception occurred while updating job: #{e}"
  end
  # [END job_discovery_update_job]
end

def job_discovery_update_job_with_field_mask job_name:, field_mask:, job_to_be_updated:
  # [START job_discovery_update_job_with_field_mask]
  # job_name     = "The name of the job you want to update"
  # field_mask   = "The field mask you want to update"
  # job_updated  = "The new job object to be updated"

  require "google/apis/jobs_v3"

  jobs = Google::Apis::JobsV3

  talent_solution_client = jobs::CloudTalentSolutionService.new
  talent_solution_client.authorization = Google::Auth.get_application_default(
    "https://www.googleapis.com/auth/jobs"
  )

  begin
    update_job_request = jobs::UpdateJobRequest.new job:         job_to_be_updated,
                                                    update_mask: field_mask
    job_updated = talent_solution_client.patch_project_job job_name, update_job_request
    puts "Job updated with filedMask #{update_job_request.update_mask}. "
    puts "Updated job: #{job_updated.to_json}"
    job_updated
  rescue StandardError => e
    puts "Exception occurred while updating job with field mask: #{e}"
  end
  # [END job_discovery_update_job_with_field_mask]
end

def job_discovery_delete_job job_name:
  # [START job_discovery_delete_job]
  # job_name  = "The name of the job you want to delete"

  require "google/apis/jobs_v3"

  jobs = Google::Apis::JobsV3

  talent_solution_client = jobs::CloudTalentSolutionService.new
  talent_solution_client.authorization = Google::Auth.get_application_default(
    "https://www.googleapis.com/auth/jobs"
  )

  begin
    talent_solution_client.delete_project_job job_name
    puts "Job deleted. jobName: #{job_name}"
  rescue StandardError => e
    puts "Exception occurred while deleting job: #{e}"
  end
  # [END job_discovery_delete_job]
end

def run_basic_job_sample arguments
  require_relative "basic_company_sample"

  command = arguments.shift
  default_project_id = "projects/#{ENV['GOOGLE_CLOUD_PROJECT']}"
  user_input = arguments.shift
  if command == "create_job"
    company_name = "#{default_project_id}/companies/#{user_input}"
  else
    job_name = "#{default_project_id}/jobs/#{user_input}"
  end

  case command
  when "create_job"
    company_got = job_discovery_get_company company_name: company_name
    job_generated = job_discovery_generate_job company_name:   company_got.name,
                                               requisition_id: arguments.shift
    job_created = job_discovery_create_job job_to_be_created: job_generated,
                                           project_id:        default_project_id
  when "get_job"
    job_discovery_get_job job_name: job_name
  when "update_job"
    job_got = job_discovery_get_job job_name: job_name
    job_got.description = "Updated description"
    job_discovery_update_job job_name:          job_got.name,
                             job_to_be_updated: job_got
  when "update_job_with_field_mask"
    job_got = job_discovery_get_job job_name: job_name
    job_got.title = "Updated title software Engineer"
    job_discovery_update_job_with_field_mask job_name:          job_got.name,
                                             field_mask:        "title",
                                             job_to_be_updated: job_created
  when "delete_job"
    job_discovery_delete_job job_name: job_name
  else
    puts <<~USAGE
      Usage: bundle exec ruby basic_job_sample.rb [command] [arguments]
      Commands:
        create_job                  <company_id> <posting_id>   Create a job with a posting ID under a company.
        get_job                     <job_id>                    Get a job by name.
        update_job                  <job_id>                    Update a job.
        update_job_with_field_mask  <job_id>                    Update a job with field mask.
        delete_job                  <job_id>                    Delete a job.
      Environment variables:
        GOOGLE_CLOUD_PROJECT must be set to your Google Cloud project ID
    USAGE
  end
end

if $PROGRAM_NAME == __FILE__
  run_basic_job_sample ARGV
end
