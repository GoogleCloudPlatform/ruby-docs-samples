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

def job_discovery_batch_create_jobs project_id:, company_name:
  # [START job_discovery_batch_create_jobs]
  # project_id     = "Id of the project"
  # company_name   = "The resource name of the company listing the job. The format is "projects/{project_id}/companies/{company_id}""

  require "google/apis/jobs_v3"

  jobs = Google::Apis::JobsV3
  talent_solution_client = jobs::CloudTalentSolutionService.new
  # @see https://developers.google.com/identity/protocols/application-default-credentials#callingruby
  talent_solution_client.authorization = Google::Auth.get_application_default(
    "https://www.googleapis.com/auth/jobs"
  )

  jobs_created = []
  job_generated1 = jobs::Job.new requisition_id:   "Job: #{company_name} 1",
                                 title:            " Lab Technician",
                                 company_name:     company_name,
                                 employment_types: ["FULL_TIME"],
                                 language_code:    "en-US",
                                 application_info:
                                                   (jobs::ApplicationInfo.new uris: ["http://careers.google.com"]),
                                 description:      "Design and improve software."
  job_generated2 = jobs::Job.new requisition_id:   "Job: #{company_name} 2",
                                 title:            "Systems Administrator",
                                 company_name:     company_name,
                                 employment_types: ["FULL_TIME"],
                                 language_code:    "en-US",
                                 application_info:
                                                   (jobs::ApplicationInfo.new uris: ["http://careers.google.com"]),
                                 description:      "System Administrator for software."

  create_job_request1 = jobs::CreateJobRequest.new job: job_generated1
  create_job_request2 = jobs::CreateJobRequest.new job: job_generated2

  talent_solution_client.batch do |client|
    client.create_job project_id, create_job_request1 do |job, err|
      if err.nil?
        jobs_created.push job
      else
        puts "Batch job create error message: #{err.message}"
      end
    end
    client.create_job project_id, create_job_request2 do |job, err|
      if err.nil?
        jobs_created.push job
      else
        puts "Batch job create error message: #{err.message}"
      end
    end
  end
  # jobCreated = batchCreate.create_job(project_id, create_job_request1)
  puts "Batch job created: #{jobs_created.to_json}"
  jobs_created
  # [END job_discovery_batch_create_jobs]
end

def job_discovery_batch_update_jobs job_to_be_updated:
  # [START job_discovery_batch_update_jobs]
  # job_to_be_updated = "Updated job objects"

  require "google/apis/jobs_v3"

  jobs = Google::Apis::JobsV3
  talent_solution_client = jobs::CloudTalentSolutionService.new
  # @see
  # https://developers.google.com/identity/protocols/application-default-credentials#callingruby
  talent_solution_client.authorization = Google::Auth.get_application_default(
    "https://www.googleapis.com/auth/jobs"
  )

  jobs_updated = []
  update_job_requests = []
  job_to_be_updated.each do |job|
    request = jobs::UpdateJobRequest.new job: job
    update_job_requests.push request
  end

  talent_solution_client.batch do |client|
    update_job_requests.each do |update_job_request|
      client.patch_project_job update_job_request.job.name, update_job_request do |job, err|
        if err.nil?
          jobs_updated.push job
        else
          puts "Batch job updated error message: #{err.message}"
        end
      end
    end
  end
  # jobCreated = batchCreate.create_job(project_id, create_job_request1)
  puts "Batch job updated: #{jobs_updated.to_json}"

  jobs_updated
  # [END job_discovery_batch_update_jobs]
end

def job_discovery_batch_update_jobs_with_mask job_to_be_updated:
  # [START job_discovery_batch_update_jobs_with_mask]
  # job_to_be_updated = "Updated job objects"

  require "google/apis/jobs_v3"

  jobs = Google::Apis::JobsV3
  talent_solution_client = jobs::CloudTalentSolutionService.new
  # @see
  # https://developers.google.com/identity/protocols/application-default-credentials#callingruby
  talent_solution_client.authorization = Google::Auth.get_application_default(
    "https://www.googleapis.com/auth/jobs"
  )

  jobs_updated = []
  update_job_with_mask_requests = []
  job_to_be_updated.each do |job|
    request = jobs::UpdateJobRequest.new job:         job,
                                         update_mask: "title"
    update_job_with_mask_requests.push request
  end

  talent_solution_client.batch do |client|
    update_job_with_mask_requests.each do |update_job_with_mask_request|
      client.patch_project_job(update_job_with_mask_request.job.name,
                               update_job_with_mask_request) do |job, err|
        if err.nil?
          jobs_updated.push job
        else
          puts "Batch job updated error message: #{err.message}"
        end
      end
    end
  end
  puts "Batch job updated with Mask: #{jobs_updated.to_json}"

  jobs_updated
  # [END job_discovery_batch_update_jobs_with_mask]
