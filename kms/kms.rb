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
  # [START kms_create_keyring]
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

  # Create a KeyRing for your project
  key_ring = kms_client.create_project_location_key_ring(parent,
      Google::Apis::CloudkmsV1beta1::KeyRing.new, key_ring_id: key_ring_id)

  puts "Created KeyRing #{key_ring_id}"
  # [END kms_create_keyring]
end

def create_cryptokey project_id:, key_ring_id:, crypto_key:, location:
  # [START kms_create_cryptokey]
  require "google/apis/cloudkms_v1beta1"

  # project_id = "Your Google Cloud project ID"
  # key_ring_id = "The id of the new KeyRing"
  # crypto_key = "Name of cryptoKey"
  # location = "The location of the new KeyRing"

  # Instantiate the client, authenticate with specified scope
  kms_client = Google::Apis::CloudkmsV1beta1::CloudKMSService.new
  kms_client.authorization = Google::Auth.get_application_default(
    "https://www.googleapis.com/auth/cloud-platform"
  )

  # The resource name of the location associated with the KeyRing
  parent = "projects/#{project_id}/locations/#{location}/" +
           "keyRings/#{key_ring_id}"

  # Create a CryptoKey for your project keyring
  crypto_key_skeleton = Google::Apis::CloudkmsV1beta1::CryptoKey.new(
    purpose: "ENCRYPT_DECRYPT")
  new_crypto_key = kms_client.create_project_location_key_ring_crypto_key(parent,
    crypto_key_skeleton, crypto_key_id: crypto_key)

  puts "Create CryptoKey #{crypto_key}"
  # [END kms_create_cryptokey]
end

def encrypt(project_id:, key_ring_id:, crypto_key:, location:, input_file:,
            output_file:)
  # [START kms_encrypt]
  require "google/apis/cloudkms_v1beta1"

  # project_id = "Your Google Cloud project ID"
  # key_ring_id = "The id of the new KeyRing"
  # crypto_key = "Name of the cryptoKey"
  # location = "The location of the new KeyRing"
  # input_file = "File to encrypt"
  # output_file = "File name to use for encrypted input file"

  # Instantiate the client, authenticate with specified scope
  kms_client = Google::Apis::CloudkmsV1beta1::CloudKMSService.new
  kms_client.authorization = Google::Auth.get_application_default(
    "https://www.googleapis.com/auth/cloud-platform"
  )

  # The resource name of the location associated with the KeyRing
  name = "projects/#{project_id}/locations/#{location}/" +
         "keyRings/#{key_ring_id}/cryptoKeys/#{crypto_key}"

  # Use the KMS API to encrypt the text
  encoded_file = Base64.encode64 File.read(input_file)

  request = Google::Apis::CloudkmsV1beta1::EncryptRequest.new(
    plaintext: encoded_file)

  response = kms_client.encrypt_crypto_key name, request

  # Write the encrypted text to a file
  File.open(output_file, "w") do |file|
    file.write(response.ciphertext)
  end

  puts "Saved encrypted #{input_file} as #{output_file}"
  # [END kms_encrypt]
end

def decrypt(project_id:, key_ring_id:, crypto_key:, location:, input_file:,
            output_file:)
  # [START kms_decrypt]
  require "google/apis/cloudkms_v1beta1"

  # project_id = "Your Google Cloud project ID"
  # key_ring_id = "The id of the new KeyRing"
  # crypto_key = "Name of the cryptoKey"
  # location = "The location of the new KeyRing"
  # input_file = "The path to an encrypted file"
  # output_file = "The path to write the decrypted file"


  # Instantiate the client, authenticate with specified scope
  kms_client = Google::Apis::CloudkmsV1beta1::CloudKMSService.new
  kms_client.authorization = Google::Auth.get_application_default(
    "https://www.googleapis.com/auth/cloud-platform"
  )

  # The resource name of the location associated with the KeyRing
  name = "projects/#{project_id}/locations/#{location}/" +
         "keyRings/#{key_ring_id}/cryptoKeys/#{crypto_key}"

  # Use the KMS API to decrypt the text
  encoded_file = File.read(input_file)

  request = Google::Apis::CloudkmsV1beta1::DecryptRequest.new
  request.ciphertext = encoded_file

  response = kms_client.decrypt_crypto_key name, request

  # Write the decrypted text to a file
  File.open(output_file, "w") do |file|
    decoded_file = Base64.decode64 response.plaintext
    file.write decoded_file
  end

  puts "Saved decrypted #{input_file} as #{output_file}"
  # [END kms_decrypt]
end

