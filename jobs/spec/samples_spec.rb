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

require "stringio"
require "rspec"
require "rspec/retry"
require "google/apis/jobs_v3"
require_relative "../V3/basic_company_sample"
require_relative "../V3/basic_job_sample"
require_relative "../V3/auto_complete_sample"
require_relative "../V3/batch_operation_sample"
require_relative "../V3/commute_search_sample"
require_relative "../V3/custom_attribute_sample"
require_relative "../V3/featured_job_sample"
require_relative "../V3/filter_search_sample"
require_relative "../V3/histogram_sample"
require_relative "../V3/location_search_sample"

RSpec.configure do |config|
  # show retry status in spec process
  config.verbose_retry = true
  # show exception that triggers a retry if verbose_retry is set to true
  config.display_try_failure_messages = true

  # set retry count and retry sleep interval to 10 seconds
  config.default_retry_count = 5
  config.default_sleep_interval = 10
end

# Start verifying
describe "Cloud Job Discovery Samples" do

  before do
    $stdout = StringIO.new
    @default_project_id = "projects/#{ENV["GOOGLE_CLOUD_PROJECT"]}"
  end

# verify basic_company_sample.rb
  it "basic_company_sample" do
    begin
      company_generated_test = 
        job_discovery_generate_company display_name: "Google", 
                                       headquarters_address: "1600 Amphitheatre Parkway "\
                                                             "Mountain View, CA 94043"
      company_created_test = 
        job_discovery_create_company company_to_be_created: company_generated_test,
                                     project_id: @default_project_id
      company_got  = job_discovery_get_company company_name: company_created_test.name
      company_created_test.display_name = "Updated name Google"
      company_updated = job_discovery_update_company company_name: company_created_test.name, 
                                                     company_updated: company_created_test
      company_created_test.display_name = "Updated name with field mask Google"
      company_updated_with_field_mask = 
        job_discovery_update_company_with_field_mask company_name: company_created_test.name, 
                                                     field_mask: "DisplayName", 
                                                     company_updated: company_created_test
      job_discovery_delete_company company_name:company_created_test.name
      # Verify status of job service
      expect(company_created_test).not_to be nil
      expect(company_got).not_to be nil
      expect(company_updated.display_name).to eq "Updated name Google"
      expect(company_updated_with_field_mask.display_name).to eq "Updated name with field mask Google"
      company_after_delete  = job_discovery_get_company company_name: company_created_test.name
      expect(company_after_delete).to be nil

      # # Verify output
      # capture = $stdout.string
      # expect(capture).to include("Company created")
      # expect(capture).to include("Company got")
      # expect(capture).to include("Company updated")
      # expect(capture).to include("Updated name Google")
      # expect(capture).to include("Company updated with filedMask DisplayName")
      # expect(capture).to include("Updated name with field mask Google")
      # expect(capture).to include("Company deleted")
    rescue => e
      puts "Exception occurred in basic_company_sample test: #{e}"
    ensure
      $stdout = StringIO.new
    end
  end
# verify basic_job_sample.rb
  it "basic_job_sample" do
    begin
      company_generated_test = 
        job_discovery_generate_company display_name: "Google", 
                                       headquarters_address: "1600 Amphitheatre Parkway "\
                                                             "Mountain View, CA 94043"
      company_created_test = 
        job_discovery_create_company company_to_be_created: company_generated_test,
                                     project_id: @default_project_id
      job_generated_test = job_discovery_generate_job company_name: company_created_test.name
      job_created_test = job_discovery_create_job job_to_be_created: job_generated_test,
                                                  project_id: @default_project_id
      job_got = job_discovery_get_job job_name: job_created_test.name
      job_created_test.description = "Updated description"
      job_updated = job_discovery_update_job job_name: job_created_test.name, 
                                             job_to_be_updated: job_created_test
      job_created_test.title = "Updated title software Engineer"
      job_updated_with_field_mask = 
        job_discovery_update_job_with_field_mask job_name: job_created_test.name,
                                                 field_mask: "title", 
                                                 job_to_be_updated: job_created_test
      job_discovery_delete_job job_name: job_created_test.name
      job_discovery_delete_company company_name: company_created_test.name

      # Verify status of job service
      expect(job_created_test).not_to be nil
      expect(job_got).not_to be nil
      expect(job_updated.description).to eq "Updated description"
      expect(job_updated_with_field_mask.title).to eq "Updated title software Engineer"
      job_after_delete  = job_discovery_get_job job_name: job_created_test.name
      expect(job_after_delete).to be nil

      # capture = $stdout.string
      # expect(capture).to include("Job created")
      # expect(capture).to include("Job got")
      # expect(capture).to include("Job updated")
      # expect(capture).to include("Job updated with filedMask title")
      # expect(capture).to include("Job deleted")
    rescue => e
      puts "Exception occurred in basic_job_sample test: #{e}"
    ensure
      $stdout = StringIO.new
    end
  end
