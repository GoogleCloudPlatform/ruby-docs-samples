# Copyright 2017 Google, Inc
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
require "google/cloud/kms/v1"

RSpec.configure do |config|
  # show retry status in spec process
  config.verbose_retry = true
  # show exception that triggers a retry if verbose_retry is set to true
  config.display_try_failure_messages = true

  # set retry count and retry sleep interval to 10 seconds
  config.default_retry_count = 5
  config.default_sleep_interval = 10
end


describe "Key Management Service Quickstart" do
  CloudKMS = Google::Cloud::Kms::V1

  before :all do
    # Note: The quickstart sample defines a `CloudKMS` constant and causes
    #       "already initialized constant" warning because the spec defines the
    #       same constant. $VERBOSE is disabled to silence this warning.
    $VERBOSE = nil
  end

  it "can list global key rings by name" do
    test_project_id  = ENV["GOOGLE_CLOUD_PROJECT"]
    test_key_ring_id = "a-key-ring-list-#{test_project_id}"
    test_parent      = "projects/#{test_project_id}/locations/global"

    client = CloudKMS::KeyManagementServiceClient.new
    test_key_rings = client.list_key_rings test_parent

    created = test_key_rings.any? do |key_ring|
      key_ring.name.end_with? test_key_ring_id
    end

    unless created
      test_key_ring = client.create_key_ring test_parent, test_key_ring_id, nil
      expect(test_key_ring).not_to eq nil
      expect(test_key_ring.name).to include test_key_ring_id
    end

    expect(CloudKMS::KeyManagementServiceClient).to receive(:location_path)
      .and_return(test_parent)

    expect {
      load File.expand_path("../quickstart.rb", __dir__)
    }.to output(
      /list-#{test_project_id}/
    ).to_stdout
  end
end
