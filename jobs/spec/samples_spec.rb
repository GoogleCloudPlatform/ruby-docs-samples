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

# Global variable to catch the printed outputs
$stdout = StringIO.new

# Start verifying
describe "Cloud Job Discovery Samples" do

# verify basic_company_sample.rb
  it "basic_company_sample" do
    begin
      load File.expand_path("../V3/basic_company_sample.rb", __dir__);
      printed = $stdout.string
      expect(printed).to include("Company created");
      expect(printed).to include("Got exception while creating company");
      expect(printed).to include("Company got");
      expect(printed).to include("Company updated");
      expect(printed).to include("Got exception while updating company");
      expect(printed).to include("Invalid companyName format");
      expect(printed).to include("company doesn't exist");
      expect(printed).to include("Company updated with filedMask DisplayName");
      expect(printed).to include("Got exception while deleting company");
      expect(printed).to include("Company deleted");
    rescue
      puts "basic_company_sample not all succeeded"
    ensure
      $stdout = StringIO.new
    end
  end
# verify basic_job_sample.rb
  it "basic_job_sample" do
    begin
      load File.expand_path("../V3/basic_job_sample.rb", __dir__);
      printed = $stdout.string
      expect(printed).to include("Job created");
      expect(printed).to include("Got exception while getting job");
      expect(printed).to include("Invalid jobName format");
      expect(printed).to include("Job got");
      expect(printed).to include("Job updated");
      expect(printed).to include("Got exception while updating job");
      expect(printed).to include("Invalid jobName format");
      expect(printed).to include("job doesn't exist");
      expect(printed).to include("Job updated with filedMask title");
      expect(printed).to include("Got exception while deleting job");
      expect(printed).to include("Job deleted");
    rescue
      puts "basic_job_sample not all succeeded"
    ensure
      $stdout = StringIO.new
    end
  end
# verify auto_complete_sample.rb
  it "auto_complete_sample" do
    begin
      load File.expand_path("../V3/auto_complete_sample.rb", __dir__);
      printed = $stdout.string
      expect(printed).to include("Job title auto complete result");
      expect(printed).to include("suggestion");
      expect(printed).to include("Default auto complete result");
    rescue
      puts "auto_complete_sample not all succeeded"
    ensure
      $stdout = StringIO.new
    end
  end
# verify batch_operation_sample.rb
  it "batch_operation_sample" do
    begin
      load File.expand_path("../V3/batch_operation_sample.rb", __dir__);
      printed = $stdout.string
      expect(printed).to include("Batch job created");
      expect(printed).to include("Batch job updated with Mask");
      expect(printed).to include("Batch job updated");
      expect(printed).to include("Batch job deleted");
    rescue
      puts "batch_operation_sample not all succeeded"
    ensure
      $stdout = StringIO.new
    end
  end
# verify commute_search_sample.rb
  it "commute_search_sample" do
    begin
      load File.expand_path("../V3/commute_search_sample.rb", __dir__);
      printed = $stdout.string
      expect(printed).to include("matchingJobs");
    rescue
      puts "commute_search_sample not all succeeded"
    ensure
      $stdout = StringIO.new
    end
  end
# verify custom_attribute_sample.rb
  it "custom_attribute_sample" do
    begin
      load File.expand_path("../V3/custom_attribute_sample.rb", __dir__);
      printed = $stdout.string
      expect(printed).to include(/matchingJobs\.matchingJobs\.matchingJobs/);
    rescue
      puts "custom_attribute_sample not all succeeded"
    ensure
      $stdout = StringIO.new
    end
  end
# verify featured_job_sample.rb
  it "featured_job_sample" do
    begin
      load File.expand_path("../V3/featured_job_sample.rb", __dir__);
      printed = $stdout.string
      expect(printed).to include("promotionValue");
      expect(printed).to include("matchingJobs");
    rescue
      puts "featured_job_sample not all succeeded"
    ensure
      $stdout = StringIO.new
    end
  end
# verify filter_search_sample.rb
  it "filter_search_sample" do
    begin
      load File.expand_path("../V3/filter_search_sample.rb", __dir__);
      printed = $stdout.string
      expect(printed).to include(/matchingJobs\.matchingJobs\.matchingJobs\.matchingJobs\.matchingJobs\.matchingJobs\.matchingJobs/);
    rescue
      puts "featured_job_sample not all succeeded"
    ensure
      $stdout = StringIO.new
    end
  end
# verify histogram_sample.rb
  it "histogram_sample" do
    begin
      load File.expand_path("../V3/histogram_sample.rb", __dir__);
      printed = $stdout.string
      expect(printed).to include(/histogramResults\.matchingJobs/);
    rescue
      puts "histogram_sample not all succeeded"
    ensure
      $stdout = StringIO.new
    end
  end
# verify location_search_sample.rb
  it "location_search_sample" do
    begin
      load File.expand_path("../V3/location_search_sample.rb", __dir__);
      printed = $stdout.string
      expect(printed).to include(/locationFilters\.matchingJobs\.locationFilters\.matchingJobs\.locationFilters\.matchingJobs/);
      expect(printed).to include(/"totalSize":2\.locationFilters\.matchingJobs/);
    rescue
      puts "location_search_sample not all succeeded"
    ensure
      $stdout = StringIO.new
    end
  end
end