# # verify auto_complete_sample.rb
#   it "auto_complete_sample" do
#     begin
#       company_generated_test = job_discovery_generate_company display_name: "Google", 
#                                                               headquarters_address: "1600 Amphitheatre Parkway Mountain View, CA 94043"
#       company_created_test = job_discovery_create_company company_to_be_created: company_generated_test,
#                                                           project_id: @default_project_id
#       job_generated_test = job_discovery_generate_job company_name: company_created_test.name
#       job_generated_test.title = "software enginner"
#       job_created_test = job_discovery_create_job job_to_be_created: job_generated_test,
#                                                   project_id: @default_project_id
#       job_discovery_job_title_auto_complete company_name: company_created_test.name, 
#                                             query: "sof", 
#                                             project_id: default_project_id
#       job_discovery_default_auto_complete company_name: company_created_test.name, 
#                                           query: "sof", 
#                                           project_id: default_project_id
#       job_discovery_delete_job job_name: job_created_test.name
#       job_discovery_delete_company company_name: company_created_test.name
#       capture = $stdout.string
#       expect(capture).to include("Job title auto complete result")
#       expect(capture).to include("suggestion")
#       expect(capture).to include("Default auto complete result")
#     rescue => e
#       puts "Exception occurred in auto_complete_sample test: #{e}"
#     ensure
#       $stdout = StringIO.new
#     end
#   end
# # verify batch_operation_sample.rb
#   it "batch_operation_sample" do
#     begin
#       company_generated_test = job_discovery_generate_company display_name: "Google", 
#                                                               headquarters_address: "1600 Amphitheatre Parkway Mountain View, CA 94043"
#       company_created_test = job_discovery_create_company company_to_be_created: company_generated_test,
#                                                           project_id: @default_project_id
#       jobs_created = job_discovery_batch_create_jobs company_name: company_created_test.name,
#                                                      project_id: @default_project_id
#       jobs_created.each{ |job|
#         job.title = job.title + " updated"
#         job.description = job.description + " updated"
#       }
#       job_discovery_batch_update_jobs job_to_be_updated: jobs_created
#       jobs_created.each{ |job|
#         job_names.push job.name
#       }
#       job_discovery_batch_delete_jobs job_to_be_deleted: job_names
#       capture = $stdout.string
#       expect(capture).to include("Batch job created")
#       expect(capture).to include("Batch job updated with Mask")
#       expect(capture).to include("Batch job updated")
#       expect(capture).to include("Batch job deleted")
#     rescue => e
#       puts "Exception occurred in batch_operation_sample test: #{e}"
#     ensure
#       $stdout = StringIO.new
#     end
#   end
# # verify commute_search_sample.rb
#   it "commute_search_sample" do
#     begin
#       company_generated_test = job_discovery_generate_company display_name: "Google", 
#                                                               headquarters_address: "1600 Amphitheatre Parkway Mountain View, CA 94043"
#       company_created_test = job_discovery_create_company company_to_be_created: company_generated_test,
#                                                           project_id: @default_project_id
#       job_generated_test = job_discovery_generate_job company_name: company_created_test.name
#       job_created_test = job_discovery_create_job job_to_be_created: job_generated_test,
#                                                   project_id: @default_project_id
#       sleep 20
#       job_discovery_commute_search location: company_created_test.derived_info.headquarters_location, 
#                                    project_id: @default_project_id
#       job_discovery_delete_job job_name: job_created_test.name
#       job_discovery_delete_company company_name: company_created_test.name
#       capture = $stdout.string
#       expect(capture).to include("matchingJobs")
#     rescue => e
#       puts "Exception occurred in commute_search_sample test: #{e}"
#     ensure
#       $stdout = StringIO.new
#     end
#   end
# # verify custom_attribute_sample.rb
#   it "custom_attribute_sample" do
#     begin
#       company_generated_test = 
#         job_discovery_generate_company display_name: "Google", 
#                                        headquarters_address: "1600 Amphitheatre Parkway "\
#                                                              "Mountain View, CA 94043"
#       company_created_test = 
#         job_discovery_create_company company_to_be_created: company_generated_test,
#                                      project_id: @default_project_id
#       job_generated_test = 
#         job_discovery_generate_job_with_custom_attribute company_name: company_created_test.name
#       job_created_test = job_discovery_create_job job_to_be_created: job_generated_test,
#                                                   project_id: @default_project_id
#       job_discovery_filters_on_long_value_custom_attribute project_id: @default_project_id
#       job_discovery_filters_on_string_value_custom_attribute project_id: @default_project_id
#       job_discovery_filters_on_multi_custom_attributes project_id: @default_project_id
#       job_discovery_delete_job job_name: job_created_test.name
#       job_discovery_delete_company company_name: company_created_test.name
#       capture = $stdout.string
#       expect(capture).to include(/matchingJobs\.matchingJobs\.matchingJobs/)
#     rescue => e
#       puts "Exception occurred in custom_attribute_sample test: #{e}"
#     ensure
#       $stdout = StringIO.new
#     end
#   end
# # verify featured_job_sample.rb
#   it "featured_job_sample" do
#     begin
#       company_generated_test = 
#         job_discovery_generate_company display_name: "Google", 
#                                        headquarters_address: "1600 Amphitheatre Parkway "\
#                                                              "Mountain View, CA 94043"
#       company_created_test = 
#         job_discovery_create_company company_to_be_created: company_generated_test,
#                                      project_id: @default_project_id
#       job_generated_test = job_discovery_generate_featured_job company_name: company_created_test.name
#       job_generated_test.title = "Lab Technician"
#       job_created_test = job_discovery_create_job job_to_be_created: job_generated_test,
#                                                   project_id: @default_project_id
#       sleep 10
#       job_discovery_featured_jobs_search company_name: company_created_test.name,
#                                          query: "Lab", 
#                                          project_id: @default_project_id
#       job_discovery_delete_job job_name: job_created_test.name
#       job_discovery_delete_company company_name: company_created_test.name
#       capture = $stdout.string
#       expect(capture).to include("promotionValue")
#       expect(capture).to include("matchingJobs")
#     rescue
#       puts "featured_job_sample not all succeeded"
#     ensure
#       $stdout = StringIO.new
#     end
#   end
# # verify filter_search_sample.rb
#   it "filter_search_sample" do
#     begin
#       company_generated_test = 
#         job_discovery_generate_company display_name: "Google", 
#                                        headquarters_address: "1600 Amphitheatre Parkway "\
#                                                              "Mountain View, CA 94043"
#       company_created_test = 
#         job_discovery_create_company company_to_be_created: company_generated_test,
#                                      project_id: @default_project_id
#       job_generated_test = job_discovery_generate_featured_job company_name: company_created_test.name
#       job_created_test = job_discovery_create_job job_to_be_created: job_generated_test,
#                                                   project_id: @default_project_id

