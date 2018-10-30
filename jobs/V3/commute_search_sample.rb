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
	The samples in this file introduce how to do a commute search.
	Note: Commute Search is different from location search. It only take latitude and longitude as
	the start location.
=end

class CommuteSearchSample
	# Instantiate the client
	@@Jobs   = Google::Apis::JobsV3
	@@DEFAULT_PROJECT_ID = "projects/" + ENV["GOOGLE_CLOUD_PROJECT"];
		
	@@talentSolution_client = @@Jobs::CloudTalentSolutionService.new
	# @see https://developers.google.com/identity/protocols/application-default-credentials#callingruby
	@@talentSolution_client.authorization = Google::Auth.get_application_default(
		"https://www.googleapis.com/auth/jobs"
	)

# [START commute_search]
=begin 
		Search based on commute info.
=end
	def commuteSearch(companyName, location)
		# Make sure to set the requestMetadata the same as the associated search request
		requestMetadata = @@Jobs::RequestMetadata.new;
		# Make sure to hash your userID
		requestMetadata.user_id = "HashedUserId";
		# Make sure to hash the sessionID
		requestMetadata.session_id = "HashedSessionId";
		# Domain of the website where the search is conducted
		requestMetadata.domain = "www.google.com";

		# Set location filter
		commuteFilter = @@Jobs::CommuteFilter.new;
		commuteFilter.road_traffic = "TRAFFIC_FREE";
		commuteFilter.commute_method = "TRANSIT";
		commuteFilter.travel_duration = "1000s";
		commuteFilter.start_coordinates = location;
		# Perform a search for analyst  related jobs
		jobQuery = @@Jobs::JobQuery.new;
		jobQuery.commute_filter = commuteFilter;
		if !companyName.nil?
			jobQuery.company_names = Array[companyName];
		end

		searchJobsRequest = @@Jobs::SearchJobsRequest.new;
		searchJobsRequest.request_metadata = requestMetadata;
		# Set the actual search term as defined in the jobQurey
		searchJobsRequest.job_query = jobQuery;
		# Set the search mode to a regular search
		searchJobsRequest.job_view = "JOB_VIEW_FULL"
		searchJobsRequest.require_precise_result_size = true;

		searchJobsResponse = @@talentSolution_client.search_jobs(@@DEFAULT_PROJECT_ID, searchJobsRequest);

		puts searchJobsResponse.to_json;
	end
# [END basic_location_search]
end

# Test main. Run only if file is being executed directly or being called by ../spec/samples_spec.rb
if (ARGV.include? File.basename(__FILE__)) || 
	((File.basename(caller[0]).include? "samples_spec.rb") && (File.basename(caller[0]).include? "load"))
	# test
	company = BasicCompanySample.new;
	job = BasicJobSample.new;
	search = CommuteSearchSample.new;

	company_created_test = company.createCompany(company.generateCompany());
	job_generated_test = job.generateJob(company_created_test.name);
	job_generated_test.addresses = Array["1600 Amphitheatre Parkway, Mountain View, CA 94043"];
	job_created_test = job.createJob(job_generated_test);

	sleep(10);

	location = Google::Apis::JobsV3::LatLng.new;
	location.latitude = 37.422408;
	location.longitude = -122.085609;
	search.commuteSearch(job_created_test.company_name, location);

	job.deleteJob(job_created_test.name);
	company.deleteCompany(company_created_test.name);
end