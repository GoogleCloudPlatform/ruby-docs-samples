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

require_relative "../data_model.rb"
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

describe "Google Cloud Firestore API samples - Data Model" do
  before do
    @firestore_project = ENV["FIRESTORE_PROJECT_ID"]
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

  example "document_ref" do
    document_ref project_id: @firestore_project
  end

  example "collection_ref" do
    collection_ref project_id: @firestore_project
  end

  example "document_path_ref" do
    document_path_ref project_id: @firestore_project
  end

  example "subcollection_ref" do
    subcollection_ref project_id: @firestore_project
  end
end
