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

def job_discovery_basic_keyword_search company_name:, query:, project_id:
	# [START basic_keyword_search]
	# company_name = "The company's name which has the job we want to search"
	# query        = "Content of the job query"
	# project_id   = "Id of the project"

	require "google/apis/jobs_v3"

	# Instantiate the client
	jobs   = Google::Apis::JobsV3
	talent_solution_client = jobs::CloudTalentSolutionService.new
	# @see 
	# https://developers.google.com/identity/protocols/application-default-credentials#callingruby
	talent_solution_client.authorization = Google::Auth.get_application_default(
		"https://www.googleapis.com/auth/jobs"
	)
	# Make sure to set the request_metadata the same as the associated search request
	request_metadata = jobs::RequestMetadata.new user_id: "HashedUserId",
												 session_id: "HashedSessionId",
												 domain: "www.google.com"

	# Perform a search for analyst  related jobs
	job_query = jobs::JobQuery.new query: query
	if !company_name.nil?
		job_query.company_names = [company_name]
	end
	search_jobs_request = jobs::SearchJobsRequest.new request_metadata: request_metadata,
													  job_query: job_query,
													  search_mode: "JOB_SEARCH"
	search_jobs_response = talent_solution_client.search_jobs(project_id, search_jobs_request)
	puts search_jobs_response.to_json
	# [END basic_keyword_search]
end

def job_discovery_category_filter_search company_name:, categories:, project_id:
	# [START category_filter_search]
	# company_name = "The company's name which has the job we want to search"
	# categories   = "Array of categories which we want to search on"
	# project_id   = "Id of the project"

	require "google/apis/jobs_v3"
	# Instantiate the client
	jobs   = Google::Apis::JobsV3
	talent_solution_client = jobs::CloudTalentSolutionService.new
	# @see 
	# https://developers.google.com/identity/protocols/application-default-credentials#callingruby
	talent_solution_client.authorization = Google::Auth.get_application_default(
		"https://www.googleapis.com/auth/jobs"
	)
	# Make sure to set the request_metadata the same as the associated search request
	request_metadata = jobs::RequestMetadata.new user_id: "HashedUserId",
												 session_id: "HashedSessionId",
												 domain: "http://careers.google.com"

	# Perform a search for analyst  related jobs
	job_query = jobs::JobQuery.new job_categories: Array.new(categories)
	if !company_name.nil?
		job_query.company_names = [company_name]
	end
	search_jobs_request = jobs::SearchJobsRequest.new request_metadata: request_metadata,
													  job_query: job_query,
													  search_mode: "JOB_SEARCH"
	search_jobs_response = talent_solution_client.search_jobs(project_id, search_jobs_request)
	puts search_jobs_response.to_json
	# [END category_filter_search]
end

def job_discovery_employment_types_filter_search company_name:, employment_types:, project_id:
	# [START employment_types_filter_search]
	# company_name     = "The company's name which has the job we want to search"
	# employment_types = "Array of employment types which we want to search on"
	# project_id       = "Id of the project"

	require "google/apis/jobs_v3"

	# Instantiate the client
	jobs   = Google::Apis::JobsV3
	talent_solution_client = jobs::CloudTalentSolutionService.new
	# @see 
	# https://developers.google.com/identity/protocols/application-default-credentials#callingruby
	talent_solution_client.authorization = Google::Auth.get_application_default(
		"https://www.googleapis.com/auth/jobs"
	)
	# Make sure to set the request_metadata the same as the associated search request
	request_metadata = jobs::RequestMetadata.new user_id: "HashedUserId",
												 session_id: "HashedSessionId",
												 domain: "http://careers.google.com"

	# Perform a search for analyst  related jobs
	job_query = jobs::JobQuery.new employment_types: employment_types
	if !company_name.nil?
		job_query.company_names = [company_name]
	end
	search_jobs_request = jobs::SearchJobsRequest.new request_metadata: request_metadata,
													  job_query: job_query,
													  search_mode: "JOB_SEARCH"
	search_jobs_response = talent_solution_client.search_jobs(project_id, search_jobs_request)
	puts search_jobs_response.to_json
	# [END employment_types_filter_search]
end

