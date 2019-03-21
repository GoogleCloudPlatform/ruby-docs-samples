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

$create_key_ring = lambda do |project_id:, location_id:, key_ring_id:|
  # [START kms_create_keyring]
  # project_id  = "Your Google Cloud project ID"
  # key_ring_id = "The ID of the new key ring"
  # location_id = "The location of the new key ring"

  require "google/cloud/kms/v1"
  CloudKMS = Google::Cloud::Kms::V1

  # Initialize the client
  client = CloudKMS::KeyManagementServiceClient.new

  # The location associated with the key ring
  location = CloudKMS::KeyManagementServiceClient.location_path project_id, location_id

  # KeyRing creation parameters (currently unused)
  key_ring_spec = CloudKMS::KeyRing.new

  # Create a key ring for your project
  key_ring = client.create_key_ring location, key_ring_id, key_ring_spec

  puts "Created key ring #{key_ring_id}"
  # [END kms_create_keyring]
end

$create_crypto_key = lambda do |project_id:, location_id:, key_ring_id:, crypto_key_id:|
  # [START kms_create_cryptokey]
  # project_id    = "Your Google Cloud project ID"
  # location_id   = "The location of the key ring"
  # key_ring_id   = "The ID of the key ring"
  # crypto_key_id = "The ID of the new crypto key"

  require "google/cloud/kms/v1"
  CloudKMS = Google::Cloud::Kms::V1

  # Initialize the client
  client = CloudKMS::KeyManagementServiceClient.new

  # The key ring to use
  key_ring =
    CloudKMS::KeyManagementServiceClient.key_ring_path project_id, location_id, key_ring_id

  # CryptoKey creation parameters
  crypto_key_spec = CloudKMS::CryptoKey.new
  crypto_key_spec.purpose = CloudKMS::CryptoKey::CryptoKeyPurpose::ENCRYPT_DECRYPT

  # Create a crypto key in the key ring
  crypto_key = client.create_crypto_key key_ring, crypto_key_id, crypto_key_spec

  puts "Created crypto key #{crypto_key_id}"
  # [END kms_create_cryptokey]
end

$encrypt = lambda do |project_id:, location_id:, key_ring_id:, crypto_key_id:, plaintext_file:, ciphertext_file:|
  # [START kms_encrypt]
  # project_id      = "Your Google Cloud project ID"
  # location_id     = "The location of the key ring"
  # key_ring_id     = "The ID of the key ring"
  # crypto_key_id   = "The ID of the crypto key"
  # plaintext_file  = "File to encrypt"
  # ciphertext_file = "File to store encrypted input data"

  require "google/cloud/kms/v1"
  CloudKMS = Google::Cloud::Kms::V1

  # Initialize the client
  client = CloudKMS::KeyManagementServiceClient.new

  # The crypto key to use
  crypto_key = CloudKMS::KeyManagementServiceClient.crypto_key_path(
    project_id, location_id, key_ring_id, crypto_key_id
  )

  # Read the secret data from the file
  plaintext = File.open(plaintext_file, "rb", &:read)

  # Use the KMS API to encrypt the data
  response = client.encrypt crypto_key, plaintext

  # Write the encrypted binary data to the output file
  File.open(ciphertext_file, "wb") { |f| f.write response.ciphertext }

  puts "Saved encrypted #{plaintext_file} as #{ciphertext_file}"
  # [END kms_encrypt]
end

$decrypt = lambda do |project_id:, location_id:, key_ring_id:, crypto_key_id:, ciphertext_file:, plaintext_file:|
  # [START kms_decrypt]
  # project_id    = "Your Google Cloud project ID"
  # location_id   = "The location of the key ring"
  # key_ring_id   = "The ID of the key ring"
  # crypto_key_id = "The ID of the crypto key"
  # ciphertext_file = "File to decrypt"
  # plaintext_file  = "File to store decrypted data"

  require "google/cloud/kms/v1"
  CloudKMS = Google::Cloud::Kms::V1

  # Initialize the client
  client = CloudKMS::KeyManagementServiceClient.new

  # The crypto key to use
  crypto_key = CloudKMS::KeyManagementServiceClient.crypto_key_path(
    project_id, location_id, key_ring_id, crypto_key_id
  )

  # Read the encrypted data from the file
  ciphertext = File.open(ciphertext_file, "rb", &:read)

  # Use the KMS API to decrypt the data
  response = client.decrypt crypto_key, ciphertext

  # Write the decrypted text to the output file
  File.open(plaintext_file, "wb") { |f| f.write response.plaintext }

  puts "Saved decrypted #{ciphertext_file} as #{plaintext_file}"
  # [END kms_decrypt]
