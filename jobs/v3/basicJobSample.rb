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
 
def generate_company
  company = Jobs::Company.new
 
  # distributor company id should be a unique Id in your system.
  company.external_id = 'company:' + SecureRandom.hex(16).upcase
 
  company.display_name = 'Google'
  company.headquarters_address = '1600 Amphitheatre Parkway Mountain View, CA 94043'
 
  puts "==========\nCompany generated: %s\n==========" % company.inspect
  return company
end
 
def create_company talent_solution_client:, company_to_be_created:, parent:
  request = Jobs::CreateCompanyRequest.new
  request.company = company_to_be_created
 
  company = talent_solution_client.create_company parent, request
  puts "==========\nCompany created: %s\n==========" % company.inspect
  return company
end
 
def delete_company talent_solution_client:, company_name:
  talent_solution_client.delete_project_company company_name
  puts "==========\nCompany deleted: %s\n==========" % company_name
end

# [START basic_job]
def generate_job_with_required_fields company_name:
  job = Jobs::Job.new
 
  # distributor company id should be a unique Id in your system.
  job.requisition_id = 'job_with_required_fields:' + SecureRandom.hex(16).upcase
 
  job.title = 'Software Engineer'

  application_info = Jobs::ApplicationInfo.new
  application_info.uris = ['http://careers.google.com']
  job.application_info = application_info
  job.description = 'Design, develop, test, deploy, maintain and improve software.'
  job.company_name = company_name
   
  puts "==========\nJob generated: %s\n==========" % job.inspect
  return job
end
# [END basic_job]


# [START create_job]
def create_job talent_solution_client:, job_to_be_created:, parent:
  request = Jobs::CreateJobRequest.new
  request.job = job_to_be_created
  
  job = talent_solution_client.create_job parent, request
  puts "==========\nJob created: %s\n==========" % job.inspect
  return job
end
# [END create_job]


# [START get_job]
def get_job talent_solution_client:, job_name:
  job = talent_solution_client.get_project_job job_name
  puts "==========\nJob existed: %s\n==========" % job.inspect
  return job
end
# [END get_job]


# [START delete_job]
def delete_job talent_solution_client:, job_name:
  talent_solution_client.delete_project_job job_name
  puts "==========\nJob deleted: %s\n==========" % job_name
end
# [END delete_job]
 

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
company_name = company_created.name

# Construct a job
job_to_be_created = generate_job_with_required_fields company_name:company_name
 
# Create a job
job_created = create_job talent_solution_client: talent_solution_client, job_to_be_created: job_to_be_created, parent:parent
job_name = job_created.name

# Get a job
get_job talent_solution_client: talent_solution_client, job_name: job_name

# Delete a job
delete_job talent_solution_client: talent_solution_client, job_name: job_name

sleep(5)

# Delete a company
delete_company talent_solution_client: talent_solution_client, company_name: company_name