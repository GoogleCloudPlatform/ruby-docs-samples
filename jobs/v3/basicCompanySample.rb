#!/usr/bin/env ruby
 
# Copyright 2018 Google Inc. All Rights Reserved.
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
 
require 'securerandom'
 
# [START instantiate]
require "google/apis/jobs_v3"
Jobs   = Google::Apis::JobsV3
# [END instantiate]
 
 
# [START basic_company]
def generate_company
  company = Jobs::Company.new
 
  # distributor company id should be a unique Id in your system.
  company.external_id = 'company:' + SecureRandom.hex(16).upcase
 
  company.display_name = 'Google'
  company.headquarters_address = '1600 Amphitheatre Parkway Mountain View, CA 94043'
 
  puts "==========\nCompany generated: %s\n==========" % company.inspect
  return company
end
 
# [END basic_company]
 
 
# [START create_company]
def create_company talent_solution_client:, company_to_be_created:, parent:
  request = Jobs::CreateCompanyRequest.new
  request.company = company_to_be_created
 
  company = talent_solution_client.create_company parent, request
  puts "==========\nCompany created: %s\n==========" % company.inspect
  return company
end
# [END create_company]
 
 
# [START get_company]
def get_company talent_solution_client:, company_name: 
  company = talent_solution_client.get_project_company company_name
  puts "==========\nCompany existed: %s\n==========" % company.inspect
  return company
end
# [END get_company]
 
 
# [START update_company]
def update_company talent_solution_client:, company_name:, company_to_be_updated:
  request = Jobs::UpdateCompanyRequest.new
  request.company = company_to_be_updated

  company = talent_solution_client.patch_project_company company_name, request
  puts "==========\nCompany updated: %s\n==========" % company.inspect
  return company
end
# [END update_company]
 
 
# [START update_company_with_field_mask]
def update_company_with_field_mask talent_solution_client:, company_name:, company_to_be_updated:, field_mask:
  request = Jobs::UpdateCompanyRequest.new
  request.company = company_to_be_updated
  request.update_mask = field_mask

  company = talent_solution_client.patch_project_company company_name, request
  puts "==========\nCompany updated: %s\n==========" % company.inspect
  return company
end
 
# [END update_company_with_field_mask]
 
 
# [START delete_company]
def delete_company talent_solution_client:, company_name:
  talent_solution_client.delete_project_company company_name
  puts "==========\nCompany deleted: %s\n==========" % company_name
end
# [END delete_company]
 
talent_solution_client = Jobs::CloudTalentSolutionService.new
talent_solution_client.authorization = Google::Auth.get_application_default(
  "https://www.googleapis.com/auth/jobs"
)

project_id = "garage-test5"
parent = "projects/#{project_id}"
 
# Construct a company
company_to_be_created = generate_company
 
# Create a company
company_created = create_company talent_solution_client: talent_solution_client, company_to_be_created: company_to_be_created, parent:parent
 
# Get a company
company_name = company_created.name
get_company talent_solution_client: talent_solution_client, company_name: company_name
 
# Update a company
company_to_be_updated = company_created
company_to_be_updated.website_uri = 'https://elgoog.im/'
update_company talent_solution_client: talent_solution_client, company_name: company_name, company_to_be_updated: company_to_be_updated
 
# Update a company with field mask
fields_to_be_patched = Jobs::Company.new
fields_to_be_patched.display_name = 'changedTitle'
fields_to_be_patched.external_id = company_created.external_id
update_company_with_field_mask talent_solution_client: talent_solution_client, company_name: company_name, company_to_be_updated: fields_to_be_patched, field_mask: 'displayName'
 
# Delete a company
delete_company talent_solution_client: talent_solution_client, company_name: company_name