def job_discovery_date_range_filter_search company_name:, start_time:, end_time:, project_id:
	# [START date_range_filter_search]
	# company_name  = "The company's name which has the job we want to search"
	# start_time    = "Start time of the date range we want to search on"
	# end_time      = "End time of the date range we want to search on"
	# project_id    = "Id of the project"

	require "google/apis/jobs_v3"
	# Instantiate the client
	jobs   = Google::Apis::JobsV3
	talent_solution_client = jobs::CloudTalentSolutionService.new
	# @see 
	# https://developers.google.com/identity/protocols/application-default-credentials#callingruby
	talent_solution_client.authorization = Google::Auth.get_application_default(
	"https://www.googleapis.com/auth/jobs"
	)
	# Make sure to set the request_metadata the same as the associated search request
	request_metadata = jobs::RequestMetadata.new user_id: "HashedUserId",
												 session_id: "HashedSessionId",
												 domain: "http://careers.google.com"

	# Perform a search for analyst  related jobs
	timestampRange = jobs::TimestampRange.new start_time: start_time,
											  end_time: end_time
	job_query = jobs::JobQuery.new publish_time_range: timestampRange,
								   company_names: [company_name]
	search_jobs_request = jobs::SearchJobsRequest.new request_metadata: request_metadata,
													  job_query: job_query,
													  search_mode: "JOB_SEARCH"
	search_jobs_response = talent_solution_client.search_jobs(project_id, search_jobs_request)

	puts search_jobs_response.to_json
	# [END date_range_filter_search]
end

def job_discovery_language_code_filter_search company_name:, language_codes:, project_id:
	# [START language_code_filter_search]
	# company_name     = "The company's name which has the job we want to search"
	# language_codes   = "Array of language codes which we want to search on"
	# project_id       = "Id of the project"

	require "google/apis/jobs_v3"

	# Instantiate the client
	jobs   = Google::Apis::JobsV3
	talent_solution_client = jobs::CloudTalentSolutionService.new
	# @see 
	# https://developers.google.com/identity/protocols/application-default-credentials#callingruby
	talent_solution_client.authorization = Google::Auth.get_application_default(
	"https://www.googleapis.com/auth/jobs"
	)
	# Make sure to set the request_metadata the same as the associated search request
	request_metadata = jobs::RequestMetadata.new user_id: "HashedUserId",
												 session_id: "HashedSessionId",
												 domain: "http://careers.google.com"

	# Perform a search for analyst  related jobs
	job_query = jobs::JobQuery.new language_codes: language_codes,
								   company_names: [company_name]
	search_jobs_request = jobs::SearchJobsRequest.new request_metadata: request_metadata,
													  job_query: job_query,
													  search_mode: "JOB_SEARCH"
	search_jobs_response = talent_solution_client.search_jobs(project_id, search_jobs_request)

	puts search_jobs_response.to_json
	# [END language_code_filter_search]
end

def job_discovery_company_display_name_search company_display_names:, project_id:
	# [START company_display_name_search]
	# company_display_names = "Array of company display names which we want to search on"
	# project_id            = "Id of the project"

	require "google/apis/jobs_v3"
	
	# Instantiate the client
	jobs   = Google::Apis::JobsV3
	talent_solution_client = jobs::CloudTalentSolutionService.new
	# @see https://developers.google.com/identity/protocols/application-default-credentials#callingruby
	talent_solution_client.authorization = Google::Auth.get_application_default(
	"https://www.googleapis.com/auth/jobs"
	)
	# Make sure to set the request_metadata the same as the associated search request
	request_metadata = jobs::RequestMetadata.new user_id: "HashedUserId",
												 session_id: "HashedSessionId",
												 domain: "http://careers.google.com"
	# Perform a search for analyst  related jobs
	job_query = jobs::JobQuery.new company_display_names: Array.new(company_display_names)
	search_jobs_request = jobs::SearchJobsRequest.new request_metadata: request_metadata,
													  job_query: job_query,
													  search_mode: "JOB_SEARCH"
	search_jobs_response = talent_solution_client.search_jobs(project_id, search_jobs_request)

	puts search_jobs_response.to_json
	# [END company_display_name_search]
end

