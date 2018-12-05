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

def job_discovery_batch_create_jobs company_name:, project_id:
	# [START batch_create_jobs]
	# company_name  = "The company's name which has the job you want to create"
	# project_id    = "Id of the project"

	require "google/apis/jobs_v3"

	jobs   = Google::Apis::JobsV3
	talent_solution_client = jobs::CloudTalentSolutionService.new
	# @see https://developers.google.com/identity/protocols/application-default-credentials#callingruby
	talent_solution_client.authorization = Google::Auth.get_application_default(
		"https://www.googleapis.com/auth/jobs"
	)

	jobs_created = Array.new	
	job_generated1 = jobs::Job.new requisition_id: "jobWithRequiredFields: #{SecureRandom.hex}",
					  title: " Lab Technician",
					  company_name: company_name,
					  employment_types: ["FULL_TIME"],
					  language_code: "en-US",
					  application_info: 
					  		(jobs::ApplicationInfo.new uris: ["http://careers.google.com"]),
					  description: "Design and improve software."
	job_generated2 = jobs::Job.new requisition_id: "jobWithRequiredFields: #{SecureRandom.hex}",
					  title: "Systems Administrator",
					  company_name: company_name,
					  employment_types: ["FULL_TIME"],
					  language_code: "en-US",
					  application_info: 
					  		(jobs::ApplicationInfo.new uris: ["http://careers.google.com"]),
					  description: "System Administrator for software."

	create_job_request1 = jobs::CreateJobRequest.new job: job_generated1
	create_job_request2 = jobs::CreateJobRequest.new job: job_generated2

	talent_solution_client.batch do |s|
		s.create_job(project_id, create_job_request1) do |job, err| 
			if err.nil?
				jobs_created.push job
			else
				puts "Batch job create error message: #{err.message}"
			end
		end
		s.create_job(project_id, create_job_request2) do |job, err| 
			if err.nil?
				jobs_created.push job
			else
				puts "Batch job create error message: #{err.message}"
			end
		end
	end
	# jobCreated = batchCreate.create_job(project_id, create_job_request1)
	puts "Batch job created: #{jobs_created.to_json}"
	return jobs_created
	# [END batch_create_jobs]
end


def job_discovery_batch_update_jobs job_to_be_updated:
	# [START batch_update_jobs]
	# job_to_be_updated = "Updated job objects"

	require "google/apis/jobs_v3"

	jobs   = Google::Apis::JobsV3
	talent_solution_client = jobs::CloudTalentSolutionService.new
	# @see 
	# https://developers.google.com/identity/protocols/application-default-credentials#callingruby
	talent_solution_client.authorization = Google::Auth.get_application_default(
		"https://www.googleapis.com/auth/jobs"
	)

	jobs_updated = Array.new
	update_job_with_mask_requests = Array.new
	job_to_be_updated.each{ |job|
		request = jobs::UpdateJobRequest.new job: job,
											 update_mask: "title"
		update_job_with_mask_requests.push request
	}
	
	talent_solution_client.batch do |s|
		update_job_with_mask_requests.each{ |update_job_with_mask_request|
			s.patch_project_job(update_job_with_mask_request.job.name, 
				update_job_with_mask_reques) do |job, err| 
					if err.nil?
						jobs_updated.push job
					else
						puts "Batch job updated error message: #{err.message}"
					end
				end
		}
	end
	puts "Batch job updated with Mask: #{jobs_updated.to_json}"

	jobs_updated.clear
	update_job_requests = Array.new
	job_to_be_updated.each{ |job|
		request = jobs::UpdateJobRequest.new job: job
		update_job_requests.push request
	}
	
	talent_solution_client.batch do |s|
		update_job_requests.each{ |update_job_request|
			s.patch_project_job(update_job_request.job.name, update_job_request) do |job, err| 
				if err.nil?
					jobs_updated.push job
				else
					puts "Batch job updated error message: #{err.message}"
				end
			end
		}
	end
	# jobCreated = batchCreate.create_job(project_id, create_job_request1)
	puts "Batch job updated: #{jobs_updated.to_json}"

	return jobs_updated
	# [END batch_update_jobs]
end

def job_discovery_batch_delete_jobs job_to_be_deleted:
	# [START batch_delete_jobs]
	# job_to_be_deleted = "Name of the jobs to be deleted"
	require "google/apis/jobs_v3"

	jobs   = Google::Apis::JobsV3
	talent_solution_client = jobs::CloudTalentSolutionService.new
	# @see 
	# https://developers.google.com/identity/protocols/application-default-credentials#callingruby
	talent_solution_client.authorization = Google::Auth.get_application_default(
		"https://www.googleapis.com/auth/jobs"
	)

	jobs_deleted = 0
	talent_solution_client.batch do |s|
		job_to_be_deleted.each{ |job_name|
			s.delete_project_job(job_name) do |job, err| 
				if err.nil?
					jobs_deleted += 1
				else
					puts "Batch job deleted error message: #{err.message}"
				end
			end
		}
	end
	puts "Batch job deleted."

	return jobs_deleted
	# [END batch_delete_jobs]
end

def run_batch_operation_sample arguments
	command = arguments.shift
	default_project_id = "projects/#{ENV["GOOGLE_CLOUD_PROJECT"]}"
	user_input = arguments.shift
	company_name = "#{default_project_id}/companies/#{user_input}"
	jobs_created = Array.new
	job_names = Array.new
	case command
	when "batch_create_jobs"
		jobs_created = job_discovery_batch_create_jobs company_name: company_name,
													   project_id: default_project_id
		jobs_created.each{ |job|
			job_names.push job.name
		}
		job_discovery_batch_delete_jobs job_to_be_deleted: job_names
	when "batch_update_jobs"
		jobs_created = job_discovery_batch_create_jobs company_name: company_name,
													   project_id: default_project_id
		jobs_created.each{ |job|
			job.title = job.title + " updated"
			job.description = job.description + " updated"
		}
		job_discovery_batch_update_jobs job_to_be_updated: jobs_created
		jobs_created.each{ |job|
			job_names.push job.name
		}
		job_discovery_batch_delete_jobs job_to_be_deleted: job_names
	when "batch_delete_jobs"
		jobs_created = job_discovery_batch_create_jobs company_name: company_name,
													   project_id: default_project_id
		jobs_created.each{ |job|
			job_names.push job.name
		}
		job_discovery_batch_delete_jobs job_to_be_deleted: job_names
	else
	puts <<-usage
Usage: bundle exec ruby batch_operation_sample.rb [command] [arguments]
Commands:
  batch_create_jobs      <company_id>     Batch create jobs under provided company.
  batch_update_jobs      <company_id>     Batch update jobs.
  batch_delete_jobs      <company_id>     Batch delete jobs.
Environment variables:
  GOOGLE_CLOUD_PROJECT must be set to your Google Cloud project ID
    usage
	end
end

if __FILE__ == $PROGRAM_NAME
  run_batch_operation_sample ARGV
end
