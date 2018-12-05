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

def job_discovery_generate_job company_name:
	# [START generate_job]
	# company_name  = "The company's name which has the job you want to create"
	require "google/apis/jobs_v3"
	require "securerandom"

	jobs   = Google::Apis::JobsV3

	requisition_id = "jobWithRequiredFields: #{SecureRandom.hex}"
	application_info = jobs::ApplicationInfo.new uris: ["http://careers.google.com"]
	job_generated = jobs::Job.new requisition_id: requisition_id,
								  title: " Lab Technician",
								  company_name: company_name,
								  employment_types: ["FULL_TIME"],
								  language_code: "en-US",
								  application_info: application_info,
								  description: "Design, develop, test, deploy, "
								  				  +"maintain and improve software."
	
	# set compensation to 12 USD/hour
	compensation_entry = jobs::CompensationEntry.new type: "BASE",
													 unit: "HOURLY",
													 amount: (jobs::Money.new currency_code: "USD",
										  									  units: 12)
	compensation_info = jobs::CompensationInfo.new entries: [compensation_entry]

	job_generated.compensation_info = compensation_info
	puts "Job generated: #{job_generated.to_json}"
	return job_generated
	# [END generate basic job]
end

def job_discovery_create_job job_to_be_created:, project_id:
	# [START create_job]
	# job_to_be_created  = "Job to be created"
	# project_id         = "Id of the project"

	require "google/apis/jobs_v3"

	jobs = Google::Apis::JobsV3

	talentSolution_client = jobs::CloudTalentSolutionService.new
	talentSolution_client.authorization = Google::Auth.get_application_default(
	"https://www.googleapis.com/auth/jobs"
	)

	begin
		create_job_request = jobs::CreateJobRequest.new job: job_to_be_created
		job_created = talentSolution_client.create_job(project_id, create_job_request)
		puts "Job created: #{job_created.to_json}"
		return job_created
	rescue => e
	   puts "Exception occurred while creating job: #{e}"
	end
	# [END create_job]
end

def job_discovery_get_job job_name:
	# [START get_job]
	# job_name  = "The name of the job you want to get"
	require "google/apis/jobs_v3"

	jobs   = Google::Apis::JobsV3

	talentSolution_client = jobs::CloudTalentSolutionService.new
	talentSolution_client.authorization = Google::Auth.get_application_default(
	"https://www.googleapis.com/auth/jobs"
	)

	begin
		job_got = talentSolution_client.get_project_job(job_name)
		puts "Job got: #{job_got.to_json}"
		return job_got
	rescue => e
	    puts "Exception occurred while getting job: #{e}"
	end
	# [END get_job]
end

def job_discovery_update_job job_name:, job_to_be_updated:
	# [START update_job]
	# job_name     = "The name of the job you want to update"
	# job_updated  = "The new job object to be updated"
	require "google/apis/jobs_v3"

	jobs = Google::Apis::JobsV3

	talentSolution_client = jobs::CloudTalentSolutionService.new
	talentSolution_client.authorization = Google::Auth.get_application_default(
	"https://www.googleapis.com/auth/jobs"
	)

	begin
		update_job_request = jobs::UpdateJobRequest.new job: job_to_be_updated
		job_updated = talentSolution_client.patch_project_job(job_name, update_job_request)
		puts "Job updated: #{job_updated.to_json}"
		return job_updated
	rescue => e
	    puts "Exception occurred while updating job: #{e}"
	end
	# [END update_job]
end

def job_discovery_update_job_with_field_mask job_name:, field_mask:, job_to_be_updated:
	# [START update_job_with_field_mask]
	# job_name     = "The name of the job you want to update"
	# field_mask   = "The field mask you want to update"
	# job_updated  = "The new job object to be updated"

	require "google/apis/jobs_v3"

	jobs = Google::Apis::JobsV3

	talentSolution_client = jobs::CloudTalentSolutionService.new
	talentSolution_client.authorization = Google::Auth.get_application_default(
	"https://www.googleapis.com/auth/jobs"
	)

	begin
		update_job_request = jobs::UpdateJobRequest.new job: job_to_be_updated,
													    update_mask: field_mask
		job_updated = talentSolution_client.patch_project_job(job_name, update_job_request)
		puts "Job updated with filedMask #{update_job_request.update_mask}. "
			 + "Updated job: #{job_updated.to_json}"
		return job_updated
	rescue => e
	    puts "Exception occurred while updating job with field mask: #{e}"
	end
	# [END update_job_with_field_mask]
end

def job_discovery_delete_job job_name:
	# [START delete_job]
	# job_name  = "The name of the job you want to delete"

	require "google/apis/jobs_v3"

	jobs = Google::Apis::JobsV3

	talentSolution_client = jobs::CloudTalentSolutionService.new
	talentSolution_client.authorization = Google::Auth.get_application_default(
	"https://www.googleapis.com/auth/jobs"
	)

	begin
		talentSolution_client.delete_project_job(job_name)
		puts "Job deleted. jobName: #{job_name}"
	rescue => e
	    puts "Exception occurred while deleting job: #{e}"
	end
	# [END delete_job]
end

def run_basic_job_sample arguments

	require_relative "basic_company_sample"

	command = arguments.shift
	default_project_id = "projects/#{ENV["GOOGLE_CLOUD_PROJECT"]}"
	user_input = arguments.shift
	if command == "create_job"
		company_name = "#{default_project_id}/companies/#{user_input}"
	else
		job_name = "#{default_project_id}/jobs/#{user_input}"
	end

	case command
	when "create_job"
		company_got_test = job_discovery_get_company company_name: company_name
		job_generated_test = job_discovery_generate_job company_name: company_got_test.name
		job_created_test = job_discovery_create_job job_to_be_created: job_generated_test,
													project_id: default_project_id
	when "get_job"
		job_discovery_get_job job_name: job_name
	when "update_job"
		job_got_test = job_discovery_get_job job_name: job_name
		job_got_test.description = "Updated description"
		job_discovery_update_job job_name: job_got_test.name, 
								 job_to_be_updated: job_got_test
	when "update_job_with_field_mask"
		job_got_test = job_discovery_get_job job_name: job_name
		job_got_test.title = "Updated title software Engineer"
		job_discovery_update_job_with_field_mask job_name: job_got_test.name, 
												 field_mask: "title", 
												 job_to_be_updated: job_created_test
	when "delete_job"
		job_discovery_delete_job job_name: job_name
	else
	puts <<-usage
Usage: bundle exec ruby basic_job_sample.rb [command] [arguments]
Commands:
  create_job                  <company_id>   Create a job under a company.
  get_job                     <job_id>       Get a job by name. 
  update_job                  <job_id>       Update a job. 
  update_job_with_field_mask  <job_id>       Update a job with field mask. 
  delete_job                  <job_id>       Delete a job. 
Environment variables:
  GOOGLE_CLOUD_PROJECT must be set to your Google Cloud project ID
    usage
	end
end

if __FILE__ == $PROGRAM_NAME
  run_basic_job_sample ARGV
end