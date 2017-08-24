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

# Note: Code samples in this file set constants which cannot be set inside
#       method definitions in Ruby. To allow for this, code snippets in this
#       sample are wrapped in global lambdas.

$create_key_ring = -> (project_id:, location_id:, key_ring_id:) do
  # [START kms_create_keyring]
  # project_id  = "Your Google Cloud project ID"
  # key_ring_id = "The ID of the new key ring"
  # location_id = "The location of the new key ring"

  require "google/apis/cloudkms_v1"

  # Initialize the client and authenticate with the specified scope
  Cloudkms = Google::Apis::CloudkmsV1
  kms_client = Cloudkms::CloudKMSService.new
  kms_client.authorization = Google::Auth.get_application_default(
    "https://www.googleapis.com/auth/cloud-platform"
  )

  # The resource name of the location associated with the key ring
  resource = "projects/#{project_id}/locations/#{location_id}"

  # Create a key ring for your project
  key_ring = kms_client.create_project_location_key_ring(
    resource,
    Cloudkms::KeyRing.new,
    key_ring_id: key_ring_id
  )

  puts "Created key ring #{key_ring_id}"
  # [END kms_create_keyring]
end

$create_crypto_key = -> (project_id:, location_id:, key_ring_id:, crypto_key_id:) do
  # [START kms_create_cryptokey]
  # project_id    = "Your Google Cloud project ID"
  # location_id   = "The location of the key ring"
  # key_ring_id   = "The ID of the key ring"
  # crypto_key_id = "The ID of the new crypto key"

  require "google/apis/cloudkms_v1"

  # Initialize the client and authenticate with the specified scope
  Cloudkms = Google::Apis::CloudkmsV1
  kms_client = Cloudkms::CloudKMSService.new
  kms_client.authorization = Google::Auth.get_application_default(
    "https://www.googleapis.com/auth/cloud-platform"
  )

  # The resource name of the key ring
  resource = "projects/#{project_id}/locations/#{location_id}/" +
             "keyRings/#{key_ring_id}"

  # Create a crypto key in the key ring
  new_crypto_key = kms_client.create_project_location_key_ring_crypto_key(
    resource,
    Cloudkms::CryptoKey.new(purpose: "ENCRYPT_DECRYPT"),
    crypto_key_id: crypto_key_id
  )

  puts "Created crypto key #{crypto_key_id}"
  # [END kms_create_cryptokey]
end

$encrypt = -> (project_id:, location_id:, key_ring_id:, crypto_key_id:, plaintext_file:, ciphertext_file:) do
  # [START kms_encrypt]
  # project_id      = "Your Google Cloud project ID"
  # location_id     = "The location of the key ring"
  # key_ring_id     = "The ID of the key ring"
  # crypto_key_id   = "The ID of the crypto key"
  # plaintext_file  = "File to encrypt"
  # ciphertext_file = "File to store encrypted input data"

  require "google/apis/cloudkms_v1"

  # Initialize the client and authenticate with the specified scope
  Cloudkms = Google::Apis::CloudkmsV1
  kms_client = Cloudkms::CloudKMSService.new
  kms_client.authorization = Google::Auth.get_application_default(
    "https://www.googleapis.com/auth/cloud-platform"
  )

  # The resource name of the crypto key
  resource = "projects/#{project_id}/locations/#{location_id}/" +
             "keyRings/#{key_ring_id}/cryptoKeys/#{crypto_key_id}"

  # Read the secret data from the file
  plaintext = File.read plaintext_file

  request = Cloudkms::EncryptRequest.new plaintext: plaintext

  # Use the KMS API to encrypt the data
  response = kms_client.encrypt_crypto_key resource, request

  # Write the encrypted text to the output file
  File.write ciphertext_file, response.ciphertext

  puts "Saved encrypted #{plaintext_file} as #{ciphertext_file}"
  # [END kms_encrypt]
end

