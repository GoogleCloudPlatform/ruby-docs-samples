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
	The samples in this file introduce how to do a general search, including:
	- Basic keyword search
	- Filter on categories
	- Filter on employment types
	- Filter on date range
	- Filter on language codes
	- Filter on company display names
	- Filter on compensations
=end

class FilterSearchSample
	# Instantiate the client
	@@Jobs   = Google::Apis::JobsV3
	@@DEFAULT_PROJECT_ID = "projects/" + ENV["GOOGLE_CLOUD_PROJECT"];
		
	@@talentSolution_client = @@Jobs::CloudTalentSolutionService.new
	# @see https://developers.google.com/identity/protocols/application-default-credentials#callingruby
	@@talentSolution_client.authorization = Google::Auth.get_application_default(
		"https://www.googleapis.com/auth/jobs"
	)

# [START basic_keyword_search]
=begin 
		Simple search jobs with keyword.
=end
	def basicKeywordSearch(companyName, query)
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
		searchJobsRequest.search_mode = "JOB_SEARCH"

		searchJobsResponse = @@talentSolution_client.search_jobs(@@DEFAULT_PROJECT_ID, searchJobsRequest);

		puts searchJobsResponse.to_json;
	end
# [END basic_keyword_search]

# [START basic_category_filter_search]
=begin 
		Simple search jobs with categoryFilter.
=end
	def categoryFilterSearch(companyName, categories)
		# Make sure to set the requestMetadata the same as the associated search request
		requestMetadata = @@Jobs::RequestMetadata.new;
		# Make sure to hash your userID
		requestMetadata.user_id = "HashedUserId";
		# Make sure to hash the sessionID
		requestMetadata.session_id = "HashedSessionId";
		# Domain of the website where the search is conducted
		requestMetadata.domain = "http://careers.google.com";

		# Perform a search for analyst  related jobs
		jobQuery = @@Jobs::JobQuery.new;
		jobQuery.job_categories = Array.new(categories);
		if !companyName.nil?
			jobQuery.company_names = Array[companyName];
		end

		searchJobsRequest = @@Jobs::SearchJobsRequest.new;
		searchJobsRequest.request_metadata = requestMetadata;
		# Set the actual search term as defined in the jobQurey
		searchJobsRequest.job_query = jobQuery;
		# Set the search mode to a regular search
		searchJobsRequest.search_mode = "JOB_SEARCH";

		searchJobsResponse = @@talentSolution_client.search_jobs(@@DEFAULT_PROJECT_ID, searchJobsRequest);

		puts searchJobsResponse.to_json;
	end
# [END basic_keyword_search]

# [START employment_types_filter_search]
=begin 
		Simple search jobs with employment types filter.
=end
	def employmentTypesFilterSearch(companyName, employmentTypes)
		# Make sure to set the requestMetadata the same as the associated search request
		requestMetadata = @@Jobs::RequestMetadata.new;
		# Make sure to hash your userID
		requestMetadata.user_id = "HashedUserId";
		# Make sure to hash the sessionID
		requestMetadata.session_id = "HashedSessionId";
		# Domain of the website where the search is conducted
		requestMetadata.domain = "http://careers.google.com";

		# Perform a search for analyst  related jobs
		jobQuery = @@Jobs::JobQuery.new;
		jobQuery.employment_types = Array.new(employmentTypes);
		if !companyName.nil?
			jobQuery.company_names = Array[companyName];
		end

		searchJobsRequest = @@Jobs::SearchJobsRequest.new;
		searchJobsRequest.request_metadata = requestMetadata;
		# Set the actual search term as defined in the jobQurey
		searchJobsRequest.job_query = jobQuery;
		# Set the search mode to a regular search
		searchJobsRequest.search_mode = "JOB_SEARCH"

		searchJobsResponse = @@talentSolution_client.search_jobs(@@DEFAULT_PROJECT_ID, searchJobsRequest);

		puts searchJobsResponse.to_json;
	end
