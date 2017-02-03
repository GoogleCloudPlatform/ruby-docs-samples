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
require "tempfile"
require "google/apis/cloudkms_v1beta1"
require_relative "../kms"

describe "Key Management Service" do

  def create_service_client
    kms_client = Google::Apis::CloudkmsV1beta1::CloudKMSService.new
    kms_client.authorization = Google::Auth.get_application_default(
      "https://www.googleapis.com/auth/cloud-platform"
    )
    kms_client
  end

  def test_create_keyring project_id:, key_ring_id:, location:
    kms_client = create_service_client

    parent = "projects/#{project_id}/locations/#{location}"

    kms_client.create_project_location_key_ring(parent,
      Google::Apis::CloudkmsV1beta1::KeyRing.new, key_ring_id: key_ring_id)
  end

  def test_get_keyring project_id:, key_ring_id:, location:
    kms_client = create_service_client

    parent = "projects/#{project_id}/locations/#{location}/" +
        "keyRings/#{key_ring_id}"

    kms_client.get_project_location_key_ring parent
  end

  def test_create_cryptokey project_id:, key_ring_id:, crypto_key:, location:
    kms_client = create_service_client

    parent = "projects/#{project_id}/locations/#{location}/" +
        "keyRings/#{key_ring_id}"

    crypto_key_skeleton = Google::Apis::CloudkmsV1beta1::CryptoKey.new(
        purpose: "ENCRYPT_DECRYPT")
    crypto_key = kms_client.create_project_location_key_ring_crypto_key(parent,
        crypto_key_skeleton, crypto_key_id: crypto_key)
  end

  def test_get_cryptokey project_id:, key_ring_id:, crypto_key:, location:
    kms_client = create_service_client

    parent = "projects/#{project_id}/locations/#{location}/" +
        "keyRings/#{key_ring_id}/cryptoKeys/#{crypto_key}"

    kms_client.get_project_location_key_ring_crypto_key parent
  end

  def test_get_cryptokey_version(project_id:, key_ring_id:, crypto_key:,
      version:, location:)

    kms_client = create_service_client

    name = "projects/#{project_id}/locations/#{location}/" +
         "keyRings/#{key_ring_id}/cryptoKeys/#{crypto_key}/" +
         "cryptoKeyVersions/#{version}"

    kms_client.get_project_location_key_ring_crypto_key_crypto_key_version name
  end

  def test_list_cryptokey_version(project_id:, key_ring_id:, crypto_key:,
      location:)
    kms_client = create_service_client

    parent = "projects/#{project_id}/locations/#{location}/" +
        "keyRings/#{key_ring_id}/cryptoKeys/#{crypto_key}"

    kms_client.list_project_location_key_ring_crypto_key_crypto_key_versions(
        parent)
  end

  def test_get_cryptokey_policy(project_id:, key_ring_id:, crypto_key:,
      location:)
    kms_client = create_service_client

    parent = "projects/#{project_id}/locations/#{location}/" +
      "keyRings/#{key_ring_id}/cryptoKeys/#{crypto_key}"

    kms_client.get_project_location_key_ring_crypto_key_iam_policy parent
  end

  def test_encrypt_file(project_id:, key_ring_id:, crypto_key:, location:,
      input_file:, output_file:)
    kms_client = create_service_client

    name = "projects/#{project_id}/locations/#{location}/" +
      "keyRings/#{key_ring_id}/cryptoKeys/#{crypto_key}"

    encoded_file = Base64.encode64 File.read(input_file)

    request = Google::Apis::CloudkmsV1beta1::EncryptRequest.new
    request.plaintext = encoded_file

    response = kms_client.encrypt_crypto_key name, request

    File.open(output_file, "w") do |file|
      file.write response.ciphertext
    end
  end

  def test_decrypt_file(project_id:, key_ring_id:, crypto_key:, location:,
      input_file:, output_file:)
    kms_client = create_service_client

    name = "projects/#{project_id}/locations/#{location}/" +
      "keyRings/#{key_ring_id}/cryptoKeys/#{crypto_key}"

    encoded_file = File.read(input_file)

    request = Google::Apis::CloudkmsV1beta1::DecryptRequest.new(
      ciphertext: encoded_file)

    response = kms_client.decrypt_crypto_key name, request

    File.open(output_file, "w") do |file|
      decoded_file = Base64.decode64 response.plaintext
      file.write decoded_file
    end
  end

  before :all do
    @project_id = ENV["GOOGLE_CLOUD_PROJECT"]
    @key_ring_id = "#{@project_id}-key-ring-#{Time.now.to_i}"
    @cryptokey_id = "#{@project_id}-cryptokey-#{Time.now.to_i}"
    @location = "global"

    @test_key_ring = test_create_keyring project_id: @project_id,
        key_ring_id: @key_ring_id, location: @location
    @test_cryptokey = test_create_cryptokey project_id: @project_id,
        key_ring_id: @key_ring_id, crypto_key: @cryptokey_id, location: @location

    @input_file = File.expand_path "resources/file.txt", __dir__
  end

  it "can create keyring" do
    test_create_key_ring_id = "#{@project_id}-create-#{Time.now.to_i}"

    expect {
      create_keyring(project_id: @project_id,
          key_ring_id: test_create_key_ring_id,
          location: @location)
    }.to output(/#{test_create_key_ring_id}/).to_stdout

    test_key_ring = test_get_keyring(project_id: @project_id,
        key_ring_id: test_create_key_ring_id, location: @location)

    expect(test_key_ring.name).to match /#{test_create_key_ring_id}/
  end

  it "can create a cryptoKey" do
    test_cryptokey_id = "#{@project_id}-crypto-#{Time.now.to_i}"

    expect {
      create_cryptokey(project_id: @project_id, key_ring_id: @key_ring_id,
          crypto_key: test_cryptokey_id, location: @location)
    }.to output(/#{test_cryptokey_id}/).to_stdout

    test_crypto_key = test_get_cryptokey(project_id: @project_id,
        key_ring_id: @key_ring_id, crypto_key: test_cryptokey_id,
        location: @location)

    expect(test_crypto_key.name).to match /#{test_cryptokey_id}/
  end

  it "can encrypt a file" do
    temp_output = Tempfile.new "kms_encrypted_file"

    expect {
      encrypt(project_id: @project_id, key_ring_id: @key_ring_id,
          crypto_key: @cryptokey_id, location: @location,
          input_file: @input_file, output_file: temp_output)
    }.to output(/#{@input_file}/).to_stdout

    test_decrypt_file(project_id: @project_id, key_ring_id: @key_ring_id,
          crypto_key: @cryptokey_id, location: @location,
          input_file: temp_output.path, output_file: temp_output.path)

    decrypted_file = File.read temp_output.path

    expect(decrypted_file).to eq "Some information"
  end

  it "can decrypt an encrypted file" do
    temp_output = Tempfile.new "kms_encrypted_file"

    test_encrypt_file(project_id: @project_id, key_ring_id: @key_ring_id,
        crypto_key: @cryptokey_id, location: @location,
        input_file: @input_file, output_file: temp_output.path)

    expect {
      decrypt(project_id: @project_id, key_ring_id: @key_ring_id,
          crypto_key: @cryptokey_id, location: @location,
          input_file: temp_output.path, output_file: temp_output.path)
    }.to output(/#{temp_output.path}/).to_stdout

    decrypted_file = File.read temp_output.path

    expect(decrypted_file).to eq "Some information"
  end

  it "can create a cryptoKey version" do
    test_cryptokey_id = "#{@project_id}-version-#{Time.now.to_i}"

    test_create_cryptokey(project_id: @project_id,
        key_ring_id: @key_ring_id, crypto_key: test_cryptokey_id,
        location: @location)

    before_version_list = test_list_cryptokey_version(project_id: @project_id,
        key_ring_id: @key_ring_id, crypto_key: test_cryptokey_id,
        location: @location)

    expect {
      create_cryptokey_version(project_id: @project_id,
         key_ring_id: @key_ring_id, crypto_key: test_cryptokey_id,
         location: @location)
    }.to output(/Created version/).to_stdout

    after_version_list = test_list_cryptokey_version(project_id: @project_id,
        key_ring_id: @key_ring_id, crypto_key: test_cryptokey_id,
        location: @location)

    expect(after_version_list.total_size).to be > before_version_list.total_size
  end

  it "can disable a cryptoKey version" do
    test_cryptokey_id = "#{@project_id}-disable-#{Time.now.to_i}"

    cryptokey = test_create_cryptokey(project_id: @project_id,
        key_ring_id: @key_ring_id, crypto_key: test_cryptokey_id,
        location: @location)

    version = "1"

    expect {
      disable_cryptokey_version(project_id: @project_id,
         key_ring_id: @key_ring_id, crypto_key: test_cryptokey_id,
         version: version, location: @location)
    }.to output(/Disabled version #{version} of #{test_cryptokey_id}/).to_stdout

    cryptokey = test_get_cryptokey_version(project_id: @project_id,
        key_ring_id: @key_ring_id, crypto_key: test_cryptokey_id,
        version: version, location: @location)

    expect(cryptokey.state).to eq "DISABLED"
  end

  it "can add a member to a cryptokey policy" do
    expect {
      add_member_to_cryptokey_policy(project_id: @project_id,
          key_ring_id: @key_ring_id, crypto_key: @cryptokey_id,
          member: "user:test@test.com", role: "roles/owner",
          location: @location)
    }.to output(/test@test.com/).to_stdout

    policy = test_get_cryptokey_policy(project_id: @project_id,
          key_ring_id: @key_ring_id, crypto_key: @cryptokey_id,
          location: @location)

    members = policy.bindings.collect(&:members).reduce(:|)

    expect(members).to include("user:test@test.com")
  end
end
