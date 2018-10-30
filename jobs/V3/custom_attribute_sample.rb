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
	This file contains the samples about CustomAttribute, including:
	- Construct a Job with CustomAttribute
	- Search Job with CustomAttributeFilter
=end

class CustomAttributeSample
	# Instantiate the client
	@@Jobs   = Google::Apis::JobsV3
	@@DEFAULT_PROJECT_ID = "projects/" + ENV["GOOGLE_CLOUD_PROJECT"];
		
	@@talentSolution_client = @@Jobs::CloudTalentSolutionService.new
	# @see https://developers.google.com/identity/protocols/application-default-credentials#callingruby
	@@talentSolution_client.authorization = Google::Auth.get_application_default(
		"https://www.googleapis.com/auth/jobs"
	)

# [START generate_job_with_a_custom_attribute]
=begin 
		Generate a job with a custom attribute.
=end
	def generateJobWithACustomAttribute(companyName)
		requisitionId = "jobWithRequiredFields:" + SecureRandom.hex;
		applicationInfo = @@Jobs::ApplicationInfo.new;
		applicationInfo.uris = Array["http://careers.google.com"];

		# Constructs custom attributes map
		customAttributes = Hash.new;
		# First custom attribute
		customAttributes["someFieldName1"] = @@Jobs::CustomAttribute.new;
		customAttributes["someFieldName1"].string_values = Array["value1"];
		customAttributes["someFieldName1"].filterable = true;
		# Second custom attribute
		customAttributes["someFieldName2"] = @@Jobs::CustomAttribute.new;
		customAttributes["someFieldName2"].long_values = Array[256];
		customAttributes["someFieldName2"].filterable = true;

		# Creates job with custom attributes
		jobGenerated = @@Jobs::Job.new;
		jobGenerated.requisition_id = requisitionId;
		jobGenerated.title = " Lab Technician";
		jobGenerated.company_name = companyName;
		jobGenerated.application_info = applicationInfo;
		jobGenerated.description = "Design, develop, test, deploy, maintain and improve software.";
		jobGenerated.custom_attributes = customAttributes;

		puts "Featured Job generated: " + jobGenerated.to_json;
		return jobGenerated;
	end
# [END generate_job_with_a_custom_attribute]

# [START custom_attribute_filter_long_value]
=begin 
		CustomAttributeFilter on Long value CustomAttribute
=end
	def filtersOnLongValueCustomAttribute()
		# Make sure to set the requestMetadata the same as the associated search request
		requestMetadata = @@Jobs::RequestMetadata.new;
		# Make sure to hash your userID
		requestMetadata.user_id = "HashedUserId";
		# Make sure to hash the sessionID
		requestMetadata.session_id = "HashedSessionId";
		# Domain of the website where the search is conducted
		requestMetadata.domain = "www.google.com";

		customAttributeFilter = "(255 <= someFieldName2) AND (someFieldName2 <= 257)";

		# Perform a search for analyst  related jobs
		jobQuery = @@Jobs::JobQuery.new;
		jobQuery.custom_attribute_filter = customAttributeFilter;
		
		searchJobsRequest = @@Jobs::SearchJobsRequest.new;
		searchJobsRequest.request_metadata = requestMetadata;
		# Set the actual search term as defined in the jobQurey
		searchJobsRequest.job_query = jobQuery;
		# Set the search mode to a regular search
		searchJobsRequest.job_view = "JOB_VIEW_FULL"

		searchJobsResponse = @@talentSolution_client.search_jobs(@@DEFAULT_PROJECT_ID, searchJobsRequest);

		puts searchJobsResponse.to_json;
	end
# [END custom_attribute_filter_long_value]

# [START custom_attribute_filter_string_value]
=begin 
		CustomAttributeFilter on String value CustomAttribute.
=end
	def filtersOnStringValueCustomAttribute()
		# Make sure to set the requestMetadata the same as the associated search request
		requestMetadata = @@Jobs::RequestMetadata.new;
		# Make sure to hash your userID
		requestMetadata.user_id = "HashedUserId";
		# Make sure to hash the sessionID
		requestMetadata.session_id = "HashedSessionId";
		# Domain of the website where the search is conducted
		requestMetadata.domain = "www.google.com";

		customAttributeFilter = "NOT EMPTY(someFieldName1)";

		# Perform a search for analyst  related jobs
		jobQuery = @@Jobs::JobQuery.new;
		jobQuery.custom_attribute_filter = customAttributeFilter;
		
		searchJobsRequest = @@Jobs::SearchJobsRequest.new;
		searchJobsRequest.request_metadata = requestMetadata;
		# Set the actual search term as defined in the jobQurey
		searchJobsRequest.job_query = jobQuery;
		# Set the search mode to a regular search
		searchJobsRequest.job_view = "JOB_VIEW_FULL"

		searchJobsResponse = @@talentSolution_client.search_jobs(@@DEFAULT_PROJECT_ID, searchJobsRequest);

		puts searchJobsResponse.to_json;
	end
# [END custom_attribute_filter_string_value]

# [START custom_attribute_filter_multi_attributes]
=begin 
		CustomAttributeFilter on multiple CustomAttributes.
=end
	def filtersOnMultiCustomAttributes()
		# Make sure to set the requestMetadata the same as the associated search request
		requestMetadata = @@Jobs::RequestMetadata.new;
		# Make sure to hash your userID
		requestMetadata.user_id = "HashedUserId";
		# Make sure to hash the sessionID
		requestMetadata.session_id = "HashedSessionId";
		# Domain of the website where the search is conducted
		requestMetadata.domain = "www.google.com";

		customAttributeFilter = "(someFieldName1 = \"value1\") "
        + "AND ((255 <= someFieldName2) OR (someFieldName2 <= 213))";

		# Perform a search for analyst  related jobs
		jobQuery = @@Jobs::JobQuery.new;
		jobQuery.custom_attribute_filter = customAttributeFilter;
		
		searchJobsRequest = @@Jobs::SearchJobsRequest.new;
		searchJobsRequest.request_metadata = requestMetadata;
		# Set the actual search term as defined in the jobQurey
		searchJobsRequest.job_query = jobQuery;
		# Set the search mode to a regular search
		searchJobsRequest.job_view = "JOB_VIEW_FULL"

		searchJobsResponse = @@talentSolution_client.search_jobs(@@DEFAULT_PROJECT_ID, searchJobsRequest);

		puts searchJobsResponse.to_json;
	end
# [END custom_attribute_filter_multi_attributes]

end

# Test main. Run only if file is being executed directly or being called by ../spec/samples_spec.rb
if (ARGV.include? File.basename(__FILE__)) || 
	((File.basename(caller[0]).include? "samples_spec.rb") && (File.basename(caller[0]).include? "load"))
	# test
	company = BasicCompanySample.new;
	job = BasicJobSample.new;
	job_with_custom_attribute = CustomAttributeSample.new;
	
	company_created_test = company.createCompany(company.generateCompany());
	job_generated_test = job_with_custom_attribute.generateJobWithACustomAttribute(company_created_test.name);
	job_created_test = job.createJob(job_generated_test);

	sleep(10);
	
	job_with_custom_attribute.filtersOnLongValueCustomAttribute();
	job_with_custom_attribute.filtersOnStringValueCustomAttribute();
	job_with_custom_attribute.filtersOnMultiCustomAttributes();

	job.deleteJob(job_created_test.name);
	company.deleteCompany(company_created_test.name);
	
end