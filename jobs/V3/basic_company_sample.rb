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

def job_discovery_generate_company display_name:, headquarters_address:
	# [START generate_company]
	# display_name         = "Your company display name"
	# headquarters_address = "Your company headquarters address"

	require "google/apis/jobs_v3"
	require "securerandom"

	jobs = Google::Apis::JobsV3
	external_id = "externalId: #{display_name} #{SecureRandom.hex}"
	company_generated = jobs::Company.new display_name: display_name,
										  headquarters_address: headquarters_address,
										  external_id: external_id
	puts "Company generated: #{company_generated.to_json}"
	return company_generated
	# [END generate_company]
end

def job_discovery_create_company company_to_be_created:, project_id:
	# [START create_company]
	# company_to_be_created  = "Company to be created"
	# project_id             = "Id of the project"

	require "google/apis/jobs_v3"

	jobs = Google::Apis::JobsV3
	talent_solution_client = jobs::CloudTalentSolutionService.new
	# @see 
	# https://developers.google.com/identity/protocols/application-default-credentials#callingruby
	talent_solution_client.authorization = Google::Auth.get_application_default(
		"https://www.googleapis.com/auth/jobs"
	)

	begin
		create_company_request = jobs::CreateCompanyRequest.new company: company_to_be_created
		company_created = talent_solution_client.create_company(project_id, create_company_request)
		puts "Company created: #{company_created.to_json}"
		return company_created
	rescue => e
	   puts "Exception occurred while creating company: #{e}"
	end
	# [END create_company]
end

def job_discovery_get_company company_name:
	# [START get_company]
	# company_name  = "The name of the company you want to get"

	require "google/apis/jobs_v3"

	jobs = Google::Apis::JobsV3
	talent_solution_client = jobs::CloudTalentSolutionService.new
	# @see 
	# https://developers.google.com/identity/protocols/application-default-credentials#callingruby
	talent_solution_client.authorization = Google::Auth.get_application_default(
		"https://www.googleapis.com/auth/jobs"
	)

	begin
		company_got = talent_solution_client.get_project_company(company_name)
		puts "Company got: #{company_got.to_json}"
		return company_got
	rescue => e
	    puts "Exception occurred while getting company: #{e}"
	end
	# [END get_company]
end

def job_discovery_update_company company_name:, company_updated:
	# [START update_company]
	# company_name     = "The name of the company you want to update"
	# company_updated  = "The new company object to be updated"

	require "google/apis/jobs_v3"

	jobs = Google::Apis::JobsV3
	talent_solution_client = jobs::CloudTalentSolutionService.new
	# @see 
	# https://developers.google.com/identity/protocols/application-default-credentials#callingruby
	talent_solution_client.authorization = Google::Auth.get_application_default(
		"https://www.googleapis.com/auth/jobs"
	)

	begin
		update_company_request = jobs::UpdateCompanyRequest.new company: company_updated
		company_updated = talent_solution_client.
							patch_project_company(company_name, update_company_request)
		puts "Company updated: #{company_updated.to_json}"
		return company_updated
	rescue => e
	    puts "Exception occurred while updating company: #{e}"
	end
	# [END update_company]
end

def job_discovery_update_company_with_field_mask company_name:, field_mask:, company_updated:
	# [START update_company_with_field_mask]
	# company_name     = "The name of the company you want to update"
	# field_mask       = "The field mask you want to update"
	# company_updated  = "The new company object to be updated"

	require "google/apis/jobs_v3"

	jobs = Google::Apis::JobsV3
	talent_solution_client = jobs::CloudTalentSolutionService.new
	# @see 
	# https://developers.google.com/identity/protocols/application-default-credentials#callingruby
	talent_solution_client.authorization = Google::Auth.get_application_default(
		"https://www.googleapis.com/auth/jobs"
	)

	begin
		update_company_request = jobs::UpdateCompanyRequest.new company: company_updated,
																update_mask: field_mask
		company_updated = talent_solution_client.
							patch_project_company(company_name, update_company_request)
		puts "Company updated with filedMask #{update_company_request.update_mask}. "\
			 "Updated company: #{company_updated.to_json}"
		return company_updated
	rescue => e
	    puts "Exception occurred while updating company with fieldMask: #{e}"
	end
	# [END update_company_with_field_mask]
end

def job_discovery_delete_company company_name:
	# [START delete_company]
	# company_name  = "The name of the company you want to delete"

	require "google/apis/jobs_v3"

	jobs = Google::Apis::JobsV3
	talent_solution_client = jobs::CloudTalentSolutionService.new
	# @see 
	# https://developers.google.com/identity/protocols/application-default-credentials#callingruby
	talent_solution_client.authorization = Google::Auth.get_application_default(
		"https://www.googleapis.com/auth/jobs"
	)

	begin
		talent_solution_client.delete_project_company(company_name)
		puts "Company deleted. CompanyName: #{company_name}"
	rescue => e
	    puts "Exception occurred while deleting company: #{e}"
	end
	# [END delete_company]
end

def run_basic_company_sample arguments
	command = arguments.shift
	default_project_id = "projects/#{ENV["GOOGLE_CLOUD_PROJECT"]}"
	user_input = arguments.shift
	if command != "create_company"
		company_name = "#{default_project_id}/companies/#{user_input}"
	end

	case command
	when "create_company"
		company_generated_test = 
			job_discovery_generate_company display_name: user_input, 
										   headquarters_address: arguments.shift
		company_created_test = 
			job_discovery_create_company company_to_be_created: company_generated_test,
										 project_id: default_project_id
	when "get_company"
		job_discovery_get_company company_name: company_name
	when "update_company"
		company_to_be_updated = job_discovery_get_company company_name: company_name
		company_to_be_updated.display_name = "Updated name Google"
		job_discovery_update_company company_name:company_name, 
									 company_updated:company_to_be_updated
	when "update_company_with_field_mask"
		company_to_be_updated = job_discovery_get_company company_name: company_name
		company_to_be_updated.display_name = "Updated name Google"
		job_discovery_update_company_with_field_mask company_name:company_name, 
									 field_mask:"DisplayName", 
									 company_updated:company_to_be_updated
	when "delete_company"
		job_discovery_delete_company company_name:company_name
	else
	puts <<-usage
Usage: bundle exec ruby basic_company_sample.rb [command] [arguments]
Commands:
  create_company                  <display_name> <headquarters_address>      Create a company with display name and headquaters address
  get_company                     <company_id>                               Get company with name.
  update_company                  <company_id>                               Update a company. 
  update_company_with_field_mask  <company_id>                               Update a company with field mask.
  delete_company                  <company_id>                               Delete a company. 
Environment variables:
  GOOGLE_CLOUD_PROJECT must be set to your Google Cloud project ID
    usage
	end
end

if __FILE__ == $PROGRAM_NAME
  run_basic_company_sample ARGV
end