# Copyright 2017 Google, Inc
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in write, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

def create_keyring project_id:, key_ring_id:, location:
  # [START create_keyring]
  require "google/apis/cloudkms_v1beta1"

  # project_id = "Your Google Cloud project ID"
  # key_ring_id = "The id of the new KeyRing"
  # location = "The location of the new KeyRing"

  # Instantiate the client, authenticate with specified scope
  kms_client = Google::Apis::CloudkmsV1beta1::CloudKMSService.new
  kms_client.authorization = Google::Auth.get_application_default(
    "https://www.googleapis.com/auth/cloud-platform"
  )

  # The resource name of the location associated with the KeyRing
  parent = "projects/#{project_id}/locations/#{location}"

  # Create the KeyRing for your project
  key_ring = kms_client.create_project_location_key_ring parent,
      Google::Apis::CloudkmsV1beta1::KeyRing.new, key_ring_id: key_ring_id

  puts "Created KeyRing #{key_ring.name}"
  # [END create_keyring]
end

def run_sample arguments
  command = arguments.shift

  case command
  when "create_keyring"
    create_keyring project_id: ENV["GOOGLE_CLOUD_PROJECT"],
                   ring_name: arguments.shift,
                   location: arguments.shift
  else
    puts <<-usage
Usage: bundle exec ruby kms.rb [command] [arguments]

Commands:
  create_keyring <keyring_name> <location>  Create a new keyring
    usage
  end
end

if __FILE__ == $PROGRAM_NAME
  run_sample ARGV
end
