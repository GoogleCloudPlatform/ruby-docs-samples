# Copyright 2020 Google LLC
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

require_relative "../query_data.rb"
require_relative "../transactions_and_batched_writes.rb"
require_relative "helpers.rb"
require "rspec"
require "rspec/retry"

RSpec.configure do |config|
  # show retry status in spec process
  config.verbose_retry = true
  # show exception that triggers a retry if verbose_retry is set to true
  config.display_try_failure_messages = true

  # set retry count and retry sleep interval to 5 seconds
  config.default_retry_count = 5
  config.default_sleep_interval = 5
end

describe "Google Cloud Firestore API samples - Transactions and Batched Writes" do
  before do
    @firestore_project = ENV["FIRESTORE_TEST_PROJECT"]
    query_create_examples project_id: @firestore_project
  end

  after do
    delete_collection_test collection_name: "cities", project_id: ENV["FIRESTORE_TEST_PROJECT"]
  end

  # Capture and return STDOUT output by block
  def capture
    real_stdout = $stdout
    $stdout = StringIO.new
    yield
    $stdout.string
  ensure
    $stdout = real_stdout
  end

  example "run_simple_transaction" do
    output = capture do
      run_simple_transaction project_id: @firestore_project
    end
    expect(output).to include "New population is 860001."
    expect(output).to include "Ran a simple transaction to update the population field in the SF document in the cities collection."
  end

  example "return_info_transaction" do
    output = capture do
      return_info_transaction project_id: @firestore_project
    end
    expect(output).to include "Population updated!"
  end

  example "batch_write" do
    output = capture do
      batch_write project_id: @firestore_project
    end
    expect(output).to include "Batch write successfully completed."
  end
end