$decrypt = -> (project_id:, location_id:, key_ring_id:, crypto_key_id:, ciphertext_file:, plaintext_file:) do
  # [START kms_decrypt]
  # project_id    = "Your Google Cloud project ID"
  # location_id   = "The location of the key ring"
  # key_ring_id   = "The ID of the key ring"
  # crypto_key_id = "The ID of the crypto key"
  # ciphertext_file = "File to decrypt"
  # plaintext_file  = "File to store decrypted data"

  require "google/apis/cloudkms_v1"

  # Initialize the client and authenticate with the specified scope
  Cloudkms = Google::Apis::CloudkmsV1
  kms_client = Cloudkms::CloudKMSService.new
  kms_client.authorization = Google::Auth.get_application_default(
    "https://www.googleapis.com/auth/cloud-platform"
  )

  # The resource name of the crypto key
  resource = "projects/#{project_id}/locations/#{location_id}/" +
             "keyRings/#{key_ring_id}/cryptoKeys/#{crypto_key_id}"

  # Read the encrypted data from the file
  ciphertext = File.read ciphertext_file

  request = Cloudkms::DecryptRequest.new ciphertext: ciphertext

  # Use the KMS API to decrypt the data
  response = kms_client.decrypt_crypto_key resource, request

  # Write the decrypted text to the output file
  File.write plaintext_file, response.plaintext

  puts "Saved decrypted #{ciphertext_file} as #{plaintext_file}"
  # [END kms_decrypt]
end

$create_crypto_key_version = -> (project_id:, location_id:, key_ring_id:, crypto_key_id:) do
  # [START kms_create_cryptokey_version]
  # project_id    = "Your Google Cloud project ID"
  # location_id   = "The location of the key ring"
  # key_ring_id   = "The ID of the key ring"
  # crypto_key_id = "The ID of the crypto key"

  require "google/apis/cloudkms_v1"

  # Initialize the client and authenticate with the specified scope
  Cloudkms = Google::Apis::CloudkmsV1
  kms_client = Cloudkms::CloudKMSService.new
  kms_client.authorization = Google::Auth.get_application_default(
    "https://www.googleapis.com/auth/cloud-platform"
  )

  # The resource name of the crypto key
  resource = "projects/#{project_id}/locations/#{location_id}/" +
             "keyRings/#{key_ring_id}/cryptoKeys/#{crypto_key_id}"

  # Create a new version in the crypto key
  crypto_key_version = kms_client.create_project_location_key_ring_crypto_key_crypto_key_version(
      resource,
      Cloudkms::CryptoKey.new(purpose: "ENCRYPT_DECRYPT")
  )

  puts "Created version #{crypto_key_version.name} for key " +
       "#{crypto_key_id} in key ring #{key_ring_id}"
  # [END kms_create_cryptokey_version]
end

$set_crypto_key_primary_version = -> (project_id:, location_id:, key_ring_id:, crypto_key_id:, version_id:) do
  # [START kms_set_cryptokey_primary_version]
  # project_id    = "Your Google Cloud project ID"
  # location_id   = "The location of the key ring"
  # key_ring_id   = "The ID of the key ring"
  # crypto_key_id = "The ID of the crypto key"
  # version_id    = "Version of the crypto key"

  require "google/apis/cloudkms_v1"

  # Initialize the client and authenticate with the specified scope
  Cloudkms = Google::Apis::CloudkmsV1
  kms_client = Cloudkms::CloudKMSService.new
  kms_client.authorization = Google::Auth.get_application_default(
    "https://www.googleapis.com/auth/cloud-platform"
  )

  # The resource name of the crypto key
  resource = "projects/#{project_id}/locations/#{location_id}/" +
             "keyRings/#{key_ring_id}/cryptoKeys/#{crypto_key_id}"

  # Update the CryptoKey primary version
  crypto_key_version = kms_client.update_project_location_key_ring_crypto_key_primary_version(
      resource,
      Cloudkms::UpdateCryptoKeyPrimaryVersionRequest.new(crypto_key_version_id: version_id)
  )

  puts "Set #{version_id} as primary version for crypto key " +
       "#{crypto_key_id} in key ring #{key_ring_id}"
  # [END kms_set_cryptokey_primary_version]
end

