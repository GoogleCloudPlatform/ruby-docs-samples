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

def job_discovery_basic_location_search project_id:, company_name:, location:, distance:
  # [START job_discovery_basic_location_search]
  # project_id       = "Id of the project."
  # company_name     = "The resource name of the company listing the job. The format is "projects/{project_id}/companies/{company_id}""
  # location         = "Location of the center where the search is based on."
  # distance         = "The distance from the provided location in miles in which to search."
  require "google/apis/jobs_v3"
  # Instantiate the client
  jobs = Google::Apis::JobsV3
  talent_solution_client = jobs::CloudTalentSolutionService.new
  # @see
  # https://developers.google.com/identity/protocols/application-default-credentials#callingruby
  talent_solution_client.authorization = Google::Auth.get_application_default(
    "https://www.googleapis.com/auth/jobs"
  )
  # Make sure to set the requestMetadata the same as the associated search request
  request_metadata = jobs::RequestMetadata.new user_id:    "HashedUserId",
                                               session_id: "HashedSessionId",
                                               domain:     "www.google.com"
  # Set location filter
  location_filter = jobs::LocationFilter.new address:           location,
                                             distance_in_miles: distance
  # Perform a search for analyst  related jobs
  job_query = jobs::JobQuery.new location_filters: [location_filter],
                                 company_names:    [company_name]

  search_jobs_request = jobs::SearchJobsRequest.new request_metadata: request_metadata,
                                                    job_query:        job_query,
                                                    search_mode:      "JOB_SEARCH"

  search_jobs_response = talent_solution_client.search_jobs project_id, search_jobs_request

  puts search_jobs_response.to_json
  search_jobs_response
  # [END job_discovery_basic_location_search]
end

def job_discovery_keyword_location_search project_id:, company_name:, location:, distance:, keyword:
  # [START job_discovery_keyword_location_search]
  # project_id      = "Id of the project."
  # company_name    = "The resource name of the company listing the job. The format is "projects/{project_id}/companies/{company_id}""
  # location        = "Location of the center where the search is based on."
  # distance        = "The distance from the provided location in miles in which to search."
  # keyword         = "Keyword of the search."
  require "google/apis/jobs_v3"
  # Instantiate the client
  jobs = Google::Apis::JobsV3
  talent_solution_client = jobs::CloudTalentSolutionService.new
  # @see
  # https://developers.google.com/identity/protocols/application-default-credentials#callingruby
  talent_solution_client.authorization = Google::Auth.get_application_default(
    "https://www.googleapis.com/auth/jobs"
  )
  # Make sure to set the requestMetadata the same as the associated search request
  request_metadata = jobs::RequestMetadata.new user_id:    "HashedUserId",
                                               session_id: "HashedSessionId",
                                               domain:     "www.google.com"
  # Set location filter
  location_filter = jobs::LocationFilter.new address:           location,
                                             distance_in_miles: distance
  # Perform a search for analyst  related jobs
  job_query = jobs::JobQuery.new location_filters: [location_filter],
                                 query:            keyword,
                                 company_names:    [company_name]

  search_jobs_request = jobs::SearchJobsRequest.new request_metadata: request_metadata,
                                                    job_query:        job_query,
                                                    search_mode:      "JOB_SEARCH"

  search_jobs_response = talent_solution_client.search_jobs project_id, search_jobs_request

  puts search_jobs_response.to_json
  search_jobs_response
  # [END job_discovery_keyword_location_search]
end

def job_discovery_city_location_search project_id:, company_name:, city:
  # [START job_discovery_city_location_search]
  # project_id       = "Id of the project."
  # company_name     = "The resource name of the company listing the job. The format is "projects/{project_id}/companies/{company_id}""
  # city             = "Name of the city where we want to do the job search."
  require "google/apis/jobs_v3"
  # Instantiate the client
  jobs = Google::Apis::JobsV3
  talent_solution_client = jobs::CloudTalentSolutionService.new
  # @see
  # https://developers.google.com/identity/protocols/application-default-credentials#callingruby
  talent_solution_client.authorization = Google::Auth.get_application_default(
    "https://www.googleapis.com/auth/jobs"
  )
  # Make sure to set the requestMetadata the same as the associated search request
  request_metadata = jobs::RequestMetadata.new user_id:    "HashedUserId",
                                               session_id: "HashedSessionId",
                                               domain:     "www.google.com"
  # Set location filter
  location_filter = jobs::LocationFilter.new address: city
  # Perform a search for analyst  related jobs
  job_query = jobs::JobQuery.new location_filters: [location_filter],
                                 company_names:    [company_name]

  search_jobs_request = jobs::SearchJobsRequest.new request_metadata: request_metadata,
                                                    job_query:        job_query,
                                                    search_mode:      "JOB_SEARCH"

  search_jobs_response = talent_solution_client.search_jobs project_id, search_jobs_request

  puts search_jobs_response.to_json
  search_jobs_response
  # [END job_discovery_city_location_search]
end