def create_cryptokey_version project_id:, key_ring_id:, crypto_key:, location:
  # [START kms_create_cryptokey_version]
  require "google/apis/cloudkms_v1beta1"

  # project_id = "Your Google Cloud project ID"
  # key_ring_id = "The id of the new KeyRing"
  # crypto_key = "Name of the cryptoKey"
  # location = "The location of the new KeyRing"

  # Instantiate the client, authenticate with specified scope
  kms_client = Google::Apis::CloudkmsV1beta1::CloudKMSService.new
  kms_client.authorization = Google::Auth.get_application_default(
    "https://www.googleapis.com/auth/cloud-platform"
  )

  # The resource name of the location associated with the KeyRing
  parent = "projects/#{project_id}/locations/#{location}/" +
           "keyRings/#{key_ring_id}/cryptoKeys/#{crypto_key}"

  # Create the CryptoKey version for your project
  crypto_key_version_skeleton = Google::Apis::CloudkmsV1beta1::CryptoKey.new(
    purpose: "ENCRYPT_DECRYPT")
  crypto_key_version = kms_client.create_project_location_key_ring_crypto_key_crypto_key_version(
    parent, crypto_key_version_skeleton)

  puts "Created version #{crypto_key_version.name} for key " +
       "#{crypto_key} in keyring #{key_ring_id}"

  # [END kms_create_cryptokey_version]
end

def disable_cryptokey_version(project_id:, key_ring_id:, crypto_key:, version:,
      location:)
  # [START kms_disable_cryptokey_version]
  require "google/apis/cloudkms_v1beta1"

  # project_id = "Your Google Cloud project ID"
  # key_ring_id = "The id of the new KeyRing"
  # crypto_key = "Name of the cryptoKey"
  # version = "Version of the cryptoKey"
  # location = "The location of the new KeyRing"

  # Instantiate the client, authenticate with specified scope
  kms_client = Google::Apis::CloudkmsV1beta1::CloudKMSService.new
  kms_client.authorization = Google::Auth.get_application_default(
    "https://www.googleapis.com/auth/cloud-platform"
  )

  # The resource name of the location associated with the KeyRing
  parent = "projects/#{project_id}/locations/#{location}/" +
           "keyRings/#{key_ring_id}/cryptoKeys/#{crypto_key}/" +
           "cryptoKeyVersions/#{version}"

  # Get a version of the cryptoKey
  crypto_key_version = kms_client.get_project_location_key_ring_crypto_key_crypto_key_version parent

  # Set the primary version state as disabled for update
  crypto_key_version.state = "DISABLED"

  # Disable the CryptoKey version
  kms_client.patch_project_location_key_ring_crypto_key_crypto_key_version(parent,
      crypto_key_version, update_mask: "state")

  puts "Disabled version #{version} of #{crypto_key}"
  # [END kms_disable_cryptokey_version]
end

def destroy_cryptokey_version(project_id:, key_ring_id:, crypto_key:, version:,
                              location:)
  # [START kms_destroy_cryptokey_version]
  require "google/apis/cloudkms_v1beta1"

  # project_id = "Your Google Cloud project ID"
  # key_ring_id = "The id of the new KeyRing"
  # crypto_key = "Name of the cryptoKey"
  # version = "Version of the cryptoKey"
  # location = "The location of the new KeyRing"

  # Instantiate the client, authenticate with specified scope
  kms_client = Google::Apis::CloudkmsV1beta1::CloudKMSService.new
  kms_client.authorization = Google::Auth.get_application_default(
    "https://www.googleapis.com/auth/cloud-platform"
  )

  # The resource name of the location associated with the KeyRing
  parent = "projects/#{project_id}/locations/#{location}/" +
           "keyRings/#{key_ring_id}/cryptoKeys/#{crypto_key}/" +
           "cryptoKeyVersions/#{version}"

  # Destroy specific version of the crypto key
  kms_client.destroy_crypto_key_version(parent,
    Google::Apis::CloudkmsV1beta1::DestroyCryptoKeyVersionRequest.new)

  puts "Destroyed version #{version} of #{crypto_key}"
  # [END kms_destroy_cryptokey_version]
end

def add_member_to_cryptokey_policy(project_id:, key_ring_id:, crypto_key:,
                                   member:, role:, location:)
  # [START kms_add_member_to_cryptokey_policy]
  require "google/apis/cloudkms_v1beta1"

  # project_id = "Your Google Cloud project ID"
  # key_ring_id = "The id of the new KeyRing"
  # crypto_key = "Name of the cryptoKey"
  # member = "Member to add to cryptoKey policy"
  # role = "Role assignment for new member"
  # location = "The location of the new KeyRing"

  # Instantiate the client, authenticate with specified scope
  kms_client = Google::Apis::CloudkmsV1beta1::CloudKMSService.new
  kms_client.authorization = Google::Auth.get_application_default(
    "https://www.googleapis.com/auth/cloud-platform"
  )

  # The resource name of the location associated with the KeyRing
  parent = "projects/#{project_id}/locations/#{location}/" +
           "keyRings/#{key_ring_id}/cryptoKeys/#{crypto_key}"

  # Get the current IAM policy
  policy = kms_client.get_project_location_key_ring_iam_policy parent

  # Add new member to current bindings
  new_binding = Google::Apis::CloudkmsV1beta1::Binding.new(members: [member],
      role: role)
  policy.bindings ||= []
  policy.bindings << new_binding

  # Update IAM policy
  policy_request = Google::Apis::CloudkmsV1beta1::SetIamPolicyRequest.new(
      policy: policy)
  kms_client.set_key_ring_iam_policy parent, policy_request

  puts "Member #{member} added to policy for " +
       "key #{crypto_key} in keyring #{key_ring_id}"
  # [END kms_add_member_to_cryptokey_policy]
