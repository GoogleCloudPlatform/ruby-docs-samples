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
	This file introduce how to do batch operation in CJD. Including:
	- Create job within batch
	- Update job within batch
	- Delete job within batch
	For simplicity, the samples always use the same kind of requests in each batch. In a real case ,
    you might put different kinds of request in one batch.
=end

class BatchOperationSample
	# Instantiate the client
	@@Jobs   = Google::Apis::JobsV3
	@@DEFAULT_PROJECT_ID = "projects/" + ENV["GOOGLE_CLOUD_PROJECT"];
		
	@@talentSolution_client = @@Jobs::CloudTalentSolutionService.new
	# @see https://developers.google.com/identity/protocols/application-default-credentials#callingruby
	@@talentSolution_client.authorization = Google::Auth.get_application_default(
		"https://www.googleapis.com/auth/jobs"
	)


# [START batch_create_jobs]
=begin 
		Batch create a few jobs
=end
	def batchCreateJobs(companyName)
		jobsCreated = Array.new;
		callback = lambda { |job, err| 
						if err.nil?
							jobsCreated.push job;
						else
							puts "Batch job create error message: " + err.message;
						end
					  }
		
		applicationInfo = @@Jobs::ApplicationInfo.new;
		applicationInfo.uris = Array["http://careers.google.com"];
		
		requisitionId1 = "jobWithRequiredFields:" + SecureRandom.hex;
		jobGenerated1 = @@Jobs::Job.new;
		jobGenerated1.requisition_id = requisitionId1;
		jobGenerated1.title = " Lab Technician";
		jobGenerated1.company_name = companyName;
		jobGenerated1.employment_types = Array["FULL_TIME"];
		jobGenerated1.language_code = "en-US";
		jobGenerated1.application_info = applicationInfo;
		jobGenerated1.description = "Design and improve software.";

		requisitionId2 = "jobWithRequiredFields:" + SecureRandom.hex;
		jobGenerated2 = @@Jobs::Job.new;
		jobGenerated2.requisition_id = requisitionId2;
		jobGenerated2.title = "Systems Administrator";
		jobGenerated2.company_name = companyName;
		jobGenerated2.employment_types = Array["FULL_TIME"];
		jobGenerated2.language_code = "en-US";
		jobGenerated2.application_info = applicationInfo;
		jobGenerated2.description = "System Administrator for software.";

		createJobRequest1 = @@Jobs::CreateJobRequest.new;
		createJobRequest1.job = jobGenerated1;
		createJobRequest2 = @@Jobs::CreateJobRequest.new;
		createJobRequest2.job = jobGenerated2;

		@@talentSolution_client.batch do |s|
			s.create_job(@@DEFAULT_PROJECT_ID, createJobRequest1, &callback);
			s.create_job(@@DEFAULT_PROJECT_ID, createJobRequest2, &callback);
		end
		# jobCreated = batchCreate.create_job(@@DEFAULT_PROJECT_ID, createJobRequest1);
		puts "Batch job created: " + jobsCreated.to_json;
		return jobsCreated;
	end
# [END batch_create_jobs]

# [START batch_update_jobs]
=begin 
		Batch update a few jobs
=end
	def batchUpdateJobs(jobToBeUpdated)
		jobsUpdated = Array.new;
		callback = lambda { |job, err| 
						if err.nil?
							jobsUpdated.push job;
						else
							puts "Batch job updated error message: " + err.message;
						end
					  }


		updateJobWithMaskRequests = Array.new;
		jobToBeUpdated.each{ |job|
			request = @@Jobs::UpdateJobRequest.new;
			request.job = job;
			request.update_mask = "title";
			updateJobWithMaskRequests.push request;
		}
		
		@@talentSolution_client.batch do |s|
			updateJobWithMaskRequests.each{ |updateJobWithMaskRequest|
				s.patch_project_job(updateJobWithMaskRequest.job.name, updateJobWithMaskRequest, &callback);
			}
		end
		puts "Batch job updated with Mask: " + jobsUpdated.to_json;

		jobsUpdated.clear;
		updateJobRequests = Array.new;
		jobToBeUpdated.each{ |job|
			request = @@Jobs::UpdateJobRequest.new;
			request.job = job;
			updateJobRequests.push request;
		}
		
		@@talentSolution_client.batch do |s|
			updateJobRequests.each{ |updateJobRequest|
				s.patch_project_job(updateJobRequest.job.name, updateJobRequest, &callback);
			}
		end
		# jobCreated = batchCreate.create_job(@@DEFAULT_PROJECT_ID, createJobRequest1);
		puts "Batch job updated: " + jobsUpdated.to_json;

		return jobsUpdated;
	end
# [END batch_create_jobs]

# [START batch_delete_jobs]
=begin 
		Batch delete a few jobs
=end
	def batchDeleteJobs(jobToBeDeleted)
		jobsDeleted = 0;
		callback = lambda { |job, err| 
						if err.nil?
							jobsDeleted += 1;
						else
							puts "Updated error message: " + err.message;
						end
					  }

		@@talentSolution_client.batch do |s|
			jobToBeDeleted.each{ |jobName|
				s.delete_project_job(jobName, &callback);
			}
		end
		# jobCreated = batchCreate.create_job(@@DEFAULT_PROJECT_ID, createJobRequest1);
		puts "Batch job deleted.";

		return jobsDeleted;
	end
# [END batch_delete_jobs]

end

# Test main. Run only if file is being executed directly or being called by ../spec/samples_spec.rb
if (ARGV.include? File.basename(__FILE__)) || 
	((File.basename(caller[0]).include? "samples_spec.rb") && (File.basename(caller[0]).include? "load"))
	# test
	company = BasicCompanySample.new
	batchJob = BatchOperationSample.new
	# createCompany
	### positive test
	company_created_test = company.createCompany(company.generateCompany());
	jobs_created_test = batchJob.batchCreateJobs(company_created_test.name);

	jobs_created_test.each{ |job|
		job.title = job.title + " updated";
		job.description = job.description + " updated";
	}

	jobs_updated_test = batchJob.batchUpdateJobs(jobs_created_test);

	jobNames = Array.new;
	jobs_updated_test.each{ |job|
		jobNames.push job.name;
	}
	batchJob.batchDeleteJobs(jobNames);
end