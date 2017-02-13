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

# Note: Code samples in this file set constants which cannot be set inside
#       method definitions in Ruby. To allow for this, code snippets in this
#       sample are wrapped in global lambdas.

$create_keyring = -> (project_id:, key_ring_id:, location:) do
  # [START kms_create_keyring]
  # project_id  = "Your Google Cloud project ID"
  # key_ring_id = "The ID of the new key ring"
  # location    = "The location of the new key ring"

  require "google/apis/cloudkms_v1beta1"

  # Initialize the client and authenticate with the specified scope
  Cloudkms = Google::Apis::CloudkmsV1beta1
  kms_client = Cloudkms::CloudKMSService.new
  kms_client.authorization = Google::Auth.get_application_default(
    "https://www.googleapis.com/auth/cloud-platform"
  )

  # The resource name of the location associated with the key ring
  resource = "projects/#{project_id}/locations/#{location}"

  # Create a key ring for your project
  key_ring = kms_client.create_project_location_key_ring(
    resource,
    Cloudkms::KeyRing.new,
    key_ring_id: key_ring_id
  )

  puts "Created key ring #{key_ring_id}"
  # [END kms_create_keyring]
end

$create_cryptokey = -> (project_id:, key_ring_id:, crypto_key:, location:) do
  # [START kms_create_cryptokey]
  # project_id  = "Your Google Cloud project ID"
  # key_ring_id = "The ID of the new key ring"
  # crypto_key  = "Name of the crypto key"
  # location    = "The location of the new key ring"

  require "google/apis/cloudkms_v1beta1"

  # Initialize the client and authenticate with the specified scope
  Cloudkms = Google::Apis::CloudkmsV1beta1
  kms_client = Cloudkms::CloudKMSService.new
  kms_client.authorization = Google::Auth.get_application_default(
    "https://www.googleapis.com/auth/cloud-platform"
  )

  # The resource name of the location associated with the key ring
  resource = "projects/#{project_id}/locations/#{location}/" +
             "keyRings/#{key_ring_id}"

  # Create a crypto key for your project key ring
  new_crypto_key = kms_client.create_project_location_key_ring_crypto_key(
    resource,
    Cloudkms::CryptoKey.new(purpose: "ENCRYPT_DECRYPT"),
    crypto_key_id: crypto_key
  )

  puts "Created crypto key #{crypto_key}"
  # [END kms_create_cryptokey]
end

$encrypt = -> (project_id:, key_ring_id:, crypto_key:, location:, input_file:, output_file:) do
  # [START kms_encrypt]
  # project_id  = "Your Google Cloud project ID"
  # key_ring_id = "The ID of the new key ring"
  # crypto_key  = "Name of the crypto key"
  # location    = "The location of the new key ring"
  # input_file  = "File to encrypt"
  # output_file = "File name to use for encrypted input file"

  require "google/apis/cloudkms_v1beta1"

  # Initialize the client and authenticate with the specified scope
  Cloudkms = Google::Apis::CloudkmsV1beta1
  kms_client = Cloudkms::CloudKMSService.new
  kms_client.authorization = Google::Auth.get_application_default(
    "https://www.googleapis.com/auth/cloud-platform"
  )

  # The resource name of the location associated with the key ring crypto key
  resource = "projects/#{project_id}/locations/#{location}/" +
             "keyRings/#{key_ring_id}/cryptoKeys/#{crypto_key}"

  # Use the KMS API to encrypt the text
  plain_text = File.read input_file

  request = Cloudkms::EncryptRequest.new plaintext: plain_text

  response = kms_client.encrypt_crypto_key resource, request

  # Write the encrypted text to a file
  File.write output_file, response.ciphertext

  puts "Saved encrypted #{input_file} as #{output_file}"
  # [END kms_encrypt]
end

