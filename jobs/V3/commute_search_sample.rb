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

def job_discovery_commute_search location:, project_id:
  # [START commute_search]
  # location_str = "Location where the commute search based on"
  # project_id   = "Id of the project"

  require "google/apis/jobs_v3"

  jobs   = Google::Apis::JobsV3
  talent_solution_client = jobs::CloudTalentSolutionService.new
  # @see https://developers.google.com/identity/protocols/application-default-credentials#callingruby
  talent_solution_client.authorization = Google::Auth.get_application_default(
    "https://www.googleapis.com/auth/jobs"
  )

  # Make sure to set the request_metadata the same as the associated search request
  request_metadata = jobs::RequestMetadata.new user_id: "HashedUserId",
						                       session_id: "HashedSessionId",
						                       domain: "www.google.com"
  # Set location filter
  commute_filter = jobs::CommuteFilter.new road_traffic: "TRAFFIC_FREE",
					                       commute_method: "DRIVING",
					                       travel_duration: "1000s",
					                       start_coordinates: location
  # Perform a search for analyst  related jobs
  search_jobs_request =
    jobs::SearchJobsRequest.new request_metadata: request_metadata,
				                job_query: (jobs::JobQuery.new commute_filter: commute_filter),
				                job_view: "JOB_VIEW_FULL",
				                require_precise_result_size: true
  search_jobs_response = talent_solution_client.search_jobs(project_id, search_jobs_request)
  puts search_jobs_response.to_json
  # [END commute_search]
end

def run_commute_search_sample arguments
  require "google/apis/jobs_v3"
  command = arguments.shift
  default_project_id = "projects/#{ENV["GOOGLE_CLOUD_PROJECT"]}"
  case command
  when "commute_search"
    location_arr = arguments.shift.split(',')
    location = Google::Apis::JobsV3::LatLng.new latitude: location_arr[0].to_f,
                          						longitude: location_arr[1].to_f
    job_discovery_commute_search location: location,
                  				 project_id: default_project_id
  else
  puts <<-usage
Usage: bundle exec ruby commute_search_sample.rb [command] [arguments]
Commands:
  commute_search        <location>     Search a job based on commute details from given location. Location format "latitude,longtitude"
Environment variables:
  GOOGLE_CLOUD_PROJECT must be set to your Google Cloud project ID
    usage
  end
end

if __FILE__ == $PROGRAM_NAME
  run_commute_search_sample ARGV
end