#       sleep 10
#       job_discovery_basic_keyword_search company_name: company_created_test.name,
#                                          query: job_created_test.title, 
#                                          project_id: @default_project_id
#       job_discovery_category_filter_search company_name: company_created_test.name,
#                                            categories: job_created_test.derived_info.job_categories, 
#                                            project_id: @default_project_id
#       job_discovery_employment_types_filter_search company_name: company_created_test.name,
#                                                    employment_types: job_created_test.employment_types, 
#                                                    project_id: @default_project_id
#       job_discovery_date_range_filter_search company_name: company_created_test.name, 
#                                              start_time: "1980-01-15T01:30:15.01Z", 
#                                              end_time: "2099-01-15T01:30:15.01Z", 
#                                              project_id: @default_project_id
#       job_discovery_language_code_filter_search company_name: company_created_test.name, 
#                                                 language_codes: ["en-Us"],
#                                                 project_id: @default_project_id
#       job_discovery_company_display_name_search company_display_names: ["Google"], 
#                                                 project_id: @default_project_id
#       job_discovery_compensation_search company_name: company_created_test.name,
#                                         min_unit: 0,
#                                         max_unit: 100,
#                                         project_id: @default_project_id
#       job_discovery_delete_job job_name: job_created_test.name
#       job_discovery_delete_company company_name: company_created_test.name
#       capture = $stdout.string
#       expect(capture).to include(/matchingJobs\.matchingJobs\.matchingJobs\.matchingJobs\.matchingJobs\.matchingJobs\.matchingJobs/)
#     rescue
#       puts "featured_job_sample not all succeeded"
#     ensure
#       $stdout = StringIO.new
#     end
#   end
# # verify histogram_sample.rb
#   it "histogram_sample" do
#     begin
#       company_generated_test = 
#         job_discovery_generate_company display_name: "Google", 
#                                        headquarters_address: "1600 Amphitheatre Parkway "\
#                                                              "Mountain View, CA 94043"
#       company_created_test = 
#         job_discovery_create_company company_to_be_created: company_generated_test,
#                                      project_id: @default_project_id
#       job_generated_test = job_discovery_generate_featured_job company_name: company_created_test.name
#       job_created_test = job_discovery_create_job job_to_be_created: job_generated_test,
#                                                   project_id: @default_project_id
#       sleep 10
#       job_discovery_histogram_search company_name: company_created_test.name,
#                                      project_id: @default_project_id
#       job_discovery_delete_job job_name: job_created_test.name
#       job_discovery_delete_company company_name: company_created_test.name
#       capture = $stdout.string
#       expect(capture).to include(/histogramResults\.matchingJobs/)
#     rescue
#       puts "histogram_sample not all succeeded"
#     ensure
#       $stdout = StringIO.new
#     end
#   end
# # verify location_search_sample.rb
#   it "location_search_sample" do
#     begin
#       company_generated_test = 
#         job_discovery_generate_company display_name: "Google", 
#                                        headquarters_address: "1600 Amphitheatre Parkway "\
#                                                              "Mountain View, CA 94043"
#       company_created_test = 
#         job_discovery_create_company company_to_be_created: company_generated_test,
#                                      project_id: @default_project_id
#       job_generated_test1 = job_discovery_generate_featured_job company_name: company_created_test.name
#       job_generated_test1.addresses =["Mountain View, CA"]
#       job_created_test1 = job_discovery_create_job job_to_be_created: job_generated_test,
#                                                    project_id: @default_project_id
#       job_generated_test2 = job_discovery_generate_featured_job company_name: company_created_test.name
#       job_generated_test2.addresses = ["Sunnyvale, CA"]
#       job_created_test2 = job_discovery_create_job job_to_be_created: job_generated_test,
#                                                    project_id: @default_project_id
#       sleep 10
#       job_discovery_basic_location_search company_name: company_created_test.name,
#                                           location: "Mountain View, CA",
#                                           distance: 0.5,
#                                           project_id: @default_project_id
#       job_discovery_keyword_location_search company_name: company_created_test.name,
#                                             location: "Mountain View, CA", 
#                                             distance: 0.5,
#                                             keyword: "Lab", 
#                                             project_id: @default_project_id
#       job_discovery_city_location_search company_name: company_created_test.name,
#                                          city: "Mountain View, CA", 
#                                          project_id: @default_project_id
#       job_discovery_multi_location_search company_name: company_created_test.name,
#                                           location1: "Mountain View, CA", 
#                                           distance1: 0.5, 
#                                           city2: "Sunnyvale", 
#                                           project_id: @default_project_id
#       job_discovery_broadening_location_search company_name: company_created_test.name, 
#                                                city: "Sunnyvale", 
#                                                project_id: @default_project_id
#       job_discovery_delete_job job_name: job_created_test1.name
#       job_discovery_delete_job job_name: job_created_test2.name
#       job_discovery_delete_company company_name: company_created_test.name
#       capture = $stdout.string
#       expect(capture).to include(/locationFilters\.matchingJobs\.locationFilters\.matchingJobs\.locationFilters\.matchingJobs/)
#       expect(capture).to include(/"totalSize":2\.locationFilters\.matchingJobs/)
#     rescue
#       puts "location_search_sample not all succeeded"
#     ensure
#       $stdout = StringIO.new
#     end
#   end
end