# [END employment_types_filter_search]

# [START date_range_filter_search]
=begin 
		Simple search jobs with date range filter.
=end
	def dateRangeFilterSearch(companyName, startTime, endTime)
		# Make sure to set the requestMetadata the same as the associated search request
		requestMetadata = @@Jobs::RequestMetadata.new;
		# Make sure to hash your userID
		requestMetadata.user_id = "HashedUserId";
		# Make sure to hash the sessionID
		requestMetadata.session_id = "HashedSessionId";
		# Domain of the website where the search is conducted
		requestMetadata.domain = "http://careers.google.com";

		# Perform a search for analyst  related jobs
		jobQuery = @@Jobs::JobQuery.new;
		timestampRange = @@Jobs::TimestampRange.new
		timestampRange.start_time = startTime;
		timestampRange.end_time = endTime;
		jobQuery.publish_time_range = timestampRange;

		if !companyName.nil?
			jobQuery.company_names = Array[companyName];
		end

		searchJobsRequest = @@Jobs::SearchJobsRequest.new;
		searchJobsRequest.request_metadata = requestMetadata;
		# Set the actual search term as defined in the jobQurey
		searchJobsRequest.job_query = jobQuery;
		# Set the search mode to a regular search
		searchJobsRequest.search_mode = "JOB_SEARCH"

		searchJobsResponse = @@talentSolution_client.search_jobs(@@DEFAULT_PROJECT_ID, searchJobsRequest);

		puts searchJobsResponse.to_json;
	end
# [END date_range_filter_search]

# [START language_code_filter_search]
=begin 
		Simple search jobs with language code filter.
=end
	def languageCodeFilterSearch(companyName, languageCodes)
		# Make sure to set the requestMetadata the same as the associated search request
		requestMetadata = @@Jobs::RequestMetadata.new;
		# Make sure to hash your userID
		requestMetadata.user_id = "HashedUserId";
		# Make sure to hash the sessionID
		requestMetadata.session_id = "HashedSessionId";
		# Domain of the website where the search is conducted
		requestMetadata.domain = "http://careers.google.com";

		# Perform a search for analyst  related jobs
		jobQuery = @@Jobs::JobQuery.new;
		jobQuery.language_codes = Array.new(languageCodes);
		if !companyName.nil?
			jobQuery.company_names = Array[companyName];
		end

		searchJobsRequest = @@Jobs::SearchJobsRequest.new;
		searchJobsRequest.request_metadata = requestMetadata;
		# Set the actual search term as defined in the jobQurey
		searchJobsRequest.job_query = jobQuery;
		# Set the search mode to a regular search
		searchJobsRequest.search_mode = "JOB_SEARCH"

		searchJobsResponse = @@talentSolution_client.search_jobs(@@DEFAULT_PROJECT_ID, searchJobsRequest);

		puts searchJobsResponse.to_json;
	end
# [END language_code_filter_search]

# [START company_display_name_filter_search]
=begin 
		Simple search jobs with company display name filter.
=end
	def companyDisplayNameFilterSearch(companyName, companyDisplayNames)
		# Make sure to set the requestMetadata the same as the associated search request
		requestMetadata = @@Jobs::RequestMetadata.new;
		# Make sure to hash your userID
		requestMetadata.user_id = "HashedUserId";
		# Make sure to hash the sessionID
		requestMetadata.session_id = "HashedSessionId";
		# Domain of the website where the search is conducted
		requestMetadata.domain = "http://careers.google.com";

		# Perform a search for analyst  related jobs
		jobQuery = @@Jobs::JobQuery.new;
		jobQuery.company_display_names = Array.new(companyDisplayNames);
		if !companyName.nil?
			jobQuery.company_names = Array[companyName];
		end

		searchJobsRequest = @@Jobs::SearchJobsRequest.new;
		searchJobsRequest.request_metadata = requestMetadata;
		# Set the actual search term as defined in the jobQurey
		searchJobsRequest.job_query = jobQuery;
		# Set the search mode to a regular search
		searchJobsRequest.search_mode = "JOB_SEARCH"

		searchJobsResponse = @@talentSolution_client.search_jobs(@@DEFAULT_PROJECT_ID, searchJobsRequest);

		puts searchJobsResponse.to_json;
	end