$decrypt = -> (project_id:, key_ring_id:, crypto_key:, location:, input_file:, output_file:) do
  # [START kms_decrypt]
  # project_id  = "Your Google Cloud project ID"
  # key_ring_id = "The ID of the new key ring"
  # crypto_key  = "Name of the crypto key"
  # location    = "The location of the new key ring"
  # input_file  = "The path to an encrypted file"
  # output_file = "The path to write the decrypted file"

  require "google/apis/cloudkms_v1beta1"

  # Initialize the client and authenticate with the specified scope
  Cloudkms = Google::Apis::CloudkmsV1beta1
  kms_client = Cloudkms::CloudKMSService.new
  kms_client.authorization = Google::Auth.get_application_default(
    "https://www.googleapis.com/auth/cloud-platform"
  )

  # The resource name of the location associated with the key ring crypto key
  resource = "projects/#{project_id}/locations/#{location}/" +
             "keyRings/#{key_ring_id}/cryptoKeys/#{crypto_key}"

  # Use the KMS API to decrypt the text
  encrypted_text = File.read input_file

  request = Cloudkms::DecryptRequest.new ciphertext: encrypted_text

  response = kms_client.decrypt_crypto_key resource, request

  # Write the decrypted text to a file
  File.write output_file, response.plaintext

  puts "Saved decrypted #{input_file} as #{output_file}"
  # [END kms_decrypt]
end

$create_cryptokey_version = -> (project_id:, key_ring_id:, crypto_key:, location:) do
  # [START kms_create_cryptokey_version]
  # project_id  = "Your Google Cloud project ID"
  # key_ring_id = "The ID of the new key ring"
  # crypto_key  = "Name of the crypto key"
  # location    = "The location of the new key ring"

  require "google/apis/cloudkms_v1beta1"

  # Initialize the client and authenticate with the specified scope
  Cloudkms = Google::Apis::CloudkmsV1beta1
  kms_client = Cloudkms::CloudKMSService.new
  kms_client.authorization = Google::Auth.get_application_default(
    "https://www.googleapis.com/auth/cloud-platform"
  )

  # The resource name of the location associated with the key ring crypto key
  resource = "projects/#{project_id}/locations/#{location}/" +
             "keyRings/#{key_ring_id}/cryptoKeys/#{crypto_key}"

  # Create the crypto key version for your project
  crypto_key_version = kms_client.create_project_location_key_ring_crypto_key_crypto_key_version(
      resource,
      Cloudkms::CryptoKey.new(purpose: "ENCRYPT_DECRYPT")
  )

  puts "Created version #{crypto_key_version.name} for key " +
       "#{crypto_key} in key ring #{key_ring_id}"
  # [END kms_create_cryptokey_version]
end

$set_cryptokey_primary_version = -> (project_id:, key_ring_id:, crypto_key:, version:, location:) do
  # [START kms_set_cryptokey_primary_version]
  # project_id  = "Your Google Cloud project ID"
  # key_ring_id = "The ID of the new key ring"
  # crypto_key  = "Name of the crypto key"
  # version     = "Version of the crypto key"
  # location    = "The location of the new key ring"

  require "google/apis/cloudkms_v1beta1"

  # Initialize the client and authenticate with the specified scope
  Cloudkms = Google::Apis::CloudkmsV1beta1
  kms_client = Cloudkms::CloudKMSService.new
  kms_client.authorization = Google::Auth.get_application_default(
    "https://www.googleapis.com/auth/cloud-platform"
  )

  # The resource name of the location associated with the key ring crypto key
  resource = "projects/#{project_id}/locations/#{location}/" +
             "keyRings/#{key_ring_id}/cryptoKeys/#{crypto_key}"

  # Update the CryptoKey primary version
  crypto_key_version = kms_client.update_project_location_key_ring_crypto_key_primary_version(
      resource,
      Cloudkms::UpdateCryptoKeyPrimaryVersionRequest.new(crypto_key_version_id: version)
  )

  puts "Set #{version} as primary version for crypto key " +
       "#{crypto_key} in key ring #{key_ring_id}"
  # [END kms_set_cryptokey_primary_version]