end

$create_crypto_key_version = lambda do |project_id:, location_id:, key_ring_id:, crypto_key_id:|
  # [START kms_create_cryptokey_version]
  # project_id    = "Your Google Cloud project ID"
  # location_id   = "The location of the key ring"
  # key_ring_id   = "The ID of the key ring"
  # crypto_key_id = "The ID of the crypto key"

  require "google/cloud/kms/v1"
  CloudKMS = Google::Cloud::Kms::V1

  # Initialize the client
  client = CloudKMS::KeyManagementServiceClient.new

  # The crypto key to use
  crypto_key = CloudKMS::KeyManagementServiceClient.crypto_key_path(
    project_id, location_id, key_ring_id, crypto_key_id
  )

  # CryptoKeyVersion creation parameters (currently unused)
  version_spec = CloudKMS::CryptoKeyVersion.new

  # Create a new version in the crypto key
  crypto_key_version = client.create_crypto_key_version crypto_key, version_spec

  puts "Created version #{crypto_key_version.name} for key " +
       "#{crypto_key_id} in key ring #{key_ring_id}"
  # [END kms_create_cryptokey_version]
end

$set_crypto_key_primary_version = lambda do |project_id:, location_id:, key_ring_id:, crypto_key_id:, version_id:|
  # [START kms_set_cryptokey_primary_version]
  # project_id    = "Your Google Cloud project ID"
  # location_id   = "The location of the key ring"
  # key_ring_id   = "The ID of the key ring"
  # crypto_key_id = "The ID of the crypto key"
  # version_id    = "Version of the crypto key"

  require "google/cloud/kms/v1"
  CloudKMS = Google::Cloud::Kms::V1

  # Initialize the client
  client = CloudKMS::KeyManagementServiceClient.new

  # The crypto key to use
  crypto_key = CloudKMS::KeyManagementServiceClient.crypto_key_path(
    project_id, location_id, key_ring_id, crypto_key_id
  )

  # Update the CryptoKey primary version
  crypto_key_version = client.update_crypto_key_primary_version crypto_key, version_id

  puts "Set #{version_id} as primary version for crypto key " +
       "#{crypto_key_id} in key ring #{key_ring_id}"
  # [END kms_set_cryptokey_primary_version]
end

$enable_crypto_key_version = lambda do |project_id:, location_id:, key_ring_id:, crypto_key_id:, version_id:|
  # [START kms_enable_cryptokey_version]
  # project_id    = "Your Google Cloud project ID"
  # location_id   = "The location of the key ring"
  # key_ring_id   = "The ID of the key ring"
  # crypto_key_id = "The ID of the crypto key"
  # version_id    = "Version of the crypto key"

  require "google/cloud/kms/v1"
  CloudKMS = Google::Cloud::Kms::V1

  # Initialize the client
  client = CloudKMS::KeyManagementServiceClient.new

  # Retrieve the crypto key version to update
  version_path = CloudKMS::KeyManagementServiceClient.crypto_key_version_path(
    project_id, location_id, key_ring_id, crypto_key_id, version_id
  )
  version = client.get_crypto_key_version version_path

  # Set the version state to enabled for update
  version.state = CloudKMS::CryptoKeyVersion::CryptoKeyVersionState::ENABLED
  update_mask = Google::Protobuf::FieldMask.new
  update_mask.paths << "state"

  # Enable the crypto key version
  result = client.update_crypto_key_version version, update_mask

  puts "Enabled version #{version_id} of #{crypto_key_id}"
  # [END kms_enable_cryptokey_version]
end

