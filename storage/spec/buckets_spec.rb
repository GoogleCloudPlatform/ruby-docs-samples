# Copyright 2016 Google, Inc
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

require_relative "../buckets"
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
    @bucket_name = ENV["GOOGLE_CLOUD_STORAGE_BUCKET"]
    @storage     = Google::Cloud::Storage.new
    @project_id  = @storage.project
    @kms_key     = create_kms_key project_id: @project_id,
                                  key_ring:   ENV["GOOGLE_CLOUD_KMS_KEY_RING"],
                                  key_name:   ENV["GOOGLE_CLOUD_KMS_KEY_NAME"]
  end

  before do
    delete_bucket!
    @storage.create_bucket @bucket_name
  end

  after :all do
    @storage.bucket(@bucket_name).requester_pays = false if @storage.bucket @bucket_name

    # Other tests assume that this bucket exists,
    # so create it before exiting this spec suite
    @storage.create_bucket @bucket_name unless @storage.bucket @bucket_name
  end

  def delete_bucket!
    bucket = @storage.bucket @bucket_name

    if bucket
      bucket.files.each &:delete until bucket.files.empty?
      bucket.delete
    end
  end

  example "list buckets" do
    expect {
      list_buckets project_id: @project_id
    }.to output(
      /#{@bucket_name}/
    ).to_stdout
  end

  example "disable requester pays" do
    @storage.bucket(@bucket_name).requester_pays = true

    expect(@storage.bucket(@bucket_name).requester_pays).to be true

    expect {
      disable_requester_pays project_id:  @project_id,
                             bucket_name: @bucket_name
    }.to output {
      /Requester pays has been disabled for #{@bucket_name}/
    }.to_stdout

    expect(@storage.bucket(@bucket_name).requester_pays).to be false
  end

  example "enable requester pays" do
    @storage.bucket(@bucket_name).requester_pays = false

    expect(@storage.bucket(@bucket_name).requester_pays).to be false

    expect {
      enable_requester_pays project_id:  @project_id,
                            bucket_name: @bucket_name
    }.to output {
      /Requester pays has been enabled for #{@bucket_name}/
    }.to_stdout

    expect(@storage.bucket(@bucket_name).requester_pays).to be true
  end

  example "check requester pays" do
    @storage.bucket(@bucket_name).requester_pays = true

    expect(@storage.bucket(@bucket_name).requester_pays).to be true

    expect {
      get_requester_pays_status project_id:  @project_id,
                                bucket_name: @bucket_name
    }.to output {
      /Requester Pays is enabled for #{@bucket_name}/
    }.to_stdout
  end

  example "disable bucket policy only" do
    @storage.bucket(@bucket_name).policy_only = true

    expect(@storage.bucket(@bucket_name).policy_only?).to be true

    expect {
      disable_bucket_policy_only project_id:  @project_id,
                                 bucket_name: @bucket_name
    }.to output{
      /Bucket Policy Only was disabled for #{@bucket_name}/
    }.to_stdout

    expect(@storage.bucket(@bucket_name).policy_only?).to be false
  end

  example "enable bucket policy only" do
    @storage.bucket(@bucket_name).policy_only = false

    expect(@storage.bucket(@bucket_name).policy_only?).to be false

    expect {
      enable_bucket_policy_only project_id:  @project_id,
                                bucket_name: @bucket_name
    }.to output{
      /Bucket Policy Only was enabled for #{@bucket_name}/
    }.to_stdout

    expect(@storage.bucket(@bucket_name).policy_only?).to be true
    @storage.bucket(@bucket_name).policy_only = false
  end

  example "get bucket policy only" do
    @storage.bucket(@bucket_name).policy_only = true
    expect(@storage.bucket(@bucket_name).policy_only?).to be true

    expect {
      get_bucket_policy_only project_id:  @project_id,
                             bucket_name: @bucket_name
    }.to output{
      /Bucket Policy Only is enabled for #{@bucket_name}/
    }.to_stdout

    @storage.bucket(@bucket_name).policy_only = false
  end

  example "enable default kms key" do
    @storage.bucket(@bucket_name).default_kms_key = nil

    expect(@storage.bucket(@bucket_name).default_kms_key).to be nil

    expect {
      enable_default_kms_key project_id:      @project_id,
                             bucket_name:     @bucket_name,
                             default_kms_key: @kms_key
    }.to output {
      /Default KMS key for #{@bucket_name} was set to #{@kms_key}/
    }.to_stdout

    expect(@storage.bucket(@bucket_name).default_kms_key).to include @kms_key

    @storage.bucket(@bucket_name).default_kms_key = nil
    expect(@storage.bucket(@bucket_name).default_kms_key).to be nil
  end

  example "set and get a retention policy" do
    skip "retention_period is not working"
    @storage.bucket(@bucket_name).retention_period = nil
    expect(@storage.bucket(@bucket_name).retention_period).to be nil

    retention_period = 5 # seconds.
    expect {
      set_retention_policy project_id:       @project_id,
                           bucket_name:      @bucket_name,
                           retention_period: retention_period
    }.to output {
      /Retention period for #{@bucket_name} is now #{retention_period} seconds/
    }.to_stdout

    expect {
      get_retention_policy project_id:  @project_id,
                           bucket_name: @bucket_name
    }.to output {
      /period: #{retention_period}/
    }.to_stdout

    expect(@storage.bucket(@bucket_name).retention_period).to eq retention_period
    expect(@storage.bucket(@bucket_name).retention_effective_at).not_to be nil
    expect(@storage.bucket(@bucket_name).retention_policy_locked?).to be false

    @storage.bucket(@bucket_name).retention_period = nil
    expect(@storage.bucket(@bucket_name).retention_period).to be nil
  end

  example "remove retention policy" do
    retention_period = 5 # seconds.
    @storage.bucket(@bucket_name).retention_period = retention_period
    expect(@storage.bucket(@bucket_name).retention_period).to be retention_period

    expect {
      remove_retention_policy project_id:  @project_id,
                              bucket_name: @bucket_name
    }.to output(
      /Retention policy for #{@bucket_name} has been removed/
    ).to_stdout

    expect(@storage.bucket(@bucket_name).retention_period).to be nil
    expect(@storage.bucket(@bucket_name).retention_effective_at).to be nil
  end

  example "enable default event-based hold" do
    @storage.bucket(@bucket_name).update do |b|
      b.default_event_based_hold = false
    end
    expect(@storage.bucket(@bucket_name).default_event_based_hold?).to be false

    expect {
      enable_default_event_based_hold project_id:  @project_id,
                                      bucket_name: @bucket_name
    }.to output(
      /Default event-based hold was enabled for #{@bucket_name}/
    ).to_stdout

    expect(@storage.bucket(@bucket_name).default_event_based_hold?).to be true
    @storage.bucket(@bucket_name).update do |b|
      b.default_event_based_hold = false
    end
    expect(@storage.bucket(@bucket_name).default_event_based_hold?).to be false
  end

  example "disable default event-based hold" do
    @storage.bucket(@bucket_name).update do |b|
      b.default_event_based_hold = true
    end
    expect(@storage.bucket(@bucket_name).default_event_based_hold?).to be true

    expect {
      disable_default_event_based_hold project_id:  @project_id,
                                       bucket_name: @bucket_name
    }.to output(
      /Default event-based hold was disabled for #{@bucket_name}/
    ).to_stdout

    expect(@storage.bucket(@bucket_name).default_event_based_hold?).to be false
  end

  example "lock retention policy" do
    expect(@storage.bucket(@bucket_name).retention_policy_locked?).to be false
    @storage.bucket(@bucket_name).retention_period = 1

    expect {
      lock_retention_policy project_id:  @project_id,
                            bucket_name: @bucket_name
    }.to output(
      /Retention policy for #{@bucket_name} is now locked/
    ).to_stdout

    expect(@storage.bucket(@bucket_name).retention_policy_locked?).to be true

    # After locking a bucket retention policy it can't be unlocked.
    delete_bucket!
    @storage.create_bucket @bucket_name
  end

  example "create bucket" do
    delete_bucket!

    expect(@storage.bucket(@bucket_name)).to be nil

    expect {
      create_bucket project_id:  @project_id,
                    bucket_name: @bucket_name
    }.to output(
      "Created bucket: #{@bucket_name}\n"
    ).to_stdout

    expect(@storage.bucket(@bucket_name)).not_to be nil
  end

  example "create bucket with specified class and location" do
    delete_bucket!

    expect(@storage.bucket(@bucket_name)).to be nil

    location      = "US"
    storage_class = "STANDARD"

    expect {
      create_bucket_class_location project_id:    @project_id,
                                   bucket_name:   @bucket_name,
                                   location:      location,
                                   storage_class: storage_class
    }.to output(
      "Created bucket #{@bucket_name} in #{location} with #{storage_class} class\n"
    ).to_stdout

    bucket = @storage.bucket @bucket_name
    expect(bucket).not_to           be nil
    expect(bucket.location).to      eql location
    expect(bucket.storage_class).to eql storage_class
  end

  example "list bucket labels" do
    bucket = @storage.bucket @bucket_name
    expect(bucket).not_to be nil

    label_key   = "get-label-key"
    label_value = "get-label-value"

    bucket.update do |bucket_update|
      bucket_update.labels[label_key] = label_value
    end

    expect {
      list_bucket_labels project_id:  @project_id,
                         bucket_name: @bucket_name
    }.to output(
      /#{label_key} = #{label_value}/
    ).to_stdout
  end

  example "add bucket label" do
    bucket = @storage.bucket @bucket_name
    expect(bucket).not_to be nil

    label_key   = "add-label-key"
    label_value = "add-label-value"

    bucket.update do |bucket_update|
      bucket_update.labels = ({})
    end

    expect(@storage.bucket(@bucket_name).labels.key?(label_key)).to be false

    expect {
      add_bucket_label project_id:  @project_id,
                       bucket_name: @bucket_name,
                       label_key:   label_key,
                       label_value: label_value
    }.to output(
      "Added label #{label_key} with value #{label_value} to #{@bucket_name}\n"
    ).to_stdout

    expect(@storage.bucket(@bucket_name).labels.key?(label_key)).to be true
  end

  example "delete bucket label" do
    bucket = @storage.bucket @bucket_name
    expect(bucket).not_to be nil

    label_key   = "add-label-key"
    label_value = "add-label-value"

    bucket.update do |bucket_update|
      bucket_update.labels[label_key] = label_value
    end

    expect(@storage.bucket(@bucket_name).labels.key?(label_key)).to be true

    expect {
      delete_bucket_label project_id:  @project_id,
                          bucket_name: @bucket_name,
                          label_key:   label_key
    }.to output(
      "Deleted label #{label_key} from #{@bucket_name}\n"
    ).to_stdout

    expect(@storage.bucket(@bucket_name).labels.key?(label_key)).to be false
  end

  example "delete bucket" do
    expect(@storage.bucket(@bucket_name)).not_to be nil

    expect {
      delete_bucket project_id: @project_id, bucket_name: @bucket_name
    }.to output(
      "Deleted bucket: #{@bucket_name}\n"
    ).to_stdout

    expect(@storage.bucket(@bucket_name)).to be nil
  end
end
