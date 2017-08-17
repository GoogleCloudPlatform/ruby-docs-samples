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
require "google/apis/cloudkms_v1"

describe "Key Management Service Quickstart" do
  Cloudkms = Google::Apis::CloudkmsV1

  def create_test_key_ring parent, key_ring_id
    client = Cloudkms::CloudKMSService.new
    client.authorization = Google::Auth.get_application_default(
      %[https://www.googleapis.com/auth/cloud-platform]
    )

    client.create_project_location_key_ring parent, Cloudkms::KeyRing.new,
                                            key_ring_id: key_ring_id
  end

  def list_test_key_rings parent
    client = Cloudkms::CloudKMSService.new
    client.authorization = Google::Auth.get_application_default(
      %[https://www.googleapis.com/auth/cloud-platform]
    )

    client.list_project_location_key_rings parent
  end

  before :all do
    # Note: The quickstart sample defines a `Cloudkms` constant and causes
    #       "already initialized constant" warning because the spec defines the
    #       same constant. $VERBOSE is disabled to silence this warning.
    $VERBOSE = nil
  end

  it "can list global key rings by name" do
    test_project_id  = ENV["GOOGLE_CLOUD_PROJECT"]
    test_key_ring_id = "a-key-ring-list-#{test_project_id}"
    test_parent      = "projects/#{test_project_id}/locations/global"
    test_key_rings   = list_test_key_rings(test_parent).key_rings

    created = test_key_rings.any? do
      |key_ring| key_ring.name.end_with?(test_key_ring_id)
    end
    if !created
      test_key_ring = create_test_key_ring test_parent, test_key_ring_id

      expect(test_key_ring).not_to  eq nil
      expect(test_key_ring.name).to include test_key_ring_id
    end

    test_kms_client = Cloudkms::CloudKMSService.new
    expect(Cloudkms::CloudKMSService).to receive(:new).
                                         and_return(test_kms_client)

    expect(test_kms_client).to receive(:list_project_location_key_rings).
        and_wrap_original do |m, *args|
      m.call test_parent
    end

    expect {
      load File.expand_path("../quickstart.rb", __dir__)
    }.to output(
      /list-#{test_project_id}/
    ).to_stdout
  end
end