$disable_crypto_key_version = lambda do |project_id:, key_ring_id:, crypto_key_id:, version_id:, location_id:|
  # [START kms_disable_cryptokey_version]
  # project_id    = "Your Google Cloud project ID"
  # location_id   = "The location of the key ring"
  # key_ring_id   = "The ID of the key ring"
  # crypto_key_id = "The ID of the crypto key"
  # version_id    = "Version of the crypto key"

  require "google/cloud/kms/v1"
  CloudKMS = Google::Cloud::Kms::V1

  # Initialize the client
  client = CloudKMS::KeyManagementServiceClient.new

  # Retrieve the crypto key version to update
  version_path = CloudKMS::KeyManagementServiceClient.crypto_key_version_path(
    project_id, location_id, key_ring_id, crypto_key_id, version_id
  )
  version = client.get_crypto_key_version version_path

  # Set the version state to disabled for update
  version.state = CloudKMS::CryptoKeyVersion::CryptoKeyVersionState::DISABLED
  update_mask = Google::Protobuf::FieldMask.new
  update_mask.paths << "state"

  # Disable the crypto key version
  result = client.update_crypto_key_version version, update_mask

  puts "Disabled version #{version_id} of #{crypto_key_id}"
  # [END kms_disable_cryptokey_version]
end

$restore_crypto_key_version = lambda do |project_id:, location_id:, key_ring_id:, crypto_key_id:, version_id:|
  # [START kms_restore_cryptokey_version]
  # project_id    = "Your Google Cloud project ID"
  # location_id   = "The location of the key ring"
  # key_ring_id   = "The ID of the key ring"
  # crypto_key_id = "The ID of the crypto key"
  # version_id    = "Version of the crypto key"

  require "google/cloud/kms/v1"
  CloudKMS = Google::Cloud::Kms::V1

  # Initialize the client
  client = CloudKMS::KeyManagementServiceClient.new

  # The crypto key version to restore
  version = CloudKMS::KeyManagementServiceClient.crypto_key_version_path(
    project_id, location_id, key_ring_id, crypto_key_id, version_id
  )

  # Restore the crypto key version
  restored = client.restore_crypto_key_version version

  puts "Restored version #{version_id} of #{crypto_key_id}"
  # [END kms_restore_cryptokey_version]
end


$destroy_crypto_key_version = lambda do |project_id:, location_id:, key_ring_id:, crypto_key_id:, version_id:|
  # [START kms_destroy_cryptokey_version]
  # project_id    = "Your Google Cloud project ID"
  # location_id   = "The location of the key ring"
  # key_ring_id   = "The ID of the key ring"
  # crypto_key_id = "The ID of the crypto key"
  # version_id    = "Version of the crypto key"

  require "google/cloud/kms/v1"
  CloudKMS = Google::Cloud::Kms::V1

  # Initialize the client
  client = CloudKMS::KeyManagementServiceClient.new

  # The crypto key version to destroy
  version = CloudKMS::KeyManagementServiceClient.crypto_key_version_path(
    project_id, location_id, key_ring_id, crypto_key_id, version_id
  )

  # Destroy the crypto key version
  destroyed = client.destroy_crypto_key_version version

  puts "Destroyed version #{version_id} of #{crypto_key_id}"
  # [END kms_destroy_cryptokey_version]
end

$add_member_to_key_ring_policy = lambda do |project_id:, location_id:, key_ring_id:, member:, role:|
  # [START kms_add_member_to_keyring_policy]
  # project_id  = "Your Google Cloud project ID"
  # location_id = "The location of the key ring"
  # key_ring_id = "The ID of the key ring"
  # member      = "Member to add to the key ring policy"
  # role        = "Role assignment for new member"

  require "google/cloud/kms/v1"
  CloudKMS = Google::Cloud::Kms::V1

  # Initialize the client
  client = CloudKMS::KeyManagementServiceClient.new

  # The key ring to use
  key_ring =
    CloudKMS::KeyManagementServiceClient.key_ring_path project_id, location_id, key_ring_id

  # Get the current IAM policy
  policy = client.get_iam_policy key_ring

  # Add new member to current bindings
  policy.bindings ||= []
  policy.bindings << Google::Iam::V1::Binding.new(members: [member], role: role)

  # Update IAM policy
  client.set_iam_policy key_ring, policy

  puts "Member #{member} added to policy for " +
       "key ring #{key_ring_id}"
  # [END kms_add_member_to_keyring_policy]
end

