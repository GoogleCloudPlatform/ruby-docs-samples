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
	The sample in this file introduce how to do a histogram search.
=end

class AutoCompleteSample
	# Instantiate the client
	@@Jobs   = Google::Apis::JobsV3
	@@DEFAULT_PROJECT_ID = "projects/" + ENV["GOOGLE_CLOUD_PROJECT"];
		
	@@talentSolution_client = @@Jobs::CloudTalentSolutionService.new
	# @see https://developers.google.com/identity/protocols/application-default-credentials#callingruby
	@@talentSolution_client.authorization = Google::Auth.get_application_default(
		"https://www.googleapis.com/auth/jobs"
	)

# [START auto_complete_job_title]
=begin 
		Auto completes job titles within given companyName
=end
	def jobTitleAutoComplete(companyName, query)

		callback = lambda { |result, err| 
						if err.nil?
							puts "Job title auto complete result: " + result.to_json;
						else
							puts "Error when auto completing job title. ERror message: " + err.to_json;
						end
					  }
		pageSize = 10;
		type = "JOB_TITLE";
		languageCode = "en-US";
		result = @@talentSolution_client.complete_project(
					@@DEFAULT_PROJECT_ID, company_name: companyName, page_size: pageSize, query: query, 
					language_code: languageCode, type: type, &callback);
	end
# [END auto_complete_job_title]

# [START default_auto_complete]
=begin 
		Default auto completes within given companyName
=end
	def defaultAutoComplete(companyName, query)

		callback = lambda { |result, err| 
						if err.nil?
							puts "Default auto complete result: " + result.to_json;
						else
							puts "Error when auto completing. Error message: " + err.to_json;
						end
					  }
		pageSize = 10;
		languageCode = "en-US";
		result = @@talentSolution_client.complete_project(
					@@DEFAULT_PROJECT_ID, company_name: companyName, page_size: pageSize, query: query, 
					language_code: languageCode, &callback);
	end
# [END default_auto_complete]

end


# Test main. Run only if file is being executed directly or being called by ../spec/samples_spec.rb
if (ARGV.include? File.basename(__FILE__)) || 
	((File.basename(caller[0]).include? "samples_spec.rb") && (File.basename(caller[0]).include? "load"))
	# test
	company = BasicCompanySample.new
	job = BasicJobSample.new
	complete = AutoCompleteSample.new
	# createCompany
	### positive test
	company_created_test = company.createCompany(company.generateCompany());
	job_generated_test = job.generateJob(company_created_test.name);
	job_generated_test.title = "software engineer"
	job_created_test = job.createJob(job_generated_test);

	sleep(10);

	complete.jobTitleAutoComplete(company_created_test.name, "sof");
	complete.defaultAutoComplete(company_created_test.name, "sof");
	complete.defaultAutoComplete(company_created_test.name, "goo");

	job.deleteJob(job_created_test.name);
	company.deleteCompany(company_created_test.name);
end