# Copyright 2018 Google LLC
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
require "securerandom"
require "google/cloud/asset"
require "google/cloud/storage"

require_relative "../quickstart"

RSpec.configure do |config|
  # show retry status in spec process
  config.verbose_retry = true
  # show exception that triggers a retry if verbose_retry is set to true
  config.display_try_failure_messages = true

  # set retry count and retry sleep interval to 10 seconds
  config.default_retry_count = 2
  config.default_sleep_interval = 10
end

describe "Asset Quickstart" do
  before do
    @storage     = Google::Cloud::Storage.new
    @bucket_name = SecureRandom.uuid
    @bucket = @storage.create_bucket @bucket_name
    expect(@bucket).not_to be nil
    @dump_file_name = "assets-by-ruby.txt"
  end

  after do
    return if @bucket.nil?

    file = @bucket.file @dump_file_name
    file&.delete
    @bucket.delete
  end

  it "export assets" do
    dump_file_path = "gs://#{@bucket_name}/#{@dump_file_name}"
    project_id = ENV["GOOGLE_CLOUD_PROJECT"]
    export_assets project_id: project_id, dump_file_path: dump_file_path
    file = @bucket.file @dump_file_name
    expect(file).not_to be nil
  end

  it "batch get assets history" do
    skip "batch_get_history does not work"
    project_id = ENV["GOOGLE_CLOUD_PROJECT"]
    asset_names = ["//storage.googleapis.com/#{@bucket_name}"]
    batch_get_history project_id: project_id, asset_names: asset_names
  end
end
