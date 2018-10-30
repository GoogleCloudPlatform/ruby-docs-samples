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
	The samples in this file introduce how to do a search with location filter, including:
	- Basic search with location filter
	- Keyword search with location filter
    - Location filter on city level
    - Broadening search with location filter
	- Location filter of multiple locations
=end

class LocationSearchSample
	# Instantiate the client
	@@Jobs   = Google::Apis::JobsV3
	@@DEFAULT_PROJECT_ID = "projects/" + ENV["GOOGLE_CLOUD_PROJECT"];
		
	@@talentSolution_client = @@Jobs::CloudTalentSolutionService.new
	# @see https://developers.google.com/identity/protocols/application-default-credentials#callingruby
	@@talentSolution_client.authorization = Google::Auth.get_application_default(
		"https://www.googleapis.com/auth/jobs"
	)

# [START basic_location_search]
=begin 
		Basic location search.
=end
	def basicLocationSearch(companyName, location, distance)
		# Make sure to set the requestMetadata the same as the associated search request
		requestMetadata = @@Jobs::RequestMetadata.new;
		# Make sure to hash your userID
		requestMetadata.user_id = "HashedUserId";
		# Make sure to hash the sessionID
		requestMetadata.session_id = "HashedSessionId";
		# Domain of the website where the search is conducted
		requestMetadata.domain = "www.google.com";

		# Set location filter
		locationFilter = @@Jobs::LocationFilter.new;
		locationFilter.address = location;
		locationFilter.distance_in_miles = distance;
		# Perform a search for analyst  related jobs
		jobQuery = @@Jobs::JobQuery.new;
		jobQuery.location_filters = Array[locationFilter];
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
# [END basic_location_search]

# [START keyword_location_search]
=begin 
		Search by keyword and location.
=end
	def keywordLocationSearch(companyName, location, distance, keyword)
		# Make sure to set the requestMetadata the same as the associated search request
		requestMetadata = @@Jobs::RequestMetadata.new;
		# Make sure to hash your userID
		requestMetadata.user_id = "HashedUserId";
		# Make sure to hash the sessionID
		requestMetadata.session_id = "HashedSessionId";
		# Domain of the website where the search is conducted
		requestMetadata.domain = "www.google.com";

		# Set location filter
		locationFilter = @@Jobs::LocationFilter.new;
		locationFilter.address = location;
		locationFilter.distance_in_miles = distance;
		# Perform a search for analyst  related jobs
		jobQuery = @@Jobs::JobQuery.new;
		jobQuery.location_filters = Array[locationFilter];
		jobQuery.query = keyword;
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
# [END keyword_location_search]

# [START city_location_search]
=begin 
		Search by city location.
=end
	def cityLocationSearch(companyName, city)
		# Make sure to set the requestMetadata the same as the associated search request
		requestMetadata = @@Jobs::RequestMetadata.new;
		# Make sure to hash your userID
		requestMetadata.user_id = "HashedUserId";
		# Make sure to hash the sessionID
		requestMetadata.session_id = "HashedSessionId";
		# Domain of the website where the search is conducted
		requestMetadata.domain = "www.google.com";

		# Set location filter
		locationFilter = @@Jobs::LocationFilter.new;
		locationFilter.address = city;
		# Perform a search for analyst  related jobs
		jobQuery = @@Jobs::JobQuery.new;
		jobQuery.location_filters = Array[locationFilter];
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
# [END keyword_location_search]

# [START multi_locations_search]
=begin 
		Multiple locations search.
=end
	def multiLocationSearch(companyNames, location1, distance1, city2)
		# Make sure to set the requestMetadata the same as the associated search request
		requestMetadata = @@Jobs::RequestMetadata.new;
		# Make sure to hash your userID
		requestMetadata.user_id = "HashedUserId";
		# Make sure to hash the sessionID
		requestMetadata.session_id = "HashedSessionId";
		# Domain of the website where the search is conducted
		requestMetadata.domain = "www.google.com";

		# Set location filter
		locationFilter1 = @@Jobs::LocationFilter.new;
		locationFilter1.address = location1;
		locationFilter1.distance_in_miles = distance1;
		locationFilter2 = @@Jobs::LocationFilter.new;
		locationFilter2.address = city2;
		# Perform a search for analyst  related jobs
		jobQuery = @@Jobs::JobQuery.new;
		jobQuery.location_filters = Array[locationFilter1, locationFilter2];
		if companyNames.size!=0
			jobQuery.company_names = Array.new(companyNames);
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
# [END basic_location_search]

# [START broadening_location_search]
=begin 
		Search by broadening location.
=end
	def broadeningLocationSearch(companyName, city)
		# Make sure to set the requestMetadata the same as the associated search request
		requestMetadata = @@Jobs::RequestMetadata.new;
		# Make sure to hash your userID
		requestMetadata.user_id = "HashedUserId";
		# Make sure to hash the sessionID
		requestMetadata.session_id = "HashedSessionId";
		# Domain of the website where the search is conducted
		requestMetadata.domain = "www.google.com";

		# Set location filter
		locationFilter = @@Jobs::LocationFilter.new;
		locationFilter.address = city;
		# Perform a search for analyst  related jobs
		jobQuery = @@Jobs::JobQuery.new;
		jobQuery.location_filters = Array[locationFilter];
		if !companyName.nil?
			jobQuery.company_names = Array[companyName];
		end

		searchJobsRequest = @@Jobs::SearchJobsRequest.new;
		searchJobsRequest.request_metadata = requestMetadata;
		# Set the actual search term as defined in the jobQurey
		searchJobsRequest.job_query = jobQuery;
		# Set the search mode to a regular search
		searchJobsRequest.search_mode = "JOB_SEARCH"
		searchJobsRequest.enable_broadening = true;

		searchJobsResponse = @@talentSolution_client.search_jobs(@@DEFAULT_PROJECT_ID, searchJobsRequest);

		puts searchJobsResponse.to_json;
	end
# [END keyword_location_search]

end

# Test main. Run only if file is being executed directly or being called by ../spec/samples_spec.rb
if (ARGV.include? File.basename(__FILE__)) || 
	((File.basename(caller[0]).include? "samples_spec.rb") && (File.basename(caller[0]).include? "load"))
	# test
	company = BasicCompanySample.new;
	job = BasicJobSample.new;
	search = LocationSearchSample.new;
	
	company_created_test1 = company.createCompany(company.generateCompany());
	job_generated_test1 = job.generateJob(company_created_test1.name);
	job_generated_test1.addresses = Array["Mountain View, CA"];
	job_created_test1 = job.createJob(job_generated_test1);

	company_created_test2 = company.createCompany(company.generateCompany());
	job_generated_test2 = job.generateJob(company_created_test2.name);
	job_generated_test2.addresses = Array["Sunnyvale, CA"];
	job_created_test2 = job.createJob(job_generated_test2);

	sleep(10);

	search.basicLocationSearch(job_created_test1.company_name, "Mountain View, CA", 0.5);
	search.keywordLocationSearch(job_created_test1.company_name, "Mountain View, CA", 0.5, "Lab Technician");
	search.cityLocationSearch(job_created_test1.company_name, "Mountain View");
	search.multiLocationSearch(Array[job_created_test1.company_name, job_created_test2.company_name], 
		"Mountain View, CA", 0.5, "Sunnyvale");
	search.broadeningLocationSearch(job_created_test1.company_name, "Mountain View");

	job.deleteJob(job_created_test1.name);
	company.deleteCompany(company_created_test1.name);
	job.deleteJob(job_created_test2.name);
	company.deleteCompany(company_created_test2.name);
end