$enable_crypto_key_version = -> (project_id:, location_id:, key_ring_id:, crypto_key_id:, version_id:) do
  # [START kms_enable_cryptokey_version]
  # project_id    = "Your Google Cloud project ID"
  # location_id   = "The location of the key ring"
  # key_ring_id   = "The ID of the key ring"
  # crypto_key_id = "The ID of the crypto key"
  # version_id    = "Version of the crypto key"

  require "google/apis/cloudkms_v1"

  # Initialize the client and authenticate with the specified scope
  Cloudkms = Google::Apis::CloudkmsV1
  kms_client = Cloudkms::CloudKMSService.new
  kms_client.authorization = Google::Auth.get_application_default(
    "https://www.googleapis.com/auth/cloud-platform"
  )

  # The resource name of the crypto key version
  resource = "projects/#{project_id}/locations/#{location_id}/" +
             "keyRings/#{key_ring_id}/cryptoKeys/#{crypto_key_id}/" +
             "cryptoKeyVersions/#{version_id}"

  # Get a version of the crypto key
  crypto_key_version = kms_client.get_project_location_key_ring_crypto_key_crypto_key_version resource

  # Set the primary version state as disabled for update
  crypto_key_version.state = "ENABLED"

  # Enable the crypto key version
  kms_client.patch_project_location_key_ring_crypto_key_crypto_key_version(
    resource,
    crypto_key_version, update_mask: "state"
  )

  puts "Enabled version #{version_id} of #{crypto_key_id}"
  # [END kms_enable_cryptokey_version]
end

$disable_crypto_key_version = -> (project_id:, key_ring_id:, crypto_key_id:, version_id:, location_id:) do
  # [START kms_disable_cryptokey_version]
  # project_id    = "Your Google Cloud project ID"
  # location_id   = "The location of the key ring"
  # key_ring_id   = "The ID of the key ring"
  # crypto_key_id = "The ID of the crypto key"
  # version_id    = "Version of the crypto key"

  require "google/apis/cloudkms_v1"

  # Initialize the client and authenticate with the specified scope
  Cloudkms = Google::Apis::CloudkmsV1
  kms_client = Cloudkms::CloudKMSService.new
  kms_client.authorization = Google::Auth.get_application_default(
    "https://www.googleapis.com/auth/cloud-platform"
  )

  # The resource name of the crypto key version
  resource = "projects/#{project_id}/locations/#{location_id}/" +
             "keyRings/#{key_ring_id}/cryptoKeys/#{crypto_key_id}/" +
             "cryptoKeyVersions/#{version_id}"

  # Get a crypto key version
  crypto_key_version = kms_client.get_project_location_key_ring_crypto_key_crypto_key_version resource

  # Set the primary version state as disabled for update
  crypto_key_version.state = "DISABLED"

  # Disable the crypto key version
  kms_client.patch_project_location_key_ring_crypto_key_crypto_key_version(
    resource,
    crypto_key_version, update_mask: "state"
  )

  puts "Disabled version #{version_id} of #{crypto_key_id}"
  # [END kms_disable_cryptokey_version]
end

$restore_crypto_key_version = -> (project_id:, location_id:, key_ring_id:, crypto_key_id:, version_id:) do
  # [START kms_restore_cryptokey_version]
  # project_id    = "Your Google Cloud project ID"
  # location_id   = "The location of the key ring"
  # key_ring_id   = "The ID of the key ring"
  # crypto_key_id = "The ID of the crypto key"
  # version_id    = "Version of the crypto key"

  require "google/apis/cloudkms_v1"

  # Initialize the client and authenticate with the specified scope
  Cloudkms = Google::Apis::CloudkmsV1
  kms_client = Cloudkms::CloudKMSService.new
  kms_client.authorization = Google::Auth.get_application_default(
    "https://www.googleapis.com/auth/cloud-platform"
  )

  # The resource name of the crypto key version
  resource = "projects/#{project_id}/locations/#{location_id}/" +
             "keyRings/#{key_ring_id}/cryptoKeys/#{crypto_key_id}/" +
             "cryptoKeyVersions/#{version_id}"

  # Restore specific version of the crypto key
  kms_client.restore_crypto_key_version(
    resource,
    Cloudkms::RestoreCryptoKeyVersionRequest.new
  )

  puts "Restored version #{version_id} of #{crypto_key_id}"
  # [END kms_restore_cryptokey_version]
end