def job_discovery_compensation_search company_name:, min_unit:, max_unit:, project_id:
	# [START compensation_search]
	# company_name  = "The company's name which has the job we want to search"
	# min_unit      = "Min value of the compensation range we want to search on"
	# max_unit      = "Max value of the compensation range we want to search on"
	# project_id    = "Id of the project"

	require "google/apis/jobs_v3"
	# Instantiate the client
	jobs   = Google::Apis::JobsV3
	talent_solution_client = jobs::CloudTalentSolutionService.new
	# @see https://developers.google.com/identity/protocols/application-default-credentials#callingruby
	talent_solution_client.authorization = Google::Auth.get_application_default(
	"https://www.googleapis.com/auth/jobs"
	)
	# Make sure to set the request_metadata the same as the associated search request
	request_metadata = jobs::RequestMetadata.new user_id: "HashedUserId",
												 session_id: "HashedSessionId",
												 domain: "http://careers.google.com"
	# Search jobs that pay between min_unit and max_unit (USD/hour)
	compensation_range = jobs::CompensationRange.new max_compensation:(
													  jobs::Money.new currency_code: "USD",
													  units: max_unit,
													  nanos: 500000000
													),
													min_compensation:(
													  jobs::Money.new currency_code: "USD",
													  units: min_unit,
													  nanos: 0
													)
	compensation_filter = jobs::CompensationFilter.new type: "UNIT_AND_AMOUNT",
													  units: ["HOURLY"],
													  range: compensation_range
	# Perform a search for analyst  related jobs
	job_query = jobs::JobQuery.new compensation_filter: compensation_filter,
								   company_names: [company_name]

	search_jobs_request = jobs::SearchJobsRequest.new request_metadata: request_metadata,
													  job_query: job_query,
													  search_mode: "JOB_SEARCH"
	search_jobs_response = talent_solution_client.search_jobs(project_id, search_jobs_request)

	puts search_jobs_response.to_json
	# [END compensation_search]
end

def run_filter_search_sample arguments

	require_relative "basic_company_sample"
	require_relative "basic_job_sample"

	command = arguments.shift
	default_project_id = "projects/#{ENV["GOOGLE_CLOUD_PROJECT"]}"
	if command != "company_display_name_search"
		company_name = "#{default_project_id}/companies/#{arguments.shift}"
	end
	if command == "category_filter_search" || command == "employment_types_filter_search" ||
	   command == "language_code_filter_search" || command == "company_display_name_search"
	   user_input_array = arguments.shift.split(',')
	end

	case command
	when "basic_keyword_search"
		job_discovery_basic_keyword_search company_name: company_name,
										   query: arguments.shift, 
										   project_id: default_project_id
	when "category_filter_search"
		job_discovery_category_filter_search company_name: company_name,
											 categories: user_input_array, 
										   	 project_id: default_project_id
    when "employment_types_filter_search"
		job_discovery_employment_types_filter_search company_name: company_name,
													 employment_types: user_input_array, 
													 project_id: default_project_id
	when "date_range_filter_search"
		job_discovery_date_range_filter_search company_name: company_name, 
											   start_time: arguments.shift, 
											   end_time: arguments.shift, 
											   project_id: default_project_id
	when "language_code_filter_search"
		job_discovery_language_code_filter_search company_name: company_name, 
												  language_codes: user_input_array, 
												  project_id: default_project_id
	when "company_display_name_search"
		job_discovery_company_display_name_search company_display_names: user_input_array, 
												  project_id: default_project_id
	when "compensation_search"
		job_discovery_compensation_search company_name: company_name,
										  min_unit: arguments.shift,
										  max_unit: arguments.shift,
										  project_id: default_project_id
	else
	puts <<-usage
Usage: bundle exec ruby filter_search_sample.rb [command] [arguments]
Commands:
  basic_keyword_search           <company_id><query>                  Search a job via keyword under a provided company.
  category_filter_search         <company_id><categories_array>       Search a job in given categories under a provided company.
  employment_types_filter_search <company_id><employment_types_array> Search a job with given employment types under a provided company.
  date_range_filter_search       <company_id><start_time><end_time>   Search a job in a certain job period under a provided company.
  language_code_filter_search    <company_id><language_codes_array>   Search a job with given language codes under a provided company.
  company_display_name_search    <company_display_names_array> 	      Search a job by company display names.
  compensation_search            <company_id><min_unit><max_unit>     Search a job in a certain compensation range (min_unit to max_unit USD/hour).
Environment variables:
  GOOGLE_CLOUD_PROJECT must be set to your Google Cloud project ID
usage
	end
end

if __FILE__ == $PROGRAM_NAME
  run_filter_search_sample ARGV
end