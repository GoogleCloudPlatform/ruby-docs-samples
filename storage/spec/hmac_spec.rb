# Copyright 2019 Google, Inc
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

require_relative "../hmac"
require_relative "spec_helpers.rb"
require "rspec"
require "rspec/retry"
require "google/cloud/storage"

RSpec.configure do |config|
  # show retry status in spec process
  config.verbose_retry = true
  # show exception that triggers a retry if verbose_retry is set to true
  config.display_try_failure_messages = true

  # set retry count and retry sleep interval to 10 seconds
  config.default_retry_count = 5
  config.default_sleep_interval = 10
end

describe "Google Cloud Storage buckets sample" do
  before :all do
    @storage               = Google::Cloud::Storage.new
    @project_id            = @storage.project
    @service_account_email = ENV["STORAGE_HMAC_KEY_SERVICE_ACCOUNT"]
    delete_all_hmac_keys!
    @access_id = create_test_hmac_key
  end

  after :all do
    delete_all_hmac_keys!
  end

  def delete_all_hmac_keys!
    @storage.hmac_keys.all do |hmac_key|
        hmac_key.inactive!
        hmac_key.delete!
    end
  end

  def create_test_hmac_key
    hmac_key = @storage.create_hmac_key @service_account_email, project_id: @project_id
    hmac_key.access_id
  end

  example "list hmac keys" do
    expect {
      list_hmac_keys project_id: @project_id
    }.to output(
      /HMAC Keys:/
    ).to_stdout
  end
  example "create hmac key" do
    expect {
      create_hmac_key project_id: @project_id, service_account_email: @service_account_email
    }.to output(
      /The base64 encoded secret is:/
    ).to_stdout
  end
  example "get hmac key" do
    expect {
      get_hmac_key project_id: @project_id, access_id: @access_id
    }.to output(
      /The HMAC key metadata is:/
    ).to_stdout
  end
  example "deactivate hmac key" do
    unless @storage.hmac_key(@access_id).active?
      @storage.hmac_key(@access_id).active!
    end
    expect {
      deactivate_hmac_key project_id: @project_id, access_id: @access_id
    }.to output(
      /The HMAC key is now inactive./
    ).to_stdout
  end
  example "activate hmac key" do
    if @storage.hmac_key(@access_id).active?
      @storage.hmac_key(@access_id).inactive!
    end
    expect {
      activate_hmac_key project_id: @project_id, access_id: @access_id
    }.to output(
      /The HMAC key is now active./
    ).to_stdout
  end
  example "delete hmac key" do
    delete_test_hmac_key_access_id = create_test_hmac_key
    @storage.hmac_key(delete_test_hmac_key_access_id).inactive!
    expect {
      delete_hmac_key project_id: @project_id, access_id: delete_test_hmac_key_access_id
    }.to output(
      /The key is deleted, though it may still appear in Client#hmac_keys results./
    ).to_stdout
  end
end
