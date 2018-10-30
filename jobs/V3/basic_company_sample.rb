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

=begin
	This file contains the basic knowledge about company and job, including:
	- Construct a company with required fields
	- Create a company
	- Get a company
	- Update a company
	- Update a company with field mask
	- Delete a company
=end


class BasicCompanySample
	# Instantiate the client
	@@Jobs   = Google::Apis::JobsV3
	@@DEFAULT_PROJECT_ID = "projects/" + ENV["GOOGLE_CLOUD_PROJECT"];
		
	@@talentSolution_client = @@Jobs::CloudTalentSolutionService.new
	# @see https://developers.google.com/identity/protocols/application-default-credentials#callingruby
	@@talentSolution_client.authorization = Google::Auth.get_application_default(
		"https://www.googleapis.com/auth/jobs"
	)

# [START generate_company]
=begin 
		Generate a company for testing purpose
=end
	def generateCompany()
		companyName = "companyName:"+ SecureRandom.hex;
		companyGenerated = @@Jobs::Company.new;
		companyGenerated.display_name = "Google";
		companyGenerated.headquarters_address= "1600 Amphitheatre Parkway Mountain View, CA 94043";
		companyGenerated.external_id = companyName;
		puts "Company generated: " + companyGenerated.to_json;
		return companyGenerated;
	end
# [END basic company]

# [START create_company]
=begin 
		Create a company
=end
	def createCompany(companyToBeCreated)
		begin
			createCompanyRequest = @@Jobs::CreateCompanyRequest.new;
			createCompanyRequest.company = companyToBeCreated;
			companyCreated = @@talentSolution_client.create_company(@@DEFAULT_PROJECT_ID, createCompanyRequest);
			puts "Company created: " + companyCreated.to_json;
			return companyCreated;
		rescue
			puts "Got exception while creating company"
		end
		
	end
# [END create_company]

# [START get_company]
=begin 
		Get a company
=end
	def getCompany(companyName)
		begin
			companyGot = @@talentSolution_client.get_project_company(companyName);
			puts "Company got: " + companyGot.to_json;
			return companyGot;
		rescue
			puts "Got exception while getting company"
			splitted_name = companyName.split('/');
			if splitted_name[0] != "projects" || splitted_name[2] != "companies" || splitted_name[1].empty? || splitted_name[3].empty?
				puts "Invalid companyName format";
			end
		end
	end
# [END get_company]

# [START update_company]
=begin 
		Update a company
=end
	def updateCompany(companyName, companyToBeUpdated)
		begin
			updateCompanyRequest = @@Jobs::UpdateCompanyRequest.new;
			updateCompanyRequest.company = companyToBeUpdated;
			companyUpdated= @@talentSolution_client.patch_project_company(companyName, updateCompanyRequest);
			puts "Company updated: " + companyUpdated.to_json;
			return companyUpdated;
		rescue
			puts "Got exception while updating company"
			splitted_name = companyName.split('/');
			if splitted_name[0] != "projects" || splitted_name[2] != "companies" || splitted_name[1].empty? || splitted_name[3].empty?
				puts "Invalid companyName format";
			elsif getCompany(companyName).nil?
				puts "company doesn't exist";
			end
		end
	end
# [END update_company]

# [START update_company_with_field_mask]
=begin 
		Update a company with field mask
=end
	def updateCompanyWithFieldMask(companyName, fieldMask, companyToBeUpdated)
		begin
			updateCompanyRequest = @@Jobs::UpdateCompanyRequest.new;
			updateCompanyRequest.company = companyToBeUpdated;
			updateCompanyRequest.update_mask = fieldMask;
			companyUpdated= @@talentSolution_client.patch_project_company(companyName, updateCompanyRequest);
			puts "Company updated with filedMask " + updateCompanyRequest.update_mask + ". Updated company: " + companyUpdated.to_json;
			return companyUpdated;
		rescue
			puts "Got exception while updating company with fieldMask"
			splitted_name = companyName.split('/');
			if splitted_name[0] != "projects" || splitted_name[2] != "companies" || splitted_name[1].empty? || splitted_name[3].empty?
				puts "Invalid companyName format";
			elsif getCompany(companyName).nil?
				puts "company doesn't exist";
			end
		end
	end
# [END update_company_with_field_mask]

# [START delete_company]
=begin 
		Delete a company
=end
	def deleteCompany(companyName)
		begin
			@@talentSolution_client.delete_project_company(companyName);
			puts "Company deleted. CompanyName: " + companyName;
		rescue
			puts "Got exception while deleting company"
			splitted_name = companyName.split('/');
			if splitted_name[0] != "projects" || splitted_name[2] != "companies" || splitted_name[1].empty? || splitted_name[3].empty?
				puts "Invalid companyName format";
			elsif getCompany(companyName).nil?
				puts "company doesn't exist";
			end
		end
	end
# [END delete_company]
end


# Test main. Run only if file is being executed directly or being called by ../spec/samples_spec.rb
if (ARGV.include? File.basename(__FILE__)) || 
	((File.basename(caller[0]).include? "samples_spec.rb") && (File.basename(caller[0]).include? "load"))

	# Test base object
	company_test = BasicCompanySample.new

	# createCompany
	### positive test
	company_generated_test = company_test.generateCompany();
	company_created_test = company_test.createCompany(company_generated_test);
	### negtive test --create duplicated company
	company_test.createCompany(company_generated_test);

	# getCompany 
	### negtive test -- get company with invalid name
	company_test.getCompany("projects\\companies\\"+company_created_test.external_id);
	### positive test
	company_test.getCompany(company_created_test.name);

	# updateCompany
	### positive test
	company_created_test.display_name = "Updated name Google";
	company_test.updateCompany(company_created_test.name, company_created_test);
	### negtive test -- update company with invalid name
	company_test.updateCompany("projects\\companies\\"+company_created_test.external_id, company_created_test);
	### negtive test -- update nonexisted company
	company_test.updateCompany(company_created_test.name+"aa", company_created_test);


	# updateCompanyWithFieldMask
	### positive test
	company_created_test.display_name = "Updated name with fieldMask Google";
	company_test.updateCompanyWithFieldMask(company_created_test.name, "DisplayName", company_created_test);

	#deleteCompany
	### negtive test
	company_test.deleteCompany(company_created_test.name+"aa");
	company_test.deleteCompany("projects\\companies\\"+company_created_test.external_id);
	### positive test
	company_test.deleteCompany(company_created_test.name);
end