$destroy_crypto_key_version = -> (project_id:, location_id:, key_ring_id:, crypto_key_id:, version_id:) do
  # [START kms_destroy_cryptokey_version]
  # project_id    = "Your Google Cloud project ID"
  # location_id   = "The location of the key ring"
  # key_ring_id   = "The ID of the key ring"
  # crypto_key_id = "The ID of the crypto key"
  # version_id    = "Version of the crypto key"

  require "google/apis/cloudkms_v1"

  # Initialize the client and authenticate with the specified scope
  Cloudkms = Google::Apis::CloudkmsV1
  kms_client = Cloudkms::CloudKMSService.new
  kms_client.authorization = Google::Auth.get_application_default(
    "https://www.googleapis.com/auth/cloud-platform"
  )

  # The resource name of the crypto key version
  resource = "projects/#{project_id}/locations/#{location_id}/" +
             "keyRings/#{key_ring_id}/cryptoKeys/#{crypto_key_id}/" +
             "cryptoKeyVersions/#{version_id}"

  # Destroy specific version of the crypto key
  kms_client.destroy_crypto_key_version(
    resource,
    Cloudkms::DestroyCryptoKeyVersionRequest.new
  )

  puts "Destroyed version #{version_id} of #{crypto_key_id}"
  # [END kms_destroy_cryptokey_version]
end

$add_member_to_key_ring_policy = -> (project_id:, location_id:, key_ring_id:, member:, role:) do
  # [START kms_add_member_to_keyring_policy]
  # project_id  = "Your Google Cloud project ID"
  # location_id = "The location of the key ring"
  # key_ring_id = "The ID of the key ring"
  # member      = "Member to add to the key ring policy"
  # role        = "Role assignment for new member"

  require "google/apis/cloudkms_v1"

  # Initialize the client and authenticate with the specified scope
  Cloudkms = Google::Apis::CloudkmsV1
  kms_client = Cloudkms::CloudKMSService.new
  kms_client.authorization = Google::Auth.get_application_default(
    "https://www.googleapis.com/auth/cloud-platform"
  )

  # The resource name of the key ring
  resource = "projects/#{project_id}/locations/#{location_id}/" +
             "keyRings/#{key_ring_id}"

  # Get the current IAM policy
  policy = kms_client.get_project_location_key_ring_iam_policy resource

  # Add new member to current bindings
  policy.bindings ||= []
  policy.bindings << Cloudkms::Binding.new(members: [member], role: role)

  # Update IAM policy
  policy_request = Cloudkms::SetIamPolicyRequest.new policy: policy
  kms_client.set_key_ring_iam_policy resource, policy_request

  puts "Member #{member} added to policy for " +
       "key ring #{key_ring_id}"
  # [END kms_add_member_to_keyring_policy]
end

$add_member_to_crypto_key_policy = -> (project_id:, location_id:, key_ring_id:, crypto_key_id:, member:, role:) do
  # [START kms_add_member_to_cryptokey_policy]
  # project_id    = "Your Google Cloud project ID"
  # location_id   = "The location of the key ring"
  # key_ring_id   = "The ID of the key ring"
  # crypto_key_id = "The ID of the crypto key"
  # member        = "Member to add to the crypto key policy"
  # role          = "Role assignment for new member"

  require "google/apis/cloudkms_v1"

  # Initialize the client and authenticate with the specified scope
  Cloudkms = Google::Apis::CloudkmsV1
  kms_client = Cloudkms::CloudKMSService.new
  kms_client.authorization = Google::Auth.get_application_default(
    "https://www.googleapis.com/auth/cloud-platform"
  )

  # The resource name of the crypto key
  resource = "projects/#{project_id}/locations/#{location_id}/" +
             "keyRings/#{key_ring_id}/cryptoKeys/#{crypto_key_id}"

  # Get the current IAM policy
  policy = kms_client.get_project_location_key_ring_crypto_key_iam_policy resource

  # Add new member to current bindings
  policy.bindings ||= []
  policy.bindings << Cloudkms::Binding.new(members: [member], role: role)

  # Update IAM policy
  policy_request = Cloudkms::SetIamPolicyRequest.new policy: policy
  kms_client.set_crypto_key_iam_policy resource, policy_request

  puts "Member #{member} added to policy for " +
       "crypto key #{crypto_key_id} in key ring #{key_ring_id}"
  # [END kms_add_member_to_cryptokey_policy]
