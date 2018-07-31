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

require "rspec"
require "rspec/retry"
require "google/apis/jobs_v3"

RSpec.configure do |config|
  # show retry status in spec process
  config.verbose_retry = true
  # show exception that triggers a retry if verbose_retry is set to true
  config.display_try_failure_messages = true

  # set retry count and retry sleep interval to 10 seconds
  config.default_retry_count = 5
  config.default_sleep_interval = 10
end

describe "Cloud Job Discovery Quickstart" do
  Jobs = Google::Apis::JobsV3

  it "can list companies" do
    test_project_id  = ENV["GOOGLE_CLOUD_PROJECT"]
    test_parent      = "projects/#{test_project_id}"
    test_jobs_client = Jobs::CloudTalentSolutionService.new
    expect(Jobs::CloudTalentSolutionService).to receive(:new).
                                         and_return(test_jobs_client)

    expect(test_jobs_client).to receive(:list_project_companies).
        and_wrap_original do |m, *args|
      m.call test_parent
    end

    expect {
      load File.expand_path("../quickstart.rb", __dir__)
    }.to output(
      /Request id.*/
    ).to_stdout
  end
end