end

$enable_cryptokey_version = -> (project_id:, key_ring_id:, crypto_key:, version:, location:) do
  # [START kms_enable_cryptokey_version]
  # project_id  = "Your Google Cloud project ID"
  # key_ring_id = "The ID of the new key ring"
  # crypto_key  = "Name of the crypto key"
  # version     = "Version of the crypto key"
  # location    = "The location of the new key ring"

  require "google/apis/cloudkms_v1beta1"

  # Initialize the client and authenticate with the specified scope
  Cloudkms = Google::Apis::CloudkmsV1beta1
  kms_client = Cloudkms::CloudKMSService.new
  kms_client.authorization = Google::Auth.get_application_default(
    "https://www.googleapis.com/auth/cloud-platform"
  )

  # The resource name of the location associated with the key ring crypto key version
  resource = "projects/#{project_id}/locations/#{location}/" +
             "keyRings/#{key_ring_id}/cryptoKeys/#{crypto_key}/" +
             "cryptoKeyVersions/#{version}"

  # Get a version of the crypto key
  crypto_key_version = kms_client.get_project_location_key_ring_crypto_key_crypto_key_version resource

  # Set the primary version state as disabled for update
  crypto_key_version.state = "ENABLED"

  # Enable the crypto key version
  kms_client.patch_project_location_key_ring_crypto_key_crypto_key_version(
    resource,
    crypto_key_version, update_mask: "state"
  )

  puts "Enabled version #{version} of #{crypto_key}"
  # [END kms_enable_cryptokey_version]
end

$disable_cryptokey_version = -> (project_id:, key_ring_id:, crypto_key:, version:, location:) do
  # [START kms_disable_cryptokey_version]
  # project_id  = "Your Google Cloud project ID"
  # key_ring_id = "The ID of the new key ring"
  # crypto_key  = "Name of the crypto key"
  # version     = "Version of the crypto key"
  # location    = "The location of the new key ring"

  require "google/apis/cloudkms_v1beta1"

  # Initialize the client and authenticate with the specified scope
  Cloudkms = Google::Apis::CloudkmsV1beta1
  kms_client = Cloudkms::CloudKMSService.new
  kms_client.authorization = Google::Auth.get_application_default(
    "https://www.googleapis.com/auth/cloud-platform"
  )

  # The resource name of the location associated with the key ring crypto key version
  resource = "projects/#{project_id}/locations/#{location}/" +
             "keyRings/#{key_ring_id}/cryptoKeys/#{crypto_key}/" +
             "cryptoKeyVersions/#{version}"

  # Get a version of the crypto key
  crypto_key_version = kms_client.get_project_location_key_ring_crypto_key_crypto_key_version resource

  # Set the primary version state as disabled for update
  crypto_key_version.state = "DISABLED"

  # Disable the crypto key version
  kms_client.patch_project_location_key_ring_crypto_key_crypto_key_version(
    resource,
    crypto_key_version, update_mask: "state"
  )

  puts "Disabled version #{version} of #{crypto_key}"
  # [END kms_disable_cryptokey_version]
end

$restore_cryptokey_version = -> (project_id:, key_ring_id:, crypto_key:, version:, location:) do
  # [START kms_restore_cryptokey_version]
  # project_id  = "Your Google Cloud project ID"
  # key_ring_id = "The ID of the new key ring"
  # crypto_key  = "Name of the crypto key"
  # version     = "Version of the crypto key"
  # location    = "The location of the new key ring"

  require "google/apis/cloudkms_v1beta1"

  # Initialize the client and authenticate with the specified scope
  Cloudkms = Google::Apis::CloudkmsV1beta1
  kms_client = Cloudkms::CloudKMSService.new
  kms_client.authorization = Google::Auth.get_application_default(
    "https://www.googleapis.com/auth/cloud-platform"
  )

  # The resource name of the location associated with the key ring crypto key version
  resource = "projects/#{project_id}/locations/#{location}/" +
             "keyRings/#{key_ring_id}/cryptoKeys/#{crypto_key}/" +
             "cryptoKeyVersions/#{version}"

  # Restore specific version of the crypto key
  kms_client.restore_crypto_key_version(
    resource,
    Cloudkms::RestoreCryptoKeyVersionRequest.new
  )

  puts "Restored version #{version} of #{crypto_key}"
  # [END kms_restore_cryptokey_version]