end

def get_keyring_policy project_id:, key_ring_id:, location:
  # [START kms_get_keyring_policy]
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
  parent = "projects/#{project_id}/locations/" +
           "#{location}/keyRings/#{key_ring_id}"

  # Get the current IAM policy
  policy = kms_client.get_project_location_key_ring_iam_policy parent

  # Print role and associated members
  policy.bindings.each do |binding|
    puts "Role: #{binding.role} Members: #{binding.members}"
  end

  # [END kms_get_keyring_policy]
end

def run_sample arguments
  command = arguments.shift

  case command
  when "create_keyring"
    create_keyring(project_id: ENV["GOOGLE_CLOUD_PROJECT"],
                   key_ring_id: arguments.shift,
                   location: arguments.shift)
  when "create_cryptokey"
    create_cryptokey(project_id: ENV["GOOGLE_CLOUD_PROJECT"],
                     key_ring_id: arguments.shift,
                     crypto_key: arguments.shift,
                     location: arguments.shift)
  when "encrypt"
    encrypt(project_id: ENV["GOOGLE_CLOUD_PROJECT"],
            key_ring_id: arguments.shift,
            crypto_key: arguments.shift,
            location: arguments.shift,
            input_file: arguments.shift,
            output_file: arguments.shift)
  when "decrypt"
    decrypt(project_id: ENV["GOOGLE_CLOUD_PROJECT"],
            key_ring_id: arguments.shift,
            crypto_key: arguments.shift,
            location: arguments.shift,
            input_file: arguments.shift,
            output_file: arguments.shift)
  when "create_cryptokey_version"
    create_cryptokey_version(project_id: ENV["GOOGLE_CLOUD_PROJECT"],
                             key_ring_id: arguments.shift,
                             crypto_key: arguments.shift,
                             location: arguments.shift)
  when "disable_cryptokey_version"
    disable_cryptokey_version(project_id: ENV["GOOGLE_CLOUD_PROJECT"],
                              key_ring_id: arguments.shift,
                              crypto_key: arguments.shift,
                              version: arguments.shift,
                              location: arguments.shift)
  when "destroy_cryptokey_version"
    destroy_cryptokey_version(project_id: ENV["GOOGLE_CLOUD_PROJECT"],
                              key_ring_id: arguments.shift,
                              crypto_key: arguments.shift,
                              version: arguments.shift,
                              location: arguments.shift)
  when "add_member"
    add_member_to_cryptokey_policy(project_id: ENV["GOOGLE_CLOUD_PROJECT"],
                                   key_ring_id: arguments.shift,
                                   crypto_key: arguments.shift,
                                   member: arguments.shift,
                                   role: arguments.shift,
                                   location: arguments.shift)
  when "get_keyring_policy"
    get_keyring_policy(project_id: ENV["GOOGLE_CLOUD_PROJECT"],
                       key_ring_id: arguments.shift,
                       location: arguments.shift)
  else
    puts <<-usage
Usage: bundle exec ruby kms.rb [command] [arguments]

Commands:
  create_keyring <key_ring> <location>  Create a new keyring
  create_cryptokey <key_ring> <crypto_key> <location> Create a new cryptokey
  encrypt <key_ring> <crypto_key> <location> <input_file> <output_file> Encrypt a file
  decrypt <key_ring> <crypto_key> <location> <input_file> <output_file Decrypt a file
  create_cryptokey_version <key_ring> <crypto_key> <location> Create a new cryptokey version
  disable_cryptokey_version <key_ring> <crypto_key> <version> <location> Disable a cryptokey version
  destroy_cryptokey_version <key_ring> <crypto_key> <version> <location> Destroy a cryptokey version
  add_member <key_ring> <crypto_key> <member> <role> <location> Add member to cryptokey IAM policy
  get_keyring_policy <key_ring> <location> Get a keyring IAM policy
    usage
  end
end

if __FILE__ == $PROGRAM_NAME
  run_sample ARGV
end