end

$remove_member_from_crypto_key_policy = -> (project_id:, location_id:, key_ring_id:, crypto_key_id:, member:, role:) do
  # [START kms_remove_member_from_cryptokey_policy]
  # project_id    = "Your Google Cloud project ID"
  # location_id   = "The location of the key ring"
  # key_ring_id   = "The ID of the key ring"
  # crypto_key_id = "The ID of the crypto key"
  # member        = "Member to remove to the crypto key policy"
  # role          = "Role assignment for the member"

  require "google/apis/cloudkms_v1"

  # Initialize the client and authenticate with the specified scope
  Cloudkms = Google::Apis::CloudkmsV1
  kms_client = Cloudkms::CloudKMSService.new
  kms_client.authorization = Google::Auth.get_application_default(
    "https://www.googleapis.com/auth/cloud-platform"
  )

  # The resource name of the crypto key
  resource = "projects/#{project_id}/locations/#{location_id}/" +
             "keyRings/#{key_ring_id}/cryptoKeys/#{crypto_key_id}"

  # Get the current IAM policy
  policy = kms_client.get_project_location_key_ring_crypto_key_iam_policy resource

  # Remove a member to current bindings
  if policy.bindings
    policy.bindings.delete_if do |binding|
      binding.role.include?(role) && binding.members.include?(member)
    end
  end

  # Update IAM policy
  policy_request = Cloudkms::SetIamPolicyRequest.new policy: policy
  kms_client.set_crypto_key_iam_policy resource, policy_request

  puts "Member #{member} removed from policy for " +
       "crypto key #{crypto_key_id} in key ring #{key_ring_id}"
  # [END kms_remove_member_from_cryptokey_policy]
end

$get_key_ring_policy = -> (project_id:, key_ring_id:, location_id:) do
  # [START kms_get_keyring_policy]
  # project_id  = "Your Google Cloud project ID"
  # location_id = "The location of the key ring"
  # key_ring_id = "The ID of the key ring"

  require "google/apis/cloudkms_v1"

  # Initialize the client and authenticate with the specified scope
  Cloudkms = Google::Apis::CloudkmsV1
  kms_client = Cloudkms::CloudKMSService.new
  kms_client.authorization = Google::Auth.get_application_default(
    "https://www.googleapis.com/auth/cloud-platform"
  )

  # The resource name of the key ring
  resource = "projects/#{project_id}/locations/#{location_id}/" +
             "keyRings/#{key_ring_id}"

  # Get the current IAM policy
  policy = kms_client.get_project_location_key_ring_iam_policy resource

  # Print role and associated members
  if policy.bindings
    policy.bindings.each do |binding|
      puts "Role: #{binding.role} Members: #{binding.members}"
    end
  else
    puts "No members"
  end
  # [END kms_get_keyring_policy]
end

