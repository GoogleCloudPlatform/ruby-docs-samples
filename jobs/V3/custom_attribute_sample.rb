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

def job_discovery_generate_job_with_custom_attribute company_name:
  # [START generate_job_with_custom_attribute]
  # company_name = "The company's name which has the job we want to create"

  require "google/apis/jobs_v3"

  jobs   = Google::Apis::JobsV3
  talent_solution_client = jobs::CloudTalentSolutionService.new
  # @see
  # https://developers.google.com/identity/protocols/application-default-credentials#callingruby
  talent_solution_client.authorization = Google::Auth.get_application_default(
    "https://www.googleapis.com/auth/jobs"
  )
  # Constructs custom attributes map
  custom_attributes = Hash.new
  # First custom attribute
  custom_attributes["someFieldName1"] = jobs::CustomAttribute.new string_values: ["value1"],
                                    							  filterable: true
  # Second custom attribute
  custom_attributes["someFieldName2"] = jobs::CustomAttribute.new long_values: [256],
                                    							  filterable: true
  # Creates job with custom attributes
  job_generated =
    jobs::Job.new requisition_id: ("jobWithRequiredFields: #{SecureRandom.hex}"),
		          title: " Lab Technician",
		          company_name: company_name,
		          application_info: (jobs::ApplicationInfo.new uris: ["http://careers.google.com"]),
		          description: "Design, develop, test, deploy, maintain and improve software.",
		          custom_attributes: custom_attributes

  puts "Featured Job generated: #{job_generated.to_json}"
  return job_generated
  # [END generate_job_with_custom_attribute]
end

def job_discovery_filters_on_long_value_custom_attribute project_id:
  # [START custom_attribute_filter_long_value]
  # project_id = "Id of the project"

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
  # Perform a search for analyst  related jobs
  job_query = jobs::JobQuery.new custom_attribute_filter: "(255 <= someFieldName2) AND"
                              + " (someFieldName2 <= 257)"
  search_jobs_request = jobs::SearchJobsRequest.new request_metadata: request_metadata,
						                            job_query: job_query,
						                            job_view: "JOB_VIEW_FULL"
  search_jobs_response = talent_solution_client.search_jobs(project_id, search_jobs_request)

  puts search_jobs_response.to_json
  # [END custom_attribute_filter_long_value]
end

def job_discovery_filters_on_string_value_custom_attribute project_id:
  # [START custom_attribute_filter_string_value]
  # project_id = "Id of the project"

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

  # Perform a search for analyst  related jobs
  job_query = jobs::JobQuery.new custom_attribute_filter: "NOT EMPTY(someFieldName1)"
  search_jobs_request = jobs::SearchJobsRequest.new request_metadata: request_metadata,
						                            job_query: job_query,
						                            job_view: "JOB_VIEW_FULL"
  search_jobs_response = talent_solution_client.search_jobs(project_id, search_jobs_request)

  puts search_jobs_response.to_json
  # [END custom_attribute_filter_string_value]
end

def job_discovery_filters_on_multi_custom_attributes project_id:
  # [START custom_attribute_filter_multi_attributes]
  # project_id = "Id of the project"

  require "google/apis/jobs_v3"

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
  custom_attribute_filter = "(someFieldName1 = \"value1\") "
        + "AND ((255 <= someFieldName2) OR (someFieldName2 <= 213))"
  job_query = jobs::JobQuery.new custom_attribute_filter: custom_attribute_filter
  search_jobs_request = jobs::SearchJobsRequest.new request_metadata: request_metadata,
						                            job_query: job_query,
						                            job_view: "JOB_VIEW_FULL"
  search_jobs_response = talent_solution_client.search_jobs(project_id, search_jobs_request)

  puts search_jobs_response.to_json
  # [END custom_attribute_filter_multi_attributes]
end

def run_custom_attribute_sample arguments

  require_relative "basic_company_sample"
  require_relative "basic_job_sample"

  command = arguments.shift
  default_project_id = "projects/#{ENV["GOOGLE_CLOUD_PROJECT"]}"

  company_name = "#{default_project_id}/companies/#{arguments.shift}"
  company_got_test = job_discovery_get_company company_name: company_name

  if !company_got_test.nil?
    job_generated_test =
      job_discovery_generate_job_with_custom_attribute company_name: company_got_test.name
    job_created_test = job_discovery_create_job job_to_be_created: job_generated_test,
                          						project_id: default_project_id
  end

  case command
  when "filters_on_long_value_custom_attribute"
    job_discovery_filters_on_long_value_custom_attribute project_id: default_project_id
  when "filters_on_string_value_custom_attribute"
    job_discovery_filters_on_string_value_custom_attribute project_id: default_project_id
  when "filters_on_multi_custom_attributes"
    job_discovery_filters_on_multi_custom_attributes project_id: default_project_id
  else
  puts <<-usage
Usage: bundle exec ruby custom_attribute_sample.rb [command] [arguments]
Commands:
  filters_on_long_value_custom_attribute           <company_id>        Filter jobs on long value customer attribute under given comany.
  filters_on_string_value_custom_attribute         <company_id>        Filter jobs on string value customer attribute under given comany.
  filters_on_multi_custom_attributes               <company_id>        Filter jobs on multi customer attributes under given comany.
Environment variables:
  GOOGLE_CLOUD_PROJECT must be set to your Google Cloud project ID
    usage
  end

  company_got_test = job_discovery_get_company company_name: company_name
  if !company_got_test.nil?
    job_discovery_delete_job job_name: job_created_test.name
  end
end

if __FILE__ == $PROGRAM_NAME
  run_custom_attribute_sample ARGV
end
