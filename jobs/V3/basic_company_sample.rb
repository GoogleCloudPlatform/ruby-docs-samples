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

def generate_company
	# [START generate_company]
	require "google/apis/jobs_v3"
	require "securerandom"

	jobs = Google::Apis::JobsV3
	company_name = "companyName:"+ SecureRandom.hex;
	company_generated = jobs::Company.new;
	company_generated.display_name = "Google";
	company_generated.headquarters_address= "1600 Amphitheatre Parkway Mountain View, CA 94043";
	company_generated.external_id = company_name;
	puts "Company generated: " + company_generated.to_json;
	return company_generated;
	# [END generate company]
end

def create_company(company_to_be_created)
	# [START create_company]
	require "google/apis/jobs_v3"

	jobs = Google::Apis::JobsV3
	default_project_id = "projects/" + ENV["GOOGLE_CLOUD_PROJECT"];
	talentSolution_client = jobs::CloudTalentSolutionService.new
	# @see https://developers.google.com/identity/protocols/application-default-credentials#callingruby
	talentSolution_client.authorization = Google::Auth.get_application_default(
		"https://www.googleapis.com/auth/jobs"
	)

	begin
		create_company_request = jobs::CreateCompanyRequest.new;
		create_company_request.company = company_to_be_created;
		company_created = talentSolution_client.create_company(default_project_id, create_company_request);
		puts "Company created: " + company_created.to_json;
		return company_created;
	rescue
		puts "Got exception while creating company"
	end
	# [END create_company]
end

def get_company(company_name)
	# [START get_company]
	require "google/apis/jobs_v3"

	jobs = Google::Apis::JobsV3
	talentSolution_client = jobs::CloudTalentSolutionService.new
	# @see https://developers.google.com/identity/protocols/application-default-credentials#callingruby
	talentSolution_client.authorization = Google::Auth.get_application_default(
		"https://www.googleapis.com/auth/jobs"
	)

	begin
		company_got = talentSolution_client.get_project_company(company_name);
		puts "Company got: " + company_got.to_json;
		return company_got;
	rescue
		puts "Got exception while getting company"
		splitted_name = company_name.split('/');
		if splitted_name[0] != "projects" || splitted_name[2] != "companies" || splitted_name[1].empty? || splitted_name[3].empty?
		puts "Invalid companyName format";
		end
	end
	# [END get_company]
end

def update_company(company_name, company_to_be_updated)
	# [START update_company]
	require "google/apis/jobs_v3"

	jobs = Google::Apis::JobsV3
	talentSolution_client = jobs::CloudTalentSolutionService.new
	# @see https://developers.google.com/identity/protocols/application-default-credentials#callingruby
	talentSolution_client.authorization = Google::Auth.get_application_default(
		"https://www.googleapis.com/auth/jobs"
	)

	begin
		update_company_request = jobs::UpdateCompanyRequest.new;
		update_company_request.company = company_to_be_updated;
		company_updated= talentSolution_client.patch_project_company(company_name, update_company_request);
		puts "Company updated: " + company_updated.to_json;
		return company_updated;
	rescue
		puts "Got exception while updating company"
		splitted_name = company_name.split('/');
		if splitted_name[0] != "projects" || splitted_name[2] != "companies" || splitted_name[1].empty? || splitted_name[3].empty?
		puts "Invalid companyName format";
		elsif get_company(company_name).nil?
		puts "company doesn't exist";
		end
	end
	# [END update_company]
end

def update_company_with_field_mask(company_name, field_mask, company_to_be_updated)
	# [START update_company_with_field_mask]
	require "google/apis/jobs_v3"

	jobs = Google::Apis::JobsV3
	talentSolution_client = jobs::CloudTalentSolutionService.new
	# @see https://developers.google.com/identity/protocols/application-default-credentials#callingruby
	talentSolution_client.authorization = Google::Auth.get_application_default(
		"https://www.googleapis.com/auth/jobs"
	)

	begin
		update_company_request = jobs::UpdateCompanyRequest.new;
		update_company_request.company = company_to_be_updated;
		update_company_request.update_mask = field_mask;
		company_updated= talentSolution_client.patch_project_company(company_name, update_company_request);
		puts "Company updated with filedMask " + update_company_request.update_mask + ". Updated company: " + company_updated.to_json;
		return company_updated;
	rescue
		puts "Got exception while updating company with fieldMask"
		splitted_name = company_name.split('/');
		if splitted_name[0] != "projects" || splitted_name[2] != "companies" || splitted_name[1].empty? || splitted_name[3].empty?
		puts "Invalid companyName format";
		elsif get_company(company_name).nil?
		puts "company doesn't exist";
		end
	end
	# [END update_company_with_field_mask]
end

def delete_company(company_name)
	# [START delete_company]
	require "google/apis/jobs_v3"

	jobs = Google::Apis::JobsV3
	talentSolution_client = jobs::CloudTalentSolutionService.new
	# @see https://developers.google.com/identity/protocols/application-default-credentials#callingruby
	talentSolution_client.authorization = Google::Auth.get_application_default(
		"https://www.googleapis.com/auth/jobs"
	)

	begin
		talentSolution_client.delete_project_company(company_name);
		puts "Company deleted. CompanyName: " + company_name;
	rescue
		puts "Got exception while deleting company"
		splitted_name = company_name.split('/');
		if splitted_name[0] != "projects" || splitted_name[2] != "companies" || splitted_name[1].empty? || splitted_name[3].empty?
		puts "Invalid companyName format";
		elsif get_company(company_name).nil?
		puts "company doesn't exist";
		end
	end
	# [END delete_company]
end

def run_basic_company_sample arguments
	command = arguments.shift
	default_project_id = "projects/" + ENV["GOOGLE_CLOUD_PROJECT"];

	case command
	when "create_company", "delete_company"
		company_generated_test = generate_company();
		company_created_test = create_company(company_generated_test)
		delete_company(company_created_test.name);
	when "get_company"
		company_generated_test = generate_company();
		company_created_test = create_company(company_generated_test)
		get_company(company_created_test.name)
		delete_company(company_created_test.name);
	when "update_company"
		company_generated_test = generate_company();
		company_created_test = create_company(company_generated_test)
		company_created_test.display_name = "Updated name Google";
		update_company(company_created_test.name, company_created_test)
		delete_company(company_created_test.name);
	when "update_company_with_field_mask"
		company_generated_test = generate_company();
		company_created_test = create_company(company_generated_test)
		company_created_test.display_name = "Updated name Google";
		update_company_with_field_mask(company_created_test.name, "DisplayName", company_created_test)
		delete_company(company_created_test.name);
	else
	puts <<-usage
Usage: bundle exec ruby basic_company_sample.rb [command] [arguments]
Commands:
  create_company                  Create a company
  get_company                     Get company
  update_company                  Update a company
  update_company_with_field_mask  Update a company with field mask
  delete_company                  Delete a company
Environment variables:
  GOOGLE_CLOUD_PROJECT must be set to your Google Cloud project ID
    usage
	end
end

if __FILE__ == $PROGRAM_NAME
  run_basic_company_sample ARGV
end