end


$destroy_cryptokey_version = -> (project_id:, key_ring_id:, crypto_key:, version:, location:) do
  # [START kms_destroy_cryptokey_version]
  # project_id  = "Your Google Cloud project ID"
  # key_ring_id = "The ID of the new key ring"
  # crypto_key  = "Name of the crypto key"
  # version     = "Version of the crypto key"
  # location    = "The location of the new key ring"

  require "google/apis/cloudkms_v1beta1"

  # Initialize the client and authenticate with the specified scope
  Cloudkms = Google::Apis::CloudkmsV1beta1
  kms_client = Cloudkms::CloudKMSService.new
  kms_client.authorization = Google::Auth.get_application_default(
    "https://www.googleapis.com/auth/cloud-platform"
  )

  # The resource name of the location associated with the key ring crypto key version
  resource = "projects/#{project_id}/locations/#{location}/" +
             "keyRings/#{key_ring_id}/cryptoKeys/#{crypto_key}/" +
             "cryptoKeyVersions/#{version}"

  # Destroy specific version of the crypto key
  kms_client.destroy_crypto_key_version(
    resource,
    Cloudkms::DestroyCryptoKeyVersionRequest.new
  )

  puts "Destroyed version #{version} of #{crypto_key}"
  # [END kms_destroy_cryptokey_version]
end

$add_member_to_keyring_policy = -> (project_id:, key_ring_id:, member:, role:, location:) do
  # [START kms_add_member_to_keyring_policy]
  # project_id  = "Your Google Cloud project ID"
  # key_ring_id = "The ID of the new key ring"
  # member      = "Member to add to the crypto key policy"
  # role        = "Role assignment for new member"
  # location    = "The location of the new key ring"

  require "google/apis/cloudkms_v1beta1"

  # Initialize the client and authenticate with the specified scope
  Cloudkms = Google::Apis::CloudkmsV1beta1
  kms_client = Cloudkms::CloudKMSService.new
  kms_client.authorization = Google::Auth.get_application_default(
    "https://www.googleapis.com/auth/cloud-platform"
  )

  # The resource name of the location associated with the key ring
  resource = "projects/#{project_id}/locations/#{location}/" +
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

$add_member_to_cryptokey_policy = -> (project_id:, key_ring_id:, crypto_key:, member:, role:, location:) do
  # [START kms_add_member_to_cryptokey_policy]
  # project_id  = "Your Google Cloud project ID"
  # key_ring_id = "The ID of the new key ring"
  # crypto_key  = "Name of the crypto key"
  # member      = "Member to add to the crypto key policy"
  # role        = "Role assignment for new member"
  # location    = "The location of the new key ring"

  require "google/apis/cloudkms_v1beta1"

  # Initialize the client and authenticate with the specified scope
  Cloudkms = Google::Apis::CloudkmsV1beta1
  kms_client = Cloudkms::CloudKMSService.new
  kms_client.authorization = Google::Auth.get_application_default(
    "https://www.googleapis.com/auth/cloud-platform"
  )

  # The resource name of the location associated with the key ring crypto key
  resource = "projects/#{project_id}/locations/#{location}/" +
             "keyRings/#{key_ring_id}/cryptoKeys/#{crypto_key}"

  # Get the current IAM policy
  policy = kms_client.get_project_location_key_ring_crypto_key_iam_policy resource

  # Add new member to current bindings
  policy.bindings ||= []
  policy.bindings << Cloudkms::Binding.new(members: [member], role: role)

  # Update IAM policy
  policy_request = Cloudkms::SetIamPolicyRequest.new policy: policy
  kms_client.set_crypto_key_iam_policy resource, policy_request

  puts "Member #{member} added to policy for " +
       "crypto key #{crypto_key} in key ring #{key_ring_id}"
  # [END kms_add_member_to_cryptokey_policy]
