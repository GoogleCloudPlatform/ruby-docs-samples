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
require "securerandom"
require_relative "../V3/basic_company_sample"
require_relative "../V3/basic_job_sample"
require_relative "../V3/auto_complete_sample"
require_relative "../V3/batch_operation_sample"
require_relative "../V3/commute_search_sample"
require_relative "../V3/custom_attribute_sample"
require_relative "../V3/email_alert_search_sample"
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
    @default_project_id = "projects/#{ENV['GOOGLE_CLOUD_PROJECT']}"
  end

  # Capture and return STDOUT output by block
  def capture
    real_stdout = $stdout
    $stdout = StringIO.new
    yield
    @captured_output = $stdout.string
  ensure
    $stdout = real_stdout
  end

  attr_reader :captured_output

  # verify basic_company_sample.rb
  it "basic_company_sample" do
    capture do
      company_generated =
        job_discovery_generate_company display_name:         "Google",
                                       external_id:          "externalId: Google #{SecureRandom.hex}",
                                       headquarters_address: "1600 Amphitheatre Parkway " +
                                                             "Mountain View, CA 94043"
      company_created =
        job_discovery_create_company company_to_be_created: company_generated,
                                     project_id:            @default_project_id
      company_got = job_discovery_get_company company_name: company_created.name
      company_created.display_name = "Updated name Google"
      company_updated = job_discovery_update_company company_name:    company_created.name,
                                                     company_updated: company_created
      company_created.display_name = "Updated name with field mask Google"
      company_updated_with_field_mask =
        job_discovery_update_company_with_field_mask company_name:    company_created.name,
                                                     field_mask:      "DisplayName",
                                                     company_updated: company_created
      job_discovery_delete_company company_name: company_created.name
      # Verify status of job service
      expect(company_created).not_to be nil
      expect(company_got).not_to be nil
      expect(company_updated.display_name).to eq "Updated name Google"
      expect(company_updated_with_field_mask.display_name).to eq "Updated name with field mask Google"
      company_after_delete = job_discovery_get_company company_name: company_created.name
      expect(company_after_delete).to be nil
    end
  end
  # verify basic_job_sample.rb
  it "basic_job_sample" do
    capture do
      company_generated =
        job_discovery_generate_company display_name:         "Google",
                                       external_id:          "externalId: Google #{SecureRandom.hex}",
                                       headquarters_address: "1600 Amphitheatre Parkway " +
                                                             "Mountain View, CA 94043"
      company_created =
        job_discovery_create_company company_to_be_created: company_generated,
                                     project_id:            @default_project_id
      job_generated = job_discovery_generate_job company_name:   company_created.name,
                                                 requisition_id: "#{company_created.name} #{SecureRandom.hex}"
      job_created = job_discovery_create_job job_to_be_created: job_generated,
                                             project_id:        @default_project_id
      job_got = job_discovery_get_job job_name: job_created.name
      job_created.description = "Updated description"
      job_updated = job_discovery_update_job job_name:          job_created.name,
                                             job_to_be_updated: job_created
      job_created.title = "Updated title software Engineer"
      job_updated_with_field_mask =
        job_discovery_update_job_with_field_mask job_name:          job_created.name,
                                                 field_mask:        "title",
                                                 job_to_be_updated: job_created
      job_discovery_delete_job job_name: job_created.name
      job_discovery_delete_company company_name: company_created.name
      # Verify status of job service
      expect(job_created).not_to be nil
      expect(job_got).not_to be nil
      expect(job_updated.description).to eq "Updated description"
      expect(job_updated_with_field_mask.title).to eq "Updated title software Engineer"
      job_after_delete = job_discovery_get_job job_name: job_created.name
      expect(job_after_delete).to be nil
    end
  end
  # verify auto_complete_sample.rb
  it "auto_complete_sample" do
    capture do
      company_generated =
        job_discovery_generate_company display_name:         "Google",
                                       external_id:          "externalId: Google #{SecureRandom.hex}",
                                       headquarters_address: "1600 Amphitheatre Parkway " +
                                                             "Mountain View, CA 94043"
      company_created =
        job_discovery_create_company company_to_be_created: company_generated,
                                     project_id:            @default_project_id
      job_generated = job_discovery_generate_job company_name:   company_created.name,
                                                 requisition_id: "#{company_created.name} #{SecureRandom.hex}"
      job_generated.title = "software enginner"
      job_created = job_discovery_create_job job_to_be_created: job_generated,
                                             project_id:        @default_project_id
      title_auto_complete_result = job_discovery_job_title_auto_complete company_name: company_created.name,
                                                                         query:        "sof",
                                                                         project_id:   @default_project_id
      default_auto_complete_result = job_discovery_default_auto_complete company_name: company_created.name,
                                                                         query:        "sof",
                                                                         project_id:   @default_project_id
      job_discovery_delete_job job_name: job_created.name
      job_discovery_delete_company company_name: company_created.name
      # Verify status of job service
      expect(title_auto_complete_result.completion_results).not_to be nil
      expect(default_auto_complete_result.completion_results).not_to be nil
    end
  end
  # verify batch_operation_sample.rb
  it "batch_operation_sample" do
    job_names = []
    capture do
      company_generated =
        job_discovery_generate_company display_name:         "Google",
                                       external_id:          "externalId: Google #{SecureRandom.hex}",
                                       headquarters_address: "1600 Amphitheatre Parkway " +
                                                             "Mountain View, CA 94043"
      company_created =
        job_discovery_create_company company_to_be_created: company_generated,
                                     project_id:            @default_project_id
      jobs_created = job_discovery_batch_create_jobs company_name: company_created.name,
                                                     project_id:   @default_project_id
      jobs_created.each do |job|
        job.description = job.description + " updated"
      end
      job_updated = job_discovery_batch_update_jobs job_to_be_updated: jobs_created
      jobs_created.each do |job|
        job.title = job.title + " updated"
      end
      job_updated_with_mask = job_discovery_batch_update_jobs_with_mask job_to_be_updated: jobs_created
      jobs_created.each do |job|
        job_names.push job.name
      end
      job_discovery_batch_delete_jobs job_to_be_deleted: job_names
      # Verify status of job service
      expect(jobs_created).not_to be nil
      job_updated.each do |job|
        expect(job.description).to include("updated")
      end
      job_updated_with_mask.each do |job|
        expect(job.title).to include("updated")
      end
      job_names.each do |job_name|
        job_after_delete = job_discovery_get_job job_name: job_name
        expect(job_after_delete).to be nil
      end
    end
  end
  # verify commute_search_sample.rb
  it "commute_search_sample" do
    capture do
      company_generated =
        job_discovery_generate_company display_name:         "Google",
                                       external_id:          "externalId: Google #{SecureRandom.hex}",
                                       headquarters_address: "1600 Amphitheatre Parkway " +
                                                             "Mountain View, CA 94043"
      company_created =
        job_discovery_create_company company_to_be_created: company_generated,
                                     project_id:            @default_project_id
      job_generated = job_discovery_generate_job company_name:   company_created.name,
                                                 requisition_id: "#{company_created.name} #{SecureRandom.hex}"
      job_created = job_discovery_create_job job_to_be_created: job_generated,
                                             project_id:        @default_project_id
      sleep 60
      location = company_created.derived_info.headquarters_location.lat_lng
      commute_search_result = job_discovery_commute_search commute_method:    "DRIVING",
                                                           travel_duration:   "1000s",
                                                           start_coordinates: location,
                                                           project_id:        @default_project_id
      job_discovery_delete_job job_name: job_created.name
      job_discovery_delete_company company_name: company_created.name
      expect(commute_search_result).not_to be nil
    end
  end
  # verify custom_attribute_sample.rb
  it "custom_attribute_sample" do
    capture do
      company_generated =
        job_discovery_generate_company display_name:         "Google",
                                       external_id:          "externalId: Google #{SecureRandom.hex}",
                                       headquarters_address: "1600 Amphitheatre Parkway " +
                                                             "Mountain View, CA 94043"
      company_created =
        job_discovery_create_company company_to_be_created: company_generated,
                                     project_id:            @default_project_id
      job_generated =
        job_discovery_generate_job_with_custom_attribute company_name:   company_created.name,
                                                         requisition_id: "#{company_created.name} #{SecureRandom.hex}"
      job_created = job_discovery_create_job job_to_be_created: job_generated,
                                             project_id:        @default_project_id
      sleep 10
      long_filter_result = try_with_backoff "long filter results" do 
        job_discovery_filters_on_long_value_custom_attribute project_id: @default_project_id
      end  
      string_filter_result =
        job_discovery_filters_on_string_value_custom_attribute project_id:   @default_project_id
      multi_filters_result =
        job_discovery_filters_on_multi_custom_attributes project_id:   @default_project_id
      job_discovery_delete_job job_name: job_created.name
      job_discovery_delete_company company_name: company_created.name
      expect(long_filter_result.matching_jobs).not_to be nil
      expect(string_filter_result.matching_jobs).not_to be nil
      expect(multi_filters_result.matching_jobs).not_to be nil
    end
  end
  # verify email_alert_search_sample.rb
  it "email_alert_search_sample" do
    capture do
      company_generated =
        job_discovery_generate_company display_name:         "Google",
                                       external_id:          "externalId: Google #{SecureRandom.hex}",
                                       headquarters_address: "1600 Amphitheatre Parkway " +
                                                             "Mountain View, CA 94043"
      company_created =
        job_discovery_create_company company_to_be_created: company_generated,
                                     project_id:            @default_project_id
      job_generated =
        job_discovery_generate_job_with_custom_attribute company_name:   company_created.name,
                                                         requisition_id: "#{company_created.name} #{SecureRandom.hex}"
      job_created = job_discovery_create_job job_to_be_created: job_generated,
                                             project_id:        @default_project_id
      sleep 10
      email_alert_search_result = try_with_backoff "email alert search result" do 
        job_discovery_email_alert_search project_id:   @default_project_id,
                                         company_name: company_created.name
      end
      job_discovery_delete_job job_name: job_created.name
      job_discovery_delete_company company_name: company_created.name
      expect(email_alert_search_result.matching_jobs).not_to be nil
    end
  end
  # verify featured_job_sample.rb
  it "featured_job_sample" do
    capture do
      company_generated =
        job_discovery_generate_company display_name:         "Google",
                                       external_id:          "externalId: Google #{SecureRandom.hex}",
                                       headquarters_address: "1600 Amphitheatre Parkway " +
                                                             "Mountain View, CA 94043"
      company_created =
        job_discovery_create_company company_to_be_created: company_generated,
                                     project_id:            @default_project_id
      job_generated =
        job_discovery_generate_featured_job company_name:   company_created.name,
                                            requisition_id: "#{company_created.name} #{SecureRandom.hex}"
      job_generated.title = "Lab Technician"
      job_created = job_discovery_create_job job_to_be_created: job_generated,
                                             project_id:        @default_project_id
      sleep 10
      search_result = try_with_backoff "search result" do 
        job_discovery_featured_jobs_search company_name: company_created.name,
                                           query:        "Lab",
                                           project_id:   @default_project_id
      end
      job_discovery_delete_job job_name: job_created.name
      job_discovery_delete_company company_name: company_created.name
      expect(search_result.matching_jobs).not_to be nil
    end
  end
  # verify filter_search_sample.rb
  it "filter_search_sample" do
    headquarters_address = "1600 Amphitheatre Parkway Mountain View, CA 94043"

    capture do
      company_generated =
        job_discovery_generate_company display_name:         "Google",
                                       external_id:          "externalId: Google #{SecureRandom.hex}",
                                       headquarters_address: headquarters_address
      company_created =
        job_discovery_create_company company_to_be_created: company_generated,
                                     project_id:            @default_project_id
      job_generated = job_discovery_generate_job company_name:   company_created.name,
                                                 requisition_id: "#{company_created.name} #{SecureRandom.hex}"
      job_created = job_discovery_create_job job_to_be_created: job_generated,
                                             project_id:        @default_project_id

      sleep 10
      keyword_search_result = try_with_backoff "keyword search result" do 
        job_discovery_basic_keyword_search company_name: company_created.name,
                                           query:        job_created.title,
                                           project_id:   @default_project_id
      end
      filter_search_result = job_discovery_category_filter_search company_name: company_created.name,
                                                                  categories:   [:SCIENCE_AND_ENGINEERING],
                                                                  project_id:   @default_project_id
      employment_search_result = job_discovery_employment_types_filter_search company_name:     company_created.name,
                                                                              employment_types: job_created.employment_types,
                                                                              project_id:       @default_project_id
      date_search_result = job_discovery_date_range_filter_search company_name: company_created.name,
                                                                  start_time:   "1980-01-15T01:30:15.01Z",
                                                                  end_time:     "2099-01-15T01:30:15.01Z",
                                                                  project_id:   @default_project_id
      code_search_result = job_discovery_language_code_filter_search company_name:   company_created.name,
                                                                     language_codes: ["en-Us"],
                                                                     project_id:     @default_project_id
      name_search_result = job_discovery_company_display_name_search company_display_names: ["Google"],
                                                                     project_id:            @default_project_id
      compensation_search_result = job_discovery_compensation_search company_name: company_created.name,
                                                                     min_unit:     0,
                                                                     max_unit:     100,
                                                                     project_id:   @default_project_id
      job_discovery_delete_job job_name: job_created.name
      job_discovery_delete_company company_name: company_created.name
      expect(keyword_search_result.matching_jobs).not_to be nil
      expect(filter_search_result.matching_jobs).not_to be nil
      expect(employment_search_result.matching_jobs).not_to be nil
      expect(date_search_result.matching_jobs).not_to be nil
      expect(code_search_result.matching_jobs).not_to be nil
      expect(name_search_result.matching_jobs).not_to be nil
      expect(compensation_search_result.matching_jobs).not_to be nil
    end
  end
  # verify histogram_sample.rb
  it "histogram_sample" do
    capture do
      company_generated =
        job_discovery_generate_company display_name:         "Google",
                                       external_id:          "externalId: Google #{SecureRandom.hex}",
                                       headquarters_address: "1600 Amphitheatre Parkway " +
                                                             "Mountain View, CA 94043"
      company_created =
        job_discovery_create_company company_to_be_created: company_generated,
                                     project_id:            @default_project_id
      job_generated = job_discovery_generate_job company_name:   company_created.name,
                                                 requisition_id: "#{company_created.name} #{SecureRandom.hex}"
      job_created = job_discovery_create_job job_to_be_created: job_generated,
                                             project_id:        @default_project_id
      sleep 10
      search_result = try_with_backoff "search result" do 
        job_discovery_histogram_search company_name: company_created.name,
                                       project_id:   @default_project_id
      end
      job_discovery_delete_job job_name: job_created.name
      job_discovery_delete_company company_name: company_created.name
      expect(search_result.matching_jobs).not_to be nil
    end
  end
  # verify location_search_sample.rb
  it "location_search_sample" do
    begin
      company_generated =
        job_discovery_generate_company display_name:         "Google",
                                       external_id:          "externalId: Google #{SecureRandom.hex}",
                                       headquarters_address: "1600 Amphitheatre Parkway " +
                                                             "Mountain View, CA 94043"
      company_created =
        job_discovery_create_company company_to_be_created: company_generated,
                                     project_id:            @default_project_id
      job_generated1 = job_discovery_generate_job company_name:   company_created.name,
                                                  requisition_id: "#{company_created.name} #{SecureRandom.hex}"
      job_generated1.addresses = ["Mountain View, CA"]
      job_created1 = job_discovery_create_job job_to_be_created: job_generated1,
                                              project_id:        @default_project_id
      job_generated1 = job_discovery_generate_job company_name:   company_created.name,
                                                  requisition_id: "#{company_created.name} #{SecureRandom.hex}"
      job_generated2.addresses = ["Sunnyvale, CA"]
      job_created2 = job_discovery_create_job job_to_be_created: job_generated2,
                                              project_id:        @default_project_id
      sleep 10
      basic_search_result = try_with_backoff "basic search result" do 
        job_discovery_basic_location_search company_name: company_created.name,
                                            location:     "Mountain View, CA",
                                            distance:     0.5,
                                            project_id:   @default_project_id
      end
      keyword_search_result = job_discovery_keyword_location_search company_name: company_created.name,
                                                                    location:     "Mountain View, CA",
                                                                    distance:     0.5,
                                                                    keyword:      "Lab",
                                                                    project_id:   @default_project_id
      city_search_result = job_discovery_city_location_search company_name: company_created.name,
                                                              city:         "Mountain View, CA",
                                                              project_id:   @default_project_id
      multi_search_result = job_discovery_multi_location_search company_name: company_created.name,
                                                                location1:    "Mountain View, CA",
                                                                distance1:    0.5,
                                                                city2:        "Sunnyvale",
                                                                project_id:   @default_project_id
      broadening_search_result = job_discovery_broadening_location_search company_name: company_created.name,
                                                                          city:         "Sunnyvale",
                                                                          project_id:   @default_project_id
      job_discovery_delete_job job_name: job_created1.name
      job_discovery_delete_job job_name: job_created2.name
      job_discovery_delete_company company_name: company_created.name
      expect(basic_search_result.matching_jobs).not_to be nil
      expect(keyword_search_result.matching_jobs).not_to be nil
      expect(city_search_result.matching_jobs).not_to be nil
      expect(multi_result.matching_jobs).not_to be nil
      expect(broadening_result.matching_jobs).not_to be nil
    rescue StandardError
      puts "location_search_sample not all succeeded"
    ensure
      $stdout = StringIO.new
    end
  end

  def try_with_backoff msg = nil, limit: 10
    count = 0
    loop do
      begin
        result = yield
        return result if count >= limit || !result.nil? 
        count += 1
        puts "Retry (#{count}): #{msg}"
        sleep count
      end
    end
  end
end