end

def job_discovery_batch_delete_jobs job_to_be_deleted:
  # [START job_discovery_batch_delete_jobs]
  # job_to_be_deleted = "Name of the jobs to be deleted"
  require "google/apis/jobs_v3"

  jobs = Google::Apis::JobsV3
  talent_solution_client = jobs::CloudTalentSolutionService.new
  # @see
  # https://developers.google.com/identity/protocols/application-default-credentials#callingruby
  talent_solution_client.authorization = Google::Auth.get_application_default(
    "https://www.googleapis.com/auth/jobs"
  )

  jobs_deleted = 0
  talent_solution_client.batch do |client|
    job_to_be_deleted.each do |job_name|
      client.delete_project_job job_name do |_job, err|
        if err.nil?
          jobs_deleted += 1
        else
          puts "Batch job deleted error message: #{err.message}"
        end
      end
    end
  end
  puts "Batch job deleted."

  jobs_deleted
  # [END job_discovery_batch_delete_jobs]
end

def job_discovery_list_jobs project_id:, company_name:
  # [START job_discovery_list_jobs]
  # project_id    = "Id of the project"
  # company_name  = "The company's name which has the job you want to list. The format is "projects/{project_id}/companies/{company_id}""
  require "google/apis/jobs_v3"

  jobs = Google::Apis::JobsV3

  talent_solution_client = jobs::CloudTalentSolutionService.new
  talent_solution_client.authorization = Google::Auth.get_application_default(
    "https://www.googleapis.com/auth/jobs"
  )

  begin
    job_got = talent_solution_client.list_project_jobs project_id, filter: "companyName = \"#{company_name}\""
    puts "Job got: #{job_got.to_json}"
    job_got
  rescue StandardError => e
    puts "Exception occurred while getting job: #{e}"
  end
  # [END job_discovery_list_jobs]
end

def run_batch_operation_sample arguments
  command = arguments.shift
  default_project_id = "projects/#{ENV['GOOGLE_CLOUD_PROJECT']}"
  user_input = arguments.shift
  company_name = "#{default_project_id}/companies/#{user_input}"
  jobs_created = []
  job_names = []
  case command
  when "batch_create_jobs"
    jobs_created = job_discovery_batch_create_jobs company_name: company_name,
                                                   project_id:   default_project_id
  when "batch_update_jobs"
    list_job_response = job_discovery_list_jobs company_name: company_name,
                                                project_id:   default_project_id
    jobs_got = list_job_response.jobs
    jobs_got.each do |job|
      job.title = "#{job.title} updated"
      job.description = "#{job.description} updated"
    end
    job_discovery_batch_update_jobs job_to_be_updated: jobs_got
  when "batch_update_jobs_with_mask"
    list_job_response = job_discovery_list_jobs company_name: company_name,
                                                project_id:   default_project_id
    jobs_got = list_job_response.jobs
    jobs_got.each do |job|
      job.title = "#{job.title} updated with mask"
    end
    job_discovery_batch_update_jobs_with_mask job_to_be_updated: jobs_got
  when "batch_delete_jobs"
    list_job_response = job_discovery_list_jobs company_name: company_name,
                                                project_id:   default_project_id
    jobs_got = list_job_response.jobs
    jobs_got.each do |job|
      job_names.push job.name
    end
    job_discovery_batch_delete_jobs job_to_be_deleted: job_names
  else
    puts <<~USAGE
      Usage: bundle exec ruby batch_operation_sample.rb [command] [arguments]
      Commands:
        batch_create_jobs            <company_id>     Batch create jobs under provided company.
        batch_update_jobs            <company_id>     Batch update jobs.
        batch_update_jobs_with_mask  <company_id>     Batch update jobs with mask.
        batch_delete_jobs            <company_id>     Batch delete jobs.
      Environment variables:
        GOOGLE_CLOUD_PROJECT must be set to your Google Cloud project ID
    USAGE
  end
end

if $PROGRAM_NAME == __FILE__
  run_batch_operation_sample ARGV
end
