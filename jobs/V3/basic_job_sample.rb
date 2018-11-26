# Copyright 2018 Google, Inc
#
# Licensed under the Apache License, Version 2.0 (the "License")
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

	requisition_id = "jobWithRequiredFields:" + SecureRandom.hex
	application_info = jobs::ApplicationInfo.new :uris => Array["http://careers.google.com"]
	job_generated = jobs::Job.new :requisition_id => requisition_id,
								  :title => " Lab Technician",
								  :company_name => company_name,
								  :employment_types => Array["FULL_TIME"],
								  :language_code => "en-US",
								  :application_info => application_info,
								  :description => "Design, develop, test, deploy, maintain and improve software."
	
	# set compensation to 12 USD/hour
	compensation_entry = jobs::CompensationEntry.new :type => "BASE",
													 :unit => "HOURLY",
													 :amount => (jobs::Money.new :currency_code => "USD",
										  										 :units => 12)
	compensation_info = jobs::CompensationInfo.new :entries => Array[compensation_entry]

	job_generated.compensation_info = compensation_info
	puts "Job generated: #{job_generated.to_json}"
	return job_generated
	# [END generate basic job]
end

def job_discovery_create_job job_to_be_created:, default_project_id:
	# [START create_job]
	# job_to_be_created  = "Job to be created"
	require "google/apis/jobs_v3"

	jobs   = Google::Apis::JobsV3

	talentSolution_client = jobs::CloudTalentSolutionService.new
	talentSolution_client.authorization = Google::Auth.get_application_default(
	"https://www.googleapis.com/auth/jobs"
	)

	begin
		create_job_request = jobs::CreateJobRequest.new :job => job_to_be_created
		job_created = talentSolution_client.create_job(default_project_id, create_job_request)
		puts "Job created: #{job_created.to_json}"
		return job_created
	rescue
		puts "Got exception while creating job"
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
	rescue
		puts "Got exception while getting job"
		splitted_name = job_name.split('/')
		if splitted_name[0] != "projects" || splitted_name[2] != "jobs" || splitted_name[1].empty? || splitted_name[3].empty?
		puts "Invalid jobName format"
		end
	end
	# [END get_job]
end

def job_discovery_update_job job_name:, job_to_be_updated:
	# [START update_job]
	# job_name  = "The name of the job you want to update"
	# job_updated  = "The new job object to be updated"
	require "google/apis/jobs_v3"

	jobs   = Google::Apis::JobsV3

	talentSolution_client = jobs::CloudTalentSolutionService.new
	talentSolution_client.authorization = Google::Auth.get_application_default(
	"https://www.googleapis.com/auth/jobs"
	)

	begin
		update_job_request = jobs::UpdateJobRequest.new :job => job_to_be_updated
		job_updated= talentSolution_client.patch_project_job(job_name, update_job_request)
		puts "Job updated: #{job_updated.to_json}"
		return job_updated
	rescue
		puts "Got exception while updating job"
		splitted_name = job_name.split('/')
		if splitted_name[0] != "projects" || splitted_name[2] != "jobs" || splitted_name[1].empty? || splitted_name[3].empty?
		puts "Invalid jobName format"
		elsif get_job(job_name).nil?
		puts "job doesn't exist"
		end
	end
	# [END update_job]
end

def job_discovery_update_job_with_field_mask job_name:, field_mask:, job_to_be_updated:
	# [START update_job_with_field_mask]
	# job_name  = "The name of the job you want to update"
	# field_mask  = "The field mask you want to update"
	# job_updated  = "The new job object to be updated"

	require "google/apis/jobs_v3"

	jobs   = Google::Apis::JobsV3

	talentSolution_client = jobs::CloudTalentSolutionService.new
	talentSolution_client.authorization = Google::Auth.get_application_default(
	"https://www.googleapis.com/auth/jobs"
	)

	begin
		update_job_request = jobs::UpdateJobRequest.new :job => job_to_be_updated,
													    :update_mask => field_mask
		job_updated= talentSolution_client.patch_project_job(job_name, update_job_request)
		puts "Job updated with filedMask #{update_job_request.update_mask}. Updated job: #{job_updated.to_json}"
		return job_updated
	rescue
		puts "Got exception while updating job with fieldMask"
		splitted_name = job_name.split('/')
		if splitted_name[0] != "projects" || splitted_name[2] != "jobs" || splitted_name[1].empty? || splitted_name[3].empty?
			puts "Invalid jobName format"
		elsif get_job(job_name).nil?
			puts "job doesn't exist"
		end
	end
	# [END update_job_with_field_mask]
end

def job_discovery_delete_job job_name:
	# [START delete_job]
	# job_name  = "The name of the job you want to delete"

	require "google/apis/jobs_v3"

	jobs   = Google::Apis::JobsV3

	talentSolution_client = jobs::CloudTalentSolutionService.new
	talentSolution_client.authorization = Google::Auth.get_application_default(
	"https://www.googleapis.com/auth/jobs"
	)

	begin
		talentSolution_client.delete_project_job(job_name)
		puts "Job deleted. jobName: #{job_name}"
	rescue
		puts "Got exception while deleting job"
		splitted_name = job_name.split('/')
		if splitted_name[0] != "projects" || splitted_name[2] != "jobs" || splitted_name[1].empty? || splitted_name[3].empty?
		puts "Invalid jobName format"
		elsif get_job(job_name).nil?
		puts "job doesn't exist"
		end
	end
	# [END delete_job]
end

def run_basic_job_sample arguments

	require_relative "basic_company_sample"

	command = arguments.shift
	default_project_id = "projects/#{ENV["GOOGLE_CLOUD_PROJECT"]}"

	case command
	when "create_job"
		company_got_test = job_discovery_get_company company_name: arguments.shift
		job_generated_test = job_discovery_generate_job company_name: company_got_test.name
		job_created_test = job_discovery_create_job job_to_be_created: job_generated_test,
													default_project_id: default_project_id
	when "get_job"
		job_discovery_get_job job_name: arguments.shift
	when "update_job"
		job_got_test = job_discovery_get_job job_name: arguments.shift
		job_got_test.description = "Updated description"
		job_discovery_update_job job_name: job_got_test.name, 
								 job_to_be_updated: job_got_test
	when "update_job_with_field_mask"
		job_got_test = job_discovery_get_job job_name: arguments.shift
		job_got_test.title = "Updated title software Engineer"
		job_discovery_update_job_with_field_mask job_name: job_got_test.name, 
												 field_mask: "title", 
												 job_to_be_updated: job_created_test
	when "delete_job"
		job_discovery_delete_job job_name: arguments.shift
	else
	puts <<-usage
Usage: bundle exec ruby basic_job_sample.rb [command] [arguments]
Commands:
  create_job                  <company_name>   Create a job under a company. Name format "projects/`project_id`/companies/`company_id`"
  get_job                     <job_name>       Get a job by name. Name format "projects/`project_id`/jobs/`job_id`"
  update_job                  <job_name>       Update a job. Name format "projects/`project_id`/jobs/`job_id`"
  update_job_with_field_mask  <job_name>       Update a job with field mask. Name format "projects/`project_id`/jobs/`job_id`"
  delete_job                  <job_name>       Delete a job. Name format "projects/`project_id`/jobs/`job_id`"
Environment variables:
  GOOGLE_CLOUD_PROJECT must be set to your Google Cloud project ID
    usage
	end
end

if __FILE__ == $PROGRAM_NAME
  run_basic_job_sample ARGV
end