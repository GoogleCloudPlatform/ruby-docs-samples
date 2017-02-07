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

  def create_test_keyring project_id:, key_ring_id:, location:
    kms_client = create_service_client

    resource = "projects/#{project_id}/locations/#{location}"

    kms_client.create_project_location_key_ring(
      resource,
      Google::Apis::CloudkmsV1beta1::KeyRing.new,
      key_ring_id: key_ring_id
    )
  end

  def get_test_keyring project_id:, key_ring_id:, location:
    kms_client = create_service_client

    resource = "projects/#{project_id}/locations/#{location}/" +
               "keyRings/#{key_ring_id}"

    kms_client.get_project_location_key_ring resource
  end

  def create_test_cryptokey project_id:, key_ring_id:, crypto_key:, location:
    kms_client = create_service_client

    resource = "projects/#{project_id}/locations/#{location}/" +
               "keyRings/#{key_ring_id}"

    kms_client.create_project_location_key_ring_crypto_key(
      resource,
      Google::Apis::CloudkmsV1beta1::CryptoKey.new(
        purpose: "ENCRYPT_DECRYPT"
      ),
      crypto_key_id: crypto_key
    )
  end

  def get_test_cryptokey project_id:, key_ring_id:, crypto_key:, location:
    kms_client = create_service_client

    resource = "projects/#{project_id}/locations/#{location}/" +
               "keyRings/#{key_ring_id}/cryptoKeys/#{crypto_key}"

    kms_client.get_project_location_key_ring_crypto_key resource
  end

  def get_test_cryptokey_version project_id:, key_ring_id:, crypto_key:, version:, location:

    kms_client = create_service_client

    name = "projects/#{project_id}/locations/#{location}/" +
           "keyRings/#{key_ring_id}/cryptoKeys/#{crypto_key}/" +
           "cryptoKeyVersions/#{version}"

    kms_client.get_project_location_key_ring_crypto_key_crypto_key_version name
  end

  def test_list_cryptokey_version project_id:, key_ring_id:, crypto_key:, location:
    kms_client = create_service_client

    resource = "projects/#{project_id}/locations/#{location}/" +
               "keyRings/#{key_ring_id}/cryptoKeys/#{crypto_key}"

    kms_client.list_project_location_key_ring_crypto_key_crypto_key_versions(
        resource
    )
  end

  def test_list_key_rings project_id:, location:
    kms_client = create_service_client

    resource = "projects/#{project_id}/locations/#{location}"

    kms_client.list_project_location_key_rings resource
  end

  def get_test_cryptokey_policy project_id:, key_ring_id:, crypto_key:, location:
    kms_client = create_service_client

    resource = "projects/#{project_id}/locations/#{location}/" +
               "keyRings/#{key_ring_id}/cryptoKeys/#{crypto_key}"

    kms_client.get_project_location_key_ring_crypto_key_iam_policy resource
  end

  def get_test_keyring_policy project_id:, key_ring_id:, location:
    kms_client = create_service_client

    resource = "projects/#{project_id}/locations/#{location}/" +
               "keyRings/#{key_ring_id}"

    kms_client.get_project_location_key_ring_iam_policy resource
  end

  def add_test_member_to_cryptokey_policy project_id:, key_ring_id:, crypto_key:, member:, role:, location:
    kms_client = create_service_client

    resource = "projects/#{project_id}/locations/#{location}/" +
               "keyRings/#{key_ring_id}/cryptoKeys/#{crypto_key}"

    policy = kms_client.get_project_location_key_ring_crypto_key_iam_policy resource

    policy.bindings ||= []
    policy.bindings << Google::Apis::CloudkmsV1beta1::Binding.new(
      members: [member],
      role: role
    )

    kms_client.set_crypto_key_iam_policy resource, policy_request
  end

  def add_test_member_to_keyring_policy project_id:, key_ring_id:, member:, role:, location:
    kms_client = create_service_client

    policy = get_test_keyring_policy(
      project_id: project_id,
      key_ring_id: key_ring_id,
      location: location
    )

    resource = "projects/#{project_id}/locations/#{location}/" +
               "keyRings/#{key_ring_id}"


    policy.bindings ||= []
    policy.bindings << Google::Apis::CloudkmsV1beta1::Binding.new(
      members: [member],
      role: role
    )

    policy_request = Google::Apis::CloudkmsV1beta1::SetIamPolicyRequest.new(
      policy: policy
    )

    kms_client.set_key_ring_iam_policy resource, policy_request
  end

  def encrypt_test_file project_id:, key_ring_id:, crypto_key:, location:, input_file:, output_file:
    kms_client = create_service_client

    name = "projects/#{project_id}/locations/#{location}/" +
           "keyRings/#{key_ring_id}/cryptoKeys/#{crypto_key}"

    plain_text = File.read input_file

    request = Google::Apis::CloudkmsV1beta1::EncryptRequest.new(
      plaintext: plain_text
    )

    response = kms_client.encrypt_crypto_key name, request

    File.write output_file, response.ciphertext
  end

  def decrypt_test_file project_id:, key_ring_id:, crypto_key:, location:, input_file:, output_file:
    kms_client = create_service_client

    name = "projects/#{project_id}/locations/#{location}/" +
           "keyRings/#{key_ring_id}/cryptoKeys/#{crypto_key}"

    encrypted_text = File.read input_file

    request = Google::Apis::CloudkmsV1beta1::DecryptRequest.new(
      ciphertext: encrypted_text
    )

    response = kms_client.decrypt_crypto_key name, request

    File.write output_file, response.plaintext
  end

  before :all do
    @project_id   = ENV["GOOGLE_CLOUD_PROJECT"]
    @key_ring_id  = "#{@project_id}_key_ring_#{Time.now.to_i}"
    @cryptokey_id = "#{@project_id}_cryptokey_#{Time.now.to_i}"
    @location     = "global"

    @test_key_ring = create_test_keyring project_id: @project_id,
        key_ring_id: @key_ring_id, location: @location

    @test_cryptokey = create_test_cryptokey project_id: @project_id,
        key_ring_id: @key_ring_id, crypto_key: @cryptokey_id, location: @location

    @input_file = File.expand_path "resources/file.txt", __dir__

    # Note: Code samples set constants, and constants cannot be set inside
    #       method definitions in Ruby. Code snippets in these samples are
    #       wrapped in global lambdas. Code ignores warnings only for this purpose.
    $VERBOSE = nil
  end

  it "can create keyring" do
    key_ring_id = "#{@project_id}-create-#{Time.now.to_i}"

    expect {
      $create_keyring.call(
        project_id: @project_id,
        key_ring_id: key_ring_id,
        location: @location
      )
    }.to output(/#{key_ring_id}/).to_stdout

    test_key_ring = get_test_keyring(
      project_id: @project_id,
      key_ring_id: key_ring_id,
      location: @location
    )

    expect(test_key_ring.name).to match /#{key_ring_id}/
  end

  it "can create a cryptoKey" do
    test_cryptokey_id = "#{@project_id}-crypto-#{Time.now.to_i}"

    expect {
      $create_cryptokey.call(
        project_id: @project_id,
        key_ring_id: @key_ring_id,
        crypto_key: test_cryptokey_id,
        location: @location
      )
    }.to output(/#{test_cryptokey_id}/).to_stdout

    test_crypto_key = get_test_cryptokey(
      project_id: @project_id,
      key_ring_id: @key_ring_id,
      crypto_key: test_cryptokey_id,
      location: @location
    )

    expect(test_crypto_key.name).to match /#{test_cryptokey_id}/
  end

  it "can encrypt a file" do
    temp_output = Tempfile.new "kms_encrypted_file"

    expect {
      $encrypt.call(
        project_id: @project_id,
        key_ring_id: @key_ring_id,
        crypto_key: @cryptokey_id,
        location: @location,
        input_file: @input_file,
        output_file: temp_output.path
      )
    }.to output(/#{@input_file}/).to_stdout

    decrypt_test_file(
      project_id: @project_id,
      key_ring_id: @key_ring_id,
      crypto_key: @cryptokey_id,
      location: @location,
      input_file: temp_output.path,
      output_file: temp_output.path
    )

    decrypted_file = File.read temp_output.path

    expect(decrypted_file).to match /Some information/
  end

  it "can decrypt an encrypted file" do
    temp_output = Tempfile.new "kms_encrypted_file"

    encrypt_test_file(
      project_id: @project_id,
      key_ring_id: @key_ring_id,
      crypto_key: @cryptokey_id,
      location: @location,
      input_file: @input_file,
      output_file: temp_output.path
    )

    expect {
      $decrypt.call(
        project_id: @project_id,
        key_ring_id: @key_ring_id,
        crypto_key: @cryptokey_id,
        location: @location,
        input_file: temp_output.path,
        output_file: temp_output.path
      )
    }.to output(/#{temp_output.path}/).to_stdout

    decrypted_file = File.read temp_output.path

    expect(decrypted_file).to match /Some information/
  end

  it "can create a cryptoKey version" do
    test_cryptokey_id = "#{@project_id}-version-#{Time.now.to_i}"

    create_test_cryptokey(
      project_id: @project_id,
      key_ring_id: @key_ring_id,
      crypto_key: test_cryptokey_id,
      location: @location
    )

    before_version_list = test_list_cryptokey_version(
      project_id: @project_id,
      key_ring_id: @key_ring_id,
      crypto_key: test_cryptokey_id,
      location: @location
    )

    expect {
      $create_cryptokey_version.call(
        project_id: @project_id,
        key_ring_id: @key_ring_id,
        crypto_key: test_cryptokey_id,
        location: @location
      )
    }.to output(/Created version/).to_stdout

    after_version_list = test_list_cryptokey_version(
      project_id: @project_id,
      key_ring_id: @key_ring_id,
      crypto_key: test_cryptokey_id,
      location: @location
    )

    expect(after_version_list.total_size).to be > before_version_list.total_size
  end

  it "can disable a cryptoKey version" do
    test_cryptokey_id = "#{@project_id}-disable-#{Time.now.to_i}"

    cryptokey = create_test_cryptokey(
      project_id: @project_id,
      key_ring_id: @key_ring_id,
      crypto_key: test_cryptokey_id,
      location: @location
    )

    version = "1" # first version is labeled 1

    expect {
      $disable_cryptokey_version.call(
        project_id: @project_id,
        key_ring_id: @key_ring_id,
        crypto_key: test_cryptokey_id,
        version: version,
        location: @location
      )
    }.to output(/Disabled version #{version} of #{test_cryptokey_id}/).to_stdout

    cryptokey = get_test_cryptokey_version(
      project_id: @project_id,
      key_ring_id: @key_ring_id,
      crypto_key: test_cryptokey_id,
      version: version,
      location: @location
    )

    expect(cryptokey.state).to eq "DISABLED"
  end

  it "can destroy a cryptoKey version" do
    test_cryptokey_id = "#{@project_id}-destroy-#{Time.now.to_i}"

    cryptokey = create_test_cryptokey(
      project_id: @project_id,
      key_ring_id: @key_ring_id,
      crypto_key: test_cryptokey_id,
      location: @location
    )

    version = "1" # first version is labeled 1

    expect {
      $destroy_cryptokey_version.call(
        project_id: @project_id,
        key_ring_id: @key_ring_id,
        crypto_key: test_cryptokey_id,
        version: version,
        location: @location
      )
    }.to output(/Destroyed version #{version} of #{test_cryptokey_id}/).to_stdout

    cryptokey = get_test_cryptokey_version(
      project_id: @project_id,
      key_ring_id: @key_ring_id,
      crypto_key: test_cryptokey_id,
      version: version,
      location: @location
    )

    expect(cryptokey.state).to eq "DESTROY_SCHEDULED"
  end

  it "can add a member to a cryptokey policy" do
    expect {
      $add_member_to_cryptokey_policy.call(
        project_id: @project_id,
        key_ring_id: @key_ring_id,
        crypto_key: @cryptokey_id,
        member: "user:test@test.com",
        role: "roles/owner",
        location: @location
      )
    }.to output(/test@test.com/).to_stdout

    policy = get_test_cryptokey_policy(
      project_id: @project_id,
      key_ring_id: @key_ring_id,
      crypto_key: @cryptokey_id,
      location: @location
    )

    members = policy.bindings.map(&:members).flatten

    expect(members).to include("user:test@test.com")
  end

  it "can get a keyring policy" do
    add_test_member_to_keyring_policy(
      project_id: @project_id,
      key_ring_id: @key_ring_id,
      member: "serviceAccount:test-account@#{@project_id}.iam.gserviceaccount.com",
      role: "roles/owner",
      location: @location
    )

    expect {
      $get_keyring_policy.call(
        project_id: @project_id,
        key_ring_id: @key_ring_id,
        location: @location
      )
    }.to output(/serviceAccount:test-account@#{@project_id}.iam.gserviceaccount.com/).to_stdout
  end
end

