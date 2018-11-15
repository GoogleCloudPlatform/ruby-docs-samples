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

def generate_job(company_name)
	# [START generate_job]
	require "google/apis/jobs_v3"
	require "securerandom"

	jobs   = Google::Apis::JobsV3;

	requisition_id = "jobWithRequiredFields:" + SecureRandom.hex;
	application_info = jobs::ApplicationInfo.new;
	application_info.uris = Array["http://careers.google.com"];
	job_generated = jobs::Job.new;
	job_generated.requisition_id = requisition_id;
	job_generated.title = " Lab Technician";
	job_generated.company_name = company_name;
	job_generated.employment_types = Array["FULL_TIME"];
	job_generated.language_code = "en-US";
	job_generated.application_info = application_info;
	job_generated.description = "Design, develop, test, deploy, maintain and improve software.";
	
	# set compensation to 12 USD/hour
	compensation_info = jobs::CompensationInfo.new;
	compensation_entry = jobs::CompensationEntry.new;
	compensation_amount = jobs::Money.new;
	compensation_amount.currency_code = "USD";
	compensation_amount.units = 12;
	compensation_entry.type = "BASE";
	compensation_entry.unit = "HOURLY";
	compensation_entry.amount = compensation_amount;
	compensation_info.entries = Array[compensation_entry];

	job_generated.compensation_info = compensation_info;
	puts "Job generated: " + job_generated.to_json;
	return job_generated;
	# [END generate basic job]
end

def create_job(job_to_be_created)
	# [START create_job]
	require "google/apis/jobs_v3"

	jobs   = Google::Apis::JobsV3;
	default_project_id = "projects/" + ENV["GOOGLE_CLOUD_PROJECT"];

	talentSolution_client = jobs::CloudTalentSolutionService.new;
	talentSolution_client.authorization = Google::Auth.get_application_default(
	"https://www.googleapis.com/auth/jobs"
	)

	begin
		create_job_request = jobs::CreateJobRequest.new;
		create_job_request.job = job_to_be_created;
		job_created = talentSolution_client.create_job(default_project_id, create_job_request);
		puts "Job created: " + job_created.to_json;
		return job_created;
	rescue
		puts "Got exception while creating job"
	end
	# [END create_job]
end

def get_job(job_name)
	# [START get_job]
	require "google/apis/jobs_v3"

	jobs   = Google::Apis::JobsV3;

	talentSolution_client = jobs::CloudTalentSolutionService.new;
	talentSolution_client.authorization = Google::Auth.get_application_default(
	"https://www.googleapis.com/auth/jobs"
	)

	begin
		job_got = talentSolution_client.get_project_job(job_name);
		puts "Job got: " + job_got.to_json;
		return job_got;
	rescue
		puts "Got exception while getting job"
		splitted_name = job_name.split('/');
		if splitted_name[0] != "projects" || splitted_name[2] != "jobs" || splitted_name[1].empty? || splitted_name[3].empty?
		puts "Invalid jobName format";
		end
	end
	# [END get_job]
end

def update_job(job_name, job_to_be_updated)
	# [START update_job]
	require "google/apis/jobs_v3"

	jobs   = Google::Apis::JobsV3;

	talentSolution_client = jobs::CloudTalentSolutionService.new;
	talentSolution_client.authorization = Google::Auth.get_application_default(
	"https://www.googleapis.com/auth/jobs"
	)

	begin
		update_job_request = jobs::UpdateJobRequest.new;
		update_job_request.job = job_to_be_updated;
		job_updated= talentSolution_client.patch_project_job(job_name, update_job_request);
		puts "Job updated: " + job_updated.to_json;
		return job_updated;
	rescue
		puts "Got exception while updating job"
		splitted_name = job_name.split('/');
		if splitted_name[0] != "projects" || splitted_name[2] != "jobs" || splitted_name[1].empty? || splitted_name[3].empty?
		puts "Invalid jobName format";
		elsif get_job(job_name).nil?
		puts "job doesn't exist";
		end
	end
	# [END update_job]
