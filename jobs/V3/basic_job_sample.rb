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

require "google/apis/jobs_v3"
require "rails"
require 'securerandom'
require_relative 'basic_company_sample'

=begin
	This file contains the basic knowledge about company and job, including:
	- Construct a company with required fields
	- Create a company
	- Get a company
	- Update a company
	- Update a company with field mask
	- Delete a company
=end

class BasicJobSample

	# Instantiate the client
	@@Jobs   = Google::Apis::JobsV3
	# ProjectId to get company list
	@@DEFAULT_PROJECT_ID = "projects/" + ENV["GOOGLE_CLOUD_PROJECT"];


	@@talentSolution_client = @@Jobs::CloudTalentSolutionService.new
	# @see https://developers.google.com/identity/protocols/application-default-credentials#callingruby
	@@talentSolution_client.authorization = Google::Auth.get_application_default(
		"https://www.googleapis.com/auth/jobs"
	)

# [START generate_job]
=begin 
		Generate a job with given company name for testing purpose
=end
	def generateJob(companyName)
		requisitionId = "jobWithRequiredFields:" + SecureRandom.hex;
		applicationInfo = @@Jobs::ApplicationInfo.new;
		applicationInfo.uris = Array["http://careers.google.com"];
		jobGenerated = @@Jobs::Job.new;
		jobGenerated.requisition_id = requisitionId;
		jobGenerated.title = " Lab Technician";
		jobGenerated.company_name = companyName;
		jobGenerated.employment_types = Array["FULL_TIME"];
		jobGenerated.language_code = "en-US";
		jobGenerated.application_info = applicationInfo;
		jobGenerated.description = "Design, develop, test, deploy, maintain and improve software.";
		
		# set compensation to 12 USD/hour
		compensationInfo = @@Jobs::CompensationInfo.new;
		compensationEntry = @@Jobs::CompensationEntry.new;
		compensationAmount = @@Jobs::Money.new;
		compensationAmount.currency_code = "USD";
		compensationAmount.units = 12;
		compensationEntry.type = "BASE";
		compensationEntry.unit = "HOURLY";
		compensationEntry.amount = compensationAmount;
		compensationInfo.entries = Array[compensationEntry];

		jobGenerated.compensation_info = compensationInfo;
		puts "Job generated: " + jobGenerated.to_json;
		return jobGenerated;
	end
# [END generate basic job]

# [START create_job]
=begin 
		Create a job
=end
	def createJob(jobToBeCreated)
		begin
			createJobRequest = @@Jobs::CreateJobRequest.new;
			createJobRequest.job = jobToBeCreated;
			jobCreated = @@talentSolution_client.create_job(@@DEFAULT_PROJECT_ID, createJobRequest);
			puts "Job created: " + jobCreated.to_json;
			return jobCreated;
		rescue
			puts "Got exception while creating job"
		end
	end
# [END create_job]

# [START get_job]
=begin 
		Get a job
=end
	def getJob(jobName)
		begin
			jobGot = @@talentSolution_client.get_project_job(jobName);
			puts "Job got: " + jobGot.to_json;
			return jobGot;
		rescue
			puts "Got exception while getting job"
			splitted_name = jobName.split('/');
			if splitted_name[0] != "projects" || splitted_name[2] != "jobs" || splitted_name[1].empty? || splitted_name[3].empty?
				puts "Invalid jobName format";
			end
		end
	end
# [END get_job]

# [START update_job]
=begin 
		Update a job
=end
	def updateJob(jobName, jobToBeUpdated)
		begin
			updateJobRequest = @@Jobs::UpdateJobRequest.new;
			updateJobRequest.job = jobToBeUpdated;
			jobUpdated= @@talentSolution_client.patch_project_job(jobName, updateJobRequest);
			puts "Job updated: " + jobUpdated.to_json;
			return jobUpdated;
		rescue
			puts "Got exception while updating job"
			splitted_name = jobName.split('/');
			if splitted_name[0] != "projects" || splitted_name[2] != "jobs" || splitted_name[1].empty? || splitted_name[3].empty?
				puts "Invalid jobName format";
			elsif getJob(jobName).nil?
				puts "job doesn't exist";
			end
		end
	end
# [END update_job]

# [START update_job_with_field_mask]
=begin 
		Update a job with field mask
=end
	def updateJobWithFieldMask(jobName, fieldMask, jobToBeUpdated)
		begin
			updateJobRequest = @@Jobs::UpdateJobRequest.new;
			updateJobRequest.job = jobToBeUpdated;
			updateJobRequest.update_mask = fieldMask;
			jobUpdated= @@talentSolution_client.patch_project_job(jobName, updateJobRequest);
			puts "Job updated with filedMask " + updateJobRequest.update_mask + ". Updated job: " + jobUpdated.to_json;
			return jobUpdated;
		rescue
			puts "Got exception while updating job with fieldMask"
			splitted_name = jobName.split('/');
			if splitted_name[0] != "projects" || splitted_name[2] != "jobs" || splitted_name[1].empty? || splitted_name[3].empty?
				puts "Invalid jobName format";
			elsif getJob(jobName).nil?
				puts "job doesn't exist";
			end
		end
	end
# [END update_job_with_field_mask]

# [START delete_job]
=begin 
		Delete a job
=end
	def deleteJob(jobName)
		begin
			@@talentSolution_client.delete_project_job(jobName);
			puts "Job deleted. jobName: " + jobName;
		rescue
			puts "Got exception while deleting job"
			splitted_name = jobName.split('/');
			if splitted_name[0] != "projects" || splitted_name[2] != "jobs" || splitted_name[1].empty? || splitted_name[3].empty?
				puts "Invalid jobName format";
			elsif getJob(jobName).nil?
				puts "job doesn't exist";
			end
		end
	end
# [END delete_job]
end

# Test main. Run only if file is being executed directly or being called by ../spec/samples_spec.rb
if (ARGV.include? File.basename(__FILE__)) || 
	((File.basename(caller[0]).include? "samples_spec.rb") && (File.basename(caller[0]).include? "load"))
	# test
	company = BasicCompanySample.new
	job = BasicJobSample.new
	# createCompany
	### positive test
	company_created_test = company.createCompany(company.generateCompany());
	job_generated_test = job.generateJob(company_created_test.name);
	job_created_test = job.createJob(job_generated_test);
	### negtive test --create duplicated company
	job.createJob(job_generated_test);

	# getJob 
	### negtive test -- get job with invalid name
	job.getJob("projects\\companies\\"+job_created_test.requisition_id);
	### positive test
	job.getJob(job_created_test.name);

	# updateJob
	### positive test
	job_created_test.description = "Updated description";
	job.updateJob(job_created_test.name, job_created_test);
	### negtive test -- update company with invalid name
	job.updateJob("projects\\companies\\" + job_created_test.requisition_id, job_created_test);
	### negtive test -- update nonexisted company
	job.updateJob(job_created_test.name+"aa", company_created_test);


	# updateJobWithFieldMask
	### positive test
	job_created_test.title = "Updated title software Engineer";
	job.updateJobWithFieldMask(job_created_test.name, "title", job_created_test);

	#deleteJob
	job.deleteJob(job_created_test.name+"aa");
	job.deleteJob("projects\\companies\\"+job_created_test.requisition_id);
	### positive test
	job.deleteJob(job_created_test.name);

	company.deleteCompany(company_created_test.name);
end