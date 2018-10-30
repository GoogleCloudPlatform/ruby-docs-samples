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
require_relative 'basic_job_sample'

=begin
	The sample in this file introduce featured job, including:
	- Construct a featured job
	- Search featured job
=end

class FeaturedJobSample

	# Instantiate the client
	@@Jobs   = Google::Apis::JobsV3
	# ProjectId to get company list
	@@DEFAULT_PROJECT_ID = "projects/" + ENV["GOOGLE_CLOUD_PROJECT"];


	@@talentSolution_client = @@Jobs::CloudTalentSolutionService.new
	# @see https://developers.google.com/identity/protocols/application-default-credentials#callingruby
	@@talentSolution_client.authorization = Google::Auth.get_application_default(
		"https://www.googleapis.com/auth/jobs"
	)

# [START generate_featured_job]
=begin 
		Generate a featured job with given company name for testing purpose
=end
	def generateFeaturedJob(companyName)
		requisitionId = "jobWithRequiredFields:" + SecureRandom.hex;
		applicationInfo = @@Jobs::ApplicationInfo.new;
		applicationInfo.uris = Array["http://careers.google.com"];
		jobGenerated = @@Jobs::Job.new;
		jobGenerated.requisition_id = requisitionId;
		jobGenerated.title = " Lab Technician";
		jobGenerated.company_name = companyName;
		jobGenerated.application_info = applicationInfo;
		jobGenerated.description = "Design, develop, test, deploy, maintain and improve software.";
		# Featured job is the job with positive promotion value
		jobGenerated.promotion_value = 2;
		puts "Featured Job generated: " + jobGenerated.to_json;
		return jobGenerated;
	end
# [END generate_featured_job]

# [START search_featured_job]
=begin 
		Simple search featured jobs with keyword.
=end
	def featuredJobsSearch(companyName, query)
		# Make sure to set the requestMetadata the same as the associated search request
		requestMetadata = @@Jobs::RequestMetadata.new;
		# Make sure to hash your userID
		requestMetadata.user_id = "HashedUserId";
		# Make sure to hash the sessionID
		requestMetadata.session_id = "HashedSessionId";
		# Domain of the website where the search is conducted
		requestMetadata.domain = "www.google.com";

		# Perform a search for analyst  related jobs
		jobQuery = @@Jobs::JobQuery.new;
		jobQuery.query = query;
		if !companyName.nil?
			jobQuery.company_names = Array[companyName];
		end

		searchJobsRequest = @@Jobs::SearchJobsRequest.new;
		searchJobsRequest.request_metadata = requestMetadata;
		# Set the actual search term as defined in the jobQurey
		searchJobsRequest.job_query = jobQuery;
		# Set the search mode to a regular search
		searchJobsRequest.search_mode = "FEATURED_JOB_SEARCH"

		searchJobsResponse = @@talentSolution_client.search_jobs(@@DEFAULT_PROJECT_ID, searchJobsRequest);

		puts searchJobsResponse.to_json;
	end
# [END basic_keyword_search]

end

# Test main. Run only if file is being executed directly or being called by ../spec/samples_spec.rb
if (ARGV.include? File.basename(__FILE__)) || 
	((File.basename(caller[0]).include? "samples_spec.rb") && (File.basename(caller[0]).include? "load"))
	# test
	company = BasicCompanySample.new;
	job = BasicJobSample.new;
	featured_job = FeaturedJobSample.new;
	
	company_created_test = company.createCompany(company.generateCompany());
	job_generated_test = featured_job.generateFeaturedJob(company_created_test.name);
	job_created_test = job.createJob(job_generated_test);

	sleep(10);
	
	featured_job.featuredJobsSearch(job_created_test.company_name, job_created_test.title);

	job.deleteJob(job_created_test.name);
	company.deleteCompany(company_created_test.name);
end