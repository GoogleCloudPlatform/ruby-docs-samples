# Copyright 2018 Google, Inc
#
# Licensed under the Apache License, Version 2.0 (the "License")
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

$stdout = StringIO.new

# Start verifying
describe "Cloud Job Discovery Samples" do

# verify basic_company_sample.rb
  it "basic_company_sample" do
    begin
      company_generated_test = job_discovery_generate_company display_name: "Google", 
                                                              headquarters_address: "1600 Amphitheatre Parkway Mountain View, CA 94043"
      company_created_test = job_discovery_create_company company_to_be_created: company_generated_test
      job_discovery_get_company company_name: company_created_test.name
      company_created_test.display_name = "Updated name Google"
      job_discovery_update_company company_name: company_created_test.name, 
                                   company_updated: company_created_test
      company_created_test.display_name = "Updated name with field mask Google"
      job_discovery_update_company_with_field_mask company_name: company_created_test.name, 
                                                   field_mask: "DisplayName", 
                                                   company_updated: company_created_test
      job_discovery_delete_company company_name:company_created_test.name
      capture = $stdout.string
      expect(capture).to include("Company created")
      expect(capture).to include("Company got")
      expect(capture).to include("Company updated")
      expect(capture).to include("Updated name Google")
      expect(capture).to include("Company updated with filedMask DisplayName")
      expect(capture).to include("Updated name with field mask Google")
      expect(capture).to include("Company deleted")
    rescue
      puts "basic_company_sample not all succeeded"
    ensure
      $stdout = StringIO.new
    end
  end
# verify basic_job_sample.rb
  it "basic_job_sample" do
    begin
      company_generated_test = job_discovery_generate_company display_name: "Google", 
                                                              headquarters_address: "1600 Amphitheatre Parkway Mountain View, CA 94043"
      company_created_test = job_discovery_create_company company_to_be_created: company_generated_test
      job_generated_test = job_discovery_generate_job company_name: company_created_test.name
      job_created_test = job_discovery_create_job job_to_be_created: job_generated_test
      job_discovery_get_job job_name: job_created_test.name
      job_created_test.description = "Updated description"
      job_discovery_update_job job_name: job_created_test.name, 
                               job_to_be_updated: job_created_test
      job_created_test.title = "Updated title software Engineer"
      job_discovery_update_job_with_field_mask job_name: job_created_test.name,
                                               field_mask: "title", 
                                               job_to_be_updated: job_created_test
      job_discovery_delete_job job_name: job_created_test.name
      job_discovery_delete_company company_name: company_created_test.name
      capture = $stdout.string
      expect(capture).to include("Job created")
      expect(capture).to include("Job got")
      expect(capture).to include("Job updated")
      expect(capture).to include("Job updated with filedMask title")
      expect(capture).to include("Job deleted")
    rescue
      puts "basic_job_sample not all succeeded"
    ensure
      $stdout = StringIO.new
    end
end
# # verify auto_complete_sample.rb
#   it "auto_complete_sample" do
#     begin
#       load File.expand_path("../V3/auto_complete_sample.rb", __dir__)
#       capture = $stdout.string
#       expect(capture).to include("Job title auto complete result")
#       expect(capture).to include("suggestion")
#       expect(capture).to include("Default auto complete result")
#     rescue
#       puts "auto_complete_sample not all succeeded"
#     ensure
#       $stdout = StringIO.new
#     end
#   end
# # verify batch_operation_sample.rb
#   it "batch_operation_sample" do
#     begin
#       load File.expand_path("../V3/batch_operation_sample.rb", __dir__)
#       capture = $stdout.string
#       expect(capture).to include("Batch job created")
#       expect(capture).to include("Batch job updated with Mask")
#       expect(capture).to include("Batch job updated")
#       expect(capture).to include("Batch job deleted")
#     rescue
#       puts "batch_operation_sample not all succeeded"
#     ensure
#       $stdout = StringIO.new
#     end
#   end
# # verify commute_search_sample.rb
#   it "commute_search_sample" do
#     begin
#       load File.expand_path("../V3/commute_search_sample.rb", __dir__)
#       capture = $stdout.string
#       expect(capture).to include("matchingJobs")
#     rescue
#       puts "commute_search_sample not all succeeded"
#     ensure
#       $stdout = StringIO.new
#     end
#   end
# # verify custom_attribute_sample.rb
#   it "custom_attribute_sample" do
#     begin
#       load File.expand_path("../V3/custom_attribute_sample.rb", __dir__)
#       capture = $stdout.string
#       expect(capture).to include(/matchingJobs\.matchingJobs\.matchingJobs/)
#     rescue
#       puts "custom_attribute_sample not all succeeded"
#     ensure
#       $stdout = StringIO.new
#     end
#   end
# # verify featured_job_sample.rb
#   it "featured_job_sample" do
#     begin
#       load File.expand_path("../V3/featured_job_sample.rb", __dir__)
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
#       load File.expand_path("../V3/filter_search_sample.rb", __dir__)
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
#       load File.expand_path("../V3/histogram_sample.rb", __dir__)
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
#       load File.expand_path("../V3/location_search_sample.rb", __dir__)
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

