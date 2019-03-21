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

describe "Storage Quickstart" do
  it "creates a new bucket" do
    storage     = Google::Cloud::Storage.new
    bucket_name = ENV["GOOGLE_CLOUD_STORAGE_BUCKET"]

    if storage.bucket bucket_name
      bucket = storage.bucket bucket_name
      bucket.files.each &:delete until bucket.files.empty?
      bucket.delete
    end

    expect(storage.bucket(bucket_name)).to be nil
    expect(Google::Cloud::Storage).to receive(:new)
      .with(project_id: "YOUR_PROJECT_ID")
      .and_return(storage)

    bucket = storage.create_bucket bucket_name
    expect(storage).to receive(:create_bucket).with("my-new-bucket")
                                              .and_return(bucket)

    expect {
      load File.expand_path("../quickstart.rb", __dir__)
    }.to output(
      "Bucket #{bucket_name} was created.\n"
    ).to_stdout

    expect(storage.bucket(bucket_name)).not_to be nil
  end
end