end

$remove_member_from_cryptokey_policy = -> (project_id:, key_ring_id:, crypto_key:, member:, role:, location:) do
  # [START kms_remove_member_from_cryptokey_policy]
  # project_id  = "Your Google Cloud project ID"
  # key_ring_id = "The ID of the new key ring"
  # crypto_key  = "Name of the crypto key"
  # member      = "Member to add to the crypto key policy"
  # role        = "Role assignment for new member"
  # location    = "The location of the new key ring"

  require "google/apis/cloudkms_v1beta1"

  # Initialize the client and authenticate with the specified scope
  Cloudkms = Google::Apis::CloudkmsV1beta1
  kms_client = Cloudkms::CloudKMSService.new
  kms_client.authorization = Google::Auth.get_application_default(
    "https://www.googleapis.com/auth/cloud-platform"
  )

  # The resource name of the location associated with the key ring crypto key
  resource = "projects/#{project_id}/locations/#{location}/" +
             "keyRings/#{key_ring_id}/cryptoKeys/#{crypto_key}"

  # Get the current IAM policy
  policy = kms_client.get_project_location_key_ring_crypto_key_iam_policy resource

  # Remove a member to current bindings
  if policy.bindings
    policy.bindings.delete_if do |binding|
      binding.role.include? role and binding.members.include? member
    end
  end

  # Update IAM policy
  policy_request = Cloudkms::SetIamPolicyRequest.new policy: policy
  kms_client.set_crypto_key_iam_policy resource, policy_request

  puts "Member #{member} removed from policy for " +
       "crypto key #{crypto_key} in key ring #{key_ring_id}"
  # [END kms_remove_member_from_cryptokey_policy]
end