def job_discovery_multi_location_search project_id:, company_name:, location1:, distance1:, city2:
  # [START job_discovery_multi_location_search]
  # project_id       = "Id of the project."
  # company_name     = "The resource name of the company listing the job. The format is "projects/{project_id}/companies/{company_id}""
  # location1        = "Location of the center where the first search is based on"
  # distance1        = "The distance from the provided location in miles in which to search."
  # city             = "Name of the city where we want to do the second search."
  require "google/apis/jobs_v3"
  # Instantiate the client
  jobs = Google::Apis::JobsV3
  talent_solution_client = jobs::CloudTalentSolutionService.new
  # @see
  # https://developers.google.com/identity/protocols/application-default-credentials#callingruby
  talent_solution_client.authorization = Google::Auth.get_application_default(
    "https://www.googleapis.com/auth/jobs"
  )
  # Make sure to set the requestMetadata the same as the associated search request
  request_metadata = jobs::RequestMetadata.new user_id:    "HashedUserId",
                                               session_id: "HashedSessionId",
                                               domain:     "www.google.com"

  # Set location filter
  location_filter1 = jobs::LocationFilter.new address:           location1,
                                              distance_in_miles: distance1
  location_filter2 = jobs::LocationFilter.new address: city2
  # Perform a search for analyst  related jobs
  job_query = jobs::JobQuery.new location_filters: [location_filter1, location_filter2],
                                 company_names:    [company_name]

  search_jobs_request = jobs::SearchJobsRequest.new request_metadata: request_metadata,
                                                    job_query:        job_query,
                                                    search_mode:      "JOB_SEARCH"

  search_jobs_response = talent_solution_client.search_jobs project_id, search_jobs_request

  puts search_jobs_response.to_json
  search_jobs_response
  # [END job_discovery_multi_location_search]
end

def job_discovery_broadening_location_search project_id:, company_name:, city:
  # [START job_discovery_broadening_location_search]
  # project_id      = "Id of the project."
  # company_name    = "The resource name of the company listing the job. The format is "projects/{project_id}/companies/{company_id}""
  # city            = "Name of the city where we want to do the job search."
  require "google/apis/jobs_v3"
  # Instantiate the client
  jobs = Google::Apis::JobsV3
  talent_solution_client = jobs::CloudTalentSolutionService.new
  # @see
  # https://developers.google.com/identity/protocols/application-default-credentials#callingruby
  talent_solution_client.authorization = Google::Auth.get_application_default(
    "https://www.googleapis.com/auth/jobs"
  )
  # Make sure to set the requestMetadata the same as the associated search request
  request_metadata = jobs::RequestMetadata.new user_id:    "HashedUserId",
                                               session_id: "HashedSessionId",
                                               domain:     "www.google.com"

  # Set location filter
  location_filter = jobs::LocationFilter.new address: city
  # Perform a search for analyst  related jobs
  job_query = jobs::JobQuery.new location_filters: [location_filter],
                                 company_names:    [company_name]

  search_jobs_request = jobs::SearchJobsRequest.new request_metadata:  request_metadata,
                                                    job_query:         job_query,
                                                    search_mode:       "JOB_SEARCH",
                                                    enable_broadening: true

  search_jobs_response = talent_solution_client.search_jobs project_id, search_jobs_request

  puts search_jobs_response.to_json
  search_jobs_response
  # [END job_discovery_broadening_location_search]
end

def run_location_search_sample arguments
  require_relative "basic_company_sample"
  require_relative "basic_job_sample"

  command = arguments.shift
  default_project_id = "projects/#{ENV['GOOGLE_CLOUD_PROJECT']}"
  company_name = "#{default_project_id}/companies/#{arguments.shift}"

  case command
  when "basic_location_search"
    job_discovery_basic_location_search company_name: company_name,
                                        location:     arguments.shift,
                                        distance:     arguments.shift,
                                        project_id:   default_project_id
  when "keyword_location_search"
    job_discovery_keyword_location_search company_name: company_name,
                                          location:     arguments.shift,
                                          distance:     arguments.shift,
                                          keyword:      arguments.shift,
                                          project_id:   default_project_id
  when "city_location_search"
    job_discovery_city_location_search company_name: company_name,
                                       city:         arguments.shift,
                                       project_id:   default_project_id
  when "multi_location_search"
    job_discovery_multi_location_search company_name: company_name,
                                        location1:    arguments.shift,
                                        distance1:    arguments.shift,
                                        city2:        arguments.shift,
                                        project_id:   default_project_id
  when "broadening_location_search"
    job_discovery_broadening_location_search company_name: company_name,
                                             city:         arguments.shift,
                                             project_id:   default_project_id
  else
    puts <<~USAGE
      Usage: bundle exec ruby filter_search_sample.rb [command] [arguments]
      Commands:
        basic_location_search       <company_id> <location> <distance>                  Search jobs in given searching area under a provided company.
        keyword_location_search     <company_id> <location> <distance> <search_keyword>  Search jobs with keyword in given searching area under a provided company.
        city_location_search        <company_id> <city>                                Search jobs in a city under a provided company.
        multi_location_search       <company_id> <location> <distance> <city>            Search jobs with multi condition under a provided company.
        broadening_location_search  <company_id> <city>                                Broaden search in a city under a provided company.
      Environment variables:
        GOOGLE_CLOUD_PROJECT must be set to your Google Cloud project ID
    USAGE
  end
end

if $PROGRAM_NAME == __FILE__
  run_location_search_sample ARGV
end