# [END company_display_name_filter_search]

# [START compensation_search]
=begin 
		Simple search jobs with compensation.
=end
	def compensationSearch(companyName)
		# Make sure to set the requestMetadata the same as the associated search request
		requestMetadata = @@Jobs::RequestMetadata.new;
		# Make sure to hash your userID
		requestMetadata.user_id = "HashedUserId";
		# Make sure to hash the sessionID
		requestMetadata.session_id = "HashedSessionId";
		# Domain of the website where the search is conducted
		requestMetadata.domain = "http://careers.google.com";

		# Perform a search for analyst  related jobs
		jobQuery = @@Jobs::JobQuery.new;
		compensationFilter = @@Jobs::CompensationFilter.new;
		compensationRange = @@Jobs::CompensationRange.new
		# Search jobs that pay between 0 and 15.5 USD per hour
		compensationMax = @@Jobs::Money.new;
		compensationMax.currency_code = "USD";
		compensationMax.units = 15;
		compensationMax.nanos = 500000000;
		compensationRange.max_compensation = compensationMax;
		compensationMin = @@Jobs::Money.new;
		compensationMin.currency_code = "USD";
		compensationMin.units = 0;
		compensationMin.nanos = 0;
		compensationRange.min_compensation = compensationMin;
		compensationFilter.type = "UNIT_AND_AMOUNT";
		compensationFilter.units = Array["HOURLY"];
		compensationFilter.range = compensationRange;
		jobQuery.compensation_filter = compensationFilter;

		if !companyName.nil?
			jobQuery.company_names = Array[companyName];
		end

		searchJobsRequest = @@Jobs::SearchJobsRequest.new;
		searchJobsRequest.request_metadata = requestMetadata;
		# Set the actual search term as defined in the jobQurey
		searchJobsRequest.job_query = jobQuery;
		# Set the search mode to a regular search
		searchJobsRequest.search_mode = "JOB_SEARCH"
		puts searchJobsRequest.to_json;
		searchJobsResponse = @@talentSolution_client.search_jobs(@@DEFAULT_PROJECT_ID, searchJobsRequest);

		puts searchJobsResponse.to_json;
	end
# [END compensation_search]

end

# Test main. Run only if file is being executed directly or being called by ../spec/samples_spec.rb
if (ARGV.include? File.basename(__FILE__)) || 
	((File.basename(caller[0]).include? "samples_spec.rb") && (File.basename(caller[0]).include? "load"))
	# test
	company = BasicCompanySample.new;
	job = BasicJobSample.new;
	search = FilterSearchSample.new;
	
	company_created_test = company.createCompany(company.generateCompany());
	job_generated_test = job.generateJob(company_created_test.name);
	job_created_test = job.createJob(job_generated_test);

	sleep(10);

	search.basicKeywordSearch(job_created_test.company_name, "Lab Technician");
	search.categoryFilterSearch(job_created_test.company_name, job_created_test.derived_info.job_categories);
	search.employmentTypesFilterSearch(job_created_test.company_name, job_created_test.employment_types);
	search.dateRangeFilterSearch(job_created_test.company_name, 
			"1980-01-15T01:30:15.01Z",
        	"2099-01-15T01:30:15.01Z");
	search.languageCodeFilterSearch(job_created_test.company_name, Array["en-Us"]);
	search.companyDisplayNameFilterSearch(job_created_test.company_name, Array["Google"]);
	search.compensationSearch(job_created_test.company_name);

	job.deleteJob(job_created_test.name);
	company.deleteCompany(company_created_test.name);

end