$get_keyring_policy = -> (project_id:, key_ring_id:, location:) do
  # [START kms_get_keyring_policy]
  # project_id  = "Your Google Cloud project ID"
  # key_ring_id = "The ID of the new key ring"
  # location    = "The location of the new key ring"

  require "google/apis/cloudkms_v1beta1"

  # Initialize the client and authenticate with the specified scope
  Cloudkms = Google::Apis::CloudkmsV1beta1
  kms_client = Cloudkms::CloudKMSService.new
  kms_client.authorization = Google::Auth.get_application_default(
    "https://www.googleapis.com/auth/cloud-platform"
  )

  # The resource name of the location associated with the key ring
  resource = "projects/#{project_id}/locations/#{location}/" +
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
  when "create_keyring"
    $create_keyring.call(
      project_id: project_id,
      key_ring_id: arguments.shift,
      location: arguments.shift
    )
  when "create_cryptokey"
    $create_cryptokey.call(
      project_id: project_id,
      key_ring_id: arguments.shift,
      crypto_key: arguments.shift,
      location: arguments.shift
    )
  when "encrypt_file"
    $encrypt.call(
      project_id: project_id,
      key_ring_id: arguments.shift,
      crypto_key: arguments.shift,
      location: arguments.shift,
      input_file: arguments.shift,
      output_file: arguments.shift
    )
  when "decrypt_file"
    $decrypt.call(
      project_id: project_id,
      key_ring_id: arguments.shift,
      crypto_key: arguments.shift,
      location: arguments.shift,
      input_file: arguments.shift,
      output_file: arguments.shift
    )
  when "create_cryptokey_version"
    $create_cryptokey_version.call(
      project_id: project_id,
      key_ring_id: arguments.shift,
      crypto_key: arguments.shift,
      location: arguments.shift
    )
  when "set_cryptokey_primary_version"
    $set_cryptokey_primary_version.call(
      project_id: project_id,
      key_ring_id: arguments.shift,
      crypto_key: arguments.shift,
      version: arguments.shift,
      location: arguments.shift
    )
  when "enable_cryptokey_version"
    $enable_cryptokey_version.call(
      project_id: project_id,
      key_ring_id: arguments.shift,
      crypto_key: arguments.shift,
      version: arguments.shift,
      location: arguments.shift
    )
  when "disable_cryptokey_version"
    $disable_cryptokey_version.call(
      project_id: project_id,
      key_ring_id: arguments.shift,
      crypto_key: arguments.shift,
      version: arguments.shift,
      location: arguments.shift
    )
  when "restore_cryptokey_version"
    $restore_cryptokey_version.call(
      project_id: project_id,
      key_ring_id: arguments.shift,
      crypto_key: arguments.shift,
      version: arguments.shift,
      location: arguments.shift
    )
  when "destroy_cryptokey_version"
    $destroy_cryptokey_version.call(
      project_id: project_id,
      key_ring_id: arguments.shift,
      crypto_key: arguments.shift,
      version: arguments.shift,
      location: arguments.shift
    )
  when "add_member_to_keyring_policy"
    $add_member_to_keyring_policy.call(
      project_id: project_id,
      key_ring_id: arguments.shift,
      member: arguments.shift,
      role: arguments.shift,
      location: arguments.shift
    )
  when "add_member_to_cryptokey_policy"
    $add_member_to_cryptokey_policy.call(
      project_id: project_id,
      key_ring_id: arguments.shift,
      crypto_key: arguments.shift,
      member: arguments.shift,
      role: arguments.shift,
      location: arguments.shift
    )
  when "remove_member_from_cryptokey_policy"
    $remove_member_from_cryptokey_policy.call(
      project_id: project_id,
      key_ring_id: arguments.shift,
      crypto_key: arguments.shift,
      member: arguments.shift,
      role: arguments.shift,
      location: arguments.shift
    )
  when "get_keyring_policy"
    $get_keyring_policy.call(
      project_id: project_id,
      key_ring_id: arguments.shift,
      location: arguments.shift
    )
  else
    puts <<-usage
Usage: bundle exec ruby kms.rb [command] [arguments]

Commands:
  create_keyring                      <key_ring> <location> Create a new keyring
  create_cryptokey                    <key_ring> <crypto_key> <location> Create a new cryptokey
  encrypt_file                        <key_ring> <crypto_key> <location> <input_file> <output_file> Encrypt a file
  decrypt_file                        <key_ring> <crypto_key> <location> <input_file> <output_file> Decrypt a file
  create_cryptokey_version            <key_ring> <crypto_key> <location> Create a new cryptokey version
  set_cryptokey_primary_version       <key_ring> <crypto_key> <verison> <location> Set a primary cryptokey version
  enable_cryptokey_version            <key_ring> <crypto_key> <version> <location> Enable a cryptokey version
  disable_cryptokey_version           <key_ring> <crypto_key> <version> <location> Disable a cryptokey version
  restore_cryptokey_version           <key_ring> <crypto_key> <version> <location> Restore a cryptokey version
  destroy_cryptokey_version           <key_ring> <crypto_key> <version> <location> Destroy a cryptokey version
  add_member_to_keyring_policy        <key_ring> <member> <role> <location> Add member to keyring IAM policy
  add_member_to_cryptokey_policy      <key_ring> <crypto_key> <member> <role> <location> Add member to cryptokey IAM policy
  remove_member_from_cryptokey_policy <key_ring> <crypto_key> <member> <role> <location> Remove member from cryptokey IAM policy
  get_keyring_policy                  <key_ring> <location> Get a keyring IAM policy

Environment variables:
  GOOGLE_CLOUD_PROJECT must be set to your Google Cloud project ID
    usage
  end
end

if __FILE__ == $PROGRAM_NAME
  run_sample ARGV
end