end

def update_job_with_field_mask(job_name, field_mask, job_to_be_updated)
	# [START update_job_with_field_mask]
	require "google/apis/jobs_v3"

	jobs   = Google::Apis::JobsV3;

	talentSolution_client = jobs::CloudTalentSolutionService.new;
	talentSolution_client.authorization = Google::Auth.get_application_default(
	"https://www.googleapis.com/auth/jobs"
	)

	begin
		update_job_request = jobs::UpdateJobRequest.new;
		update_job_request.job = job_to_be_updated;
		update_job_request.update_mask = field_mask;
		job_updated= talentSolution_client.patch_project_job(job_name, update_job_request);
		puts "Job updated with filedMask " + update_job_request.update_mask + ". Updated job: " + job_updated.to_json;
		return job_updated;
	rescue
		puts "Got exception while updating job with fieldMask"
		splitted_name = job_name.split('/');
		if splitted_name[0] != "projects" || splitted_name[2] != "jobs" || splitted_name[1].empty? || splitted_name[3].empty?
			puts "Invalid jobName format";
		elsif get_job(job_name).nil?
			puts "job doesn't exist";
		end
	end
	# [END update_job_with_field_mask]
end

def delete_job(job_name)
	# [START delete_job]
	require "google/apis/jobs_v3"

	jobs   = Google::Apis::JobsV3;

	talentSolution_client = jobs::CloudTalentSolutionService.new;
	talentSolution_client.authorization = Google::Auth.get_application_default(
	"https://www.googleapis.com/auth/jobs"
	)

	begin
		talentSolution_client.delete_project_job(job_name);
		puts "Job deleted. jobName: " + job_name;
	rescue
		puts "Got exception while deleting job"
		splitted_name = job_name.split('/');
		if splitted_name[0] != "projects" || splitted_name[2] != "jobs" || splitted_name[1].empty? || splitted_name[3].empty?
		puts "Invalid jobName format";
		elsif get_job(job_name).nil?
		puts "job doesn't exist";
		end
	end
	# [END delete_job]
end

def run_basic_job_sample arguments

	require_relative "basic_company_sample"

	command = arguments.shift
	default_project_id = "projects/" + ENV["GOOGLE_CLOUD_PROJECT"];

	case command
	when "create_job", "delete_job"
		company_created_test = create_company(generate_company());
		job_generated_test = generate_job(company_created_test.name);
		job_created_test = create_job(job_generated_test);
		delete_job(job_created_test.name);
		delete_company(company_created_test.name);
	when "get_job"
		company_created_test = create_company(generate_company());
		job_generated_test = generate_job(company_created_test.name);
		job_created_test = create_job(job_generated_test);
		get_job(job_created_test.name);
		delete_job(job_created_test.name);
		delete_company(company_created_test.name);
	when "update_job"
		company_created_test = create_company(generate_company());
		job_generated_test = generate_job(company_created_test.name);
		job_created_test = create_job(job_generated_test);
		job_created_test.description = "Updated description";
		update_job(job_created_test.name, job_created_test);
		delete_job(job_created_test.name);
		delete_company(company_created_test.name);
	when "update_job_with_field_mask"
		company_created_test = create_company(generate_company());
		job_generated_test = generate_job(company_created_test.name);
		job_created_test = create_job(job_generated_test);
		job_created_test.title = "Updated title software Engineer";
		update_job_with_field_mask(job_created_test.name, "title", job_created_test);
		delete_job(job_created_test.name);
		delete_company(company_created_test.name);
	else
	puts <<-usage
Usage: bundle exec ruby basic_job_sample.rb [command] [arguments]
Commands:
  create_job                  Create a job
  get_job                     Get a job
  update_job                  Update a job
  update_job_with_field_mask  Update a job with field mask
  delete_job                  Delete a job
Environment variables:
  GOOGLE_CLOUD_PROJECT must be set to your Google Cloud project ID
    usage
	end
end

if __FILE__ == $PROGRAM_NAME
  run_basic_job_sample ARGV
end