def run_sample arguments
  command    = arguments.shift
  project_id = ENV["GOOGLE_CLOUD_PROJECT"]

  case command
  when "create_key_ring"
    $create_key_ring.call(
      project_id:    project_id,
      location_id:   arguments.shift,
      key_ring_id:   arguments.shift
    )
  when "create_crypto_key"
    $create_crypto_key.call(
      project_id:    project_id,
      location_id:   arguments.shift,
      key_ring_id:   arguments.shift,
      crypto_key_id: arguments.shift
    )
  when "encrypt_file"
    $encrypt.call(
      project_id:    project_id,
      location_id:   arguments.shift,
      key_ring_id:   arguments.shift,
      crypto_key_id: arguments.shift,
      input_file:    arguments.shift,
      output_file:   arguments.shift
    )
  when "decrypt_file"
    $decrypt.call(
      project_id:    project_id,
      location_id:   arguments.shift,
      key_ring_id:   arguments.shift,
      crypto_key_id: arguments.shift,
      input_file:    arguments.shift,
      output_file:   arguments.shift
    )
  when "create_crypto_key_version"
    $create_crypto_key_version.call(
      project_id:    project_id,
      location_id:   arguments.shift,
      key_ring_id:   arguments.shift,
      crypto_key_id: arguments.shift
    )
  when "set_crypto_key_primary_version"
    $set_crypto_key_primary_version.call(
      project_id:    project_id,
      location_id:   arguments.shift,
      key_ring_id:   arguments.shift,
      crypto_key_id: arguments.shift,
      version_id:    arguments.shift
    )
  when "enable_crypto_key_version"
    $enable_crypto_key_version.call(
      project_id:    project_id,
      location_id:   arguments.shift,
      key_ring_id:   arguments.shift,
      crypto_key_id: arguments.shift,
      version_id:    arguments.shift
    )
  when "disable_crypto_key_version"
    $disable_crypto_key_version.call(
      project_id:    project_id,
      location_id:   arguments.shift,
      key_ring_id:   arguments.shift,
      crypto_key_id: arguments.shift,
      version_id:    arguments.shift
    )
  when "restore_crypto_key_version"
    $restore_crypto_key_version.call(
      project_id:    project_id,
      key_ring_id:   arguments.shift,
      crypto_key_id: arguments.shift,
      version_id:    arguments.shift,
      location_id:   arguments.shift,
    )
  when "destroy_crypto_key_version"
    $destroy_crypto_key_version.call(
      project_id:    project_id,
      location_id:   arguments.shift,
      key_ring_id:   arguments.shift,
      crypto_key_id: arguments.shift,
      version_id:    arguments.shift
    )
  when "add_member_to_key_ring_policy"
    $add_member_to_key_ring_policy.call(
      project_id:    project_id,
      location_id:   arguments.shift,
      key_ring_id:   arguments.shift,
      member:        arguments.shift,
      role:          arguments.shift
    )
  when "add_member_to_crypto_key_policy"
    $add_member_to_crypto_key_policy.call(
      project_id:    project_id,
      location_id:   arguments.shift,
      key_ring_id:   arguments.shift,
      crypto_key_id: arguments.shift,
      member:        arguments.shift,
      role:          arguments.shift
    )
  when "remove_member_from_crypto_key_policy"
    $remove_member_from_crypto_key_policy.call(
      project_id:    project_id,
      location_id:   arguments.shift,
      key_ring_id:   arguments.shift,
      crypto_key_id: arguments.shift,
      member:        arguments.shift,
      role:          arguments.shift
    )
  when "get_key_ring_policy"
    $get_key_ring_policy.call(
      project_id:    project_id,
      location_id:   arguments.shift,
      key_ring_id:   arguments.shift
    )
  else
    puts <<-usage
Usage: bundle exec ruby kms.rb [command] [arguments]

Commands:
  create_key_ring                      <location> <key_ring> Create a new key ring
  create_crypto_key                    <location> <key_ring> <crypto_key> Create a new crypto key
  encrypt_file                         <location> <key_ring> <crypto_key> <input_file> <output_file> Encrypt a file
  decrypt_file                         <location> <key_ring> <crypto_key> <input_file> <output_file> Decrypt a file
  create_crypto_key_version            <location> <key_ring> <crypto_key> Create a new crypto key version
  set_crypto_key_primary_version       <location> <key_ring> <crypto_key> <verison> Set a primary crypto key version
  enable_crypto_key_version            <location> <key_ring> <crypto_key> <version> Enable a crypto key version
  disable_crypto_key_version           <location> <key_ring> <crypto_key> <version> Disable a crypto key version
  restore_crypto_key_version           <location> <key_ring> <crypto_key> <version> Restore a crypto key version
  destroy_crypto_key_version           <location> <key_ring> <crypto_key> <version> Destroy a crypto key version
  add_member_to_key_ring_policy        <location> <key_ring> <member> <role> Add member to key ring IAM policy
  add_member_to_crypto_key_policy      <location> <key_ring> <crypto_key> <member> <role> Add member to crypto key IAM policy
  remove_member_from_crypto_key_policy <location> <key_ring> <crypto_key> <member> <role> Remove member from crypto key IAM policy
  get_key_ring_policy                  <location> <key_ring> Get a key ring IAM policy

Environment variables:
  GOOGLE_CLOUD_PROJECT must be set to your Google Cloud project ID
    usage
  end
end

if __FILE__ == $PROGRAM_NAME
  run_sample ARGV
end