$add_member_to_crypto_key_policy = lambda do |project_id:, location_id:, key_ring_id:, crypto_key_id:, member:, role:|
  # [START kms_add_member_to_cryptokey_policy]
  # project_id    = "Your Google Cloud project ID"
  # location_id   = "The location of the key ring"
  # key_ring_id   = "The ID of the key ring"
  # crypto_key_id = "The ID of the crypto key"
  # member        = "Member to add to the crypto key policy"
  # role          = "Role assignment for new member"

  require "google/cloud/kms/v1"
  CloudKMS = Google::Cloud::Kms::V1

  # Initialize the client
  client = CloudKMS::KeyManagementServiceClient.new

  # The CryptoKey to use
  crypto_key = CloudKMS::KeyManagementServiceClient.crypto_key_path(
    project_id, location_id, key_ring_id, crypto_key_id
  )

  # Get the current IAM policy
  policy = client.get_iam_policy crypto_key

  # Add new member to current bindings
  policy.bindings ||= []
  policy.bindings << Google::Iam::V1::Binding.new(members: [member], role: role)

  # Update IAM policy
  client.set_iam_policy crypto_key, policy

  puts "Member #{member} added to policy for " +
       "crypto key #{crypto_key_id} in key ring #{key_ring_id}"
  # [END kms_add_member_to_cryptokey_policy]
end

$remove_member_from_crypto_key_policy = lambda do |project_id:, location_id:, key_ring_id:, crypto_key_id:, member:, role:|
  # [START kms_remove_member_from_cryptokey_policy]
  # project_id    = "Your Google Cloud project ID"
  # location_id   = "The location of the key ring"
  # key_ring_id   = "The ID of the key ring"
  # crypto_key_id = "The ID of the crypto key"
  # member        = "Member to remove to the crypto key policy"
  # role          = "Role assignment for the member"

  require "google/cloud/kms/v1"
  CloudKMS = Google::Cloud::Kms::V1

  # Initialize the client
  client = CloudKMS::KeyManagementServiceClient.new

  # The CryptoKey to use
  crypto_key = CloudKMS::KeyManagementServiceClient.crypto_key_path(
    project_id, location_id, key_ring_id, crypto_key_id
  )

  # Get the current IAM policy
  policy = client.get_iam_policy crypto_key

  # Remove a member from current bindings
  policy.bindings.each do |binding|
    if binding.role == role
      binding.members.delete member
    end
  end

  # Update IAM policy
  client.set_iam_policy crypto_key, policy

  puts "Member #{member} removed from policy for " +
       "crypto key #{crypto_key_id} in key ring #{key_ring_id}"
  # [END kms_remove_member_from_cryptokey_policy]
end

$get_key_ring_policy = lambda do |project_id:, key_ring_id:, location_id:|
  # [START kms_get_keyring_policy]
  # project_id  = "Your Google Cloud project ID"
  # location_id = "The location of the key ring"
  # key_ring_id = "The ID of the key ring"

  require "google/cloud/kms/v1"
  CloudKMS = Google::Cloud::Kms::V1

  # Initialize the client
  client = CloudKMS::KeyManagementServiceClient.new

  # The key ring to use
  key_ring =
    CloudKMS::KeyManagementServiceClient.key_ring_path project_id, location_id, key_ring_id

  # Get the current IAM policy
  policy = client.get_iam_policy key_ring

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
      project_id:  project_id,
      location_id: arguments.shift,
      key_ring_id: arguments.shift
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
      project_id:      project_id,
      location_id:     arguments.shift,
      key_ring_id:     arguments.shift,
      crypto_key_id:   arguments.shift,
      plaintext_file:  arguments.shift,
      ciphertext_file: arguments.shift
    )
  when "decrypt_file"
    $decrypt.call(
      project_id:      project_id,
      location_id:     arguments.shift,
      key_ring_id:     arguments.shift,
      crypto_key_id:   arguments.shift,
      ciphertext_file: arguments.shift,
      plaintext_file:  arguments.shift
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
      location_id:   arguments.shift,
      key_ring_id:   arguments.shift,
      crypto_key_id: arguments.shift,
      version_id:    arguments.shift
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
      project_id:  project_id,
      location_id: arguments.shift,
      key_ring_id: arguments.shift,
      member:      arguments.shift,
      role:        arguments.shift
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
      project_id:  project_id,
      location_id: arguments.shift,
      key_ring_id: arguments.shift
    )
  else
    puts <<~USAGE
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
    USAGE
  end
end

if $PROGRAM_NAME == __FILE__
  run_sample ARGV
end
