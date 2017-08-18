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
require "google/apis/cloudkms_v1"
require_relative "../kms"

describe "Key Management Service" do

  def create_service_client
    kms_client = Google::Apis::CloudkmsV1::CloudKMSService.new
    kms_client.authorization = Google::Auth.get_application_default(
      "https://www.googleapis.com/auth/cloud-platform"
    )
    kms_client
  end

  def create_test_key_ring project_id:, location_id:, key_ring_id:
    kms_client = create_service_client

    resource = "projects/#{project_id}/locations/#{location_id}"

    kms_client.create_project_location_key_ring(
      resource,
      Google::Apis::CloudkmsV1::KeyRing.new,
      key_ring_id: key_ring_id
    )
  end

  def get_test_key_ring project_id:, location_id:, key_ring_id:
    kms_client = create_service_client

    resource = "projects/#{project_id}/locations/#{location_id}/" +
               "keyRings/#{key_ring_id}"

    kms_client.get_project_location_key_ring resource
  end

  def create_test_crypto_key project_id:, location_id:, key_ring_id:, crypto_key:
    kms_client = create_service_client

    resource = "projects/#{project_id}/locations/#{location_id}/" +
               "keyRings/#{key_ring_id}"

    kms_client.create_project_location_key_ring_crypto_key(
      resource,
      Google::Apis::CloudkmsV1::CryptoKey.new(
        purpose: "ENCRYPT_DECRYPT"
      ),
      crypto_key_id: crypto_key
    )
  end

  def create_test_crypto_key_version project_id:, location_id:, key_ring_id:, crypto_key:
    kms_client = create_service_client

    resource = "projects/#{project_id}/locations/#{location_id}/" +
               "keyRings/#{key_ring_id}/cryptoKeys/#{crypto_key}"

    crypto_key_version = kms_client.create_project_location_key_ring_crypto_key_crypto_key_version(
        resource,
        Cloudkms::CryptoKey.new(purpose: "ENCRYPT_DECRYPT")
    )
  end

  def destroy_test_crypto_key_version project_id:, location_id:, key_ring_id:, crypto_key:, version:
    kms_client = create_service_client

    # The resource name of the location associated with the key ring
    resource = "projects/#{project_id}/locations/#{location_id}/" +
               "keyRings/#{key_ring_id}/cryptoKeys/#{crypto_key}/" +
               "cryptoKeyVersions/#{version}"

    # Destroy specific version of the crypto key
    kms_client.destroy_crypto_key_version(
      resource,
      Cloudkms::DestroyCryptoKeyVersionRequest.new
    )
  end

  def disable_test_crypto_key_version project_id:, location_id:, key_ring_id:, crypto_key:, version:
    kms_client = create_service_client

    resource = "projects/#{project_id}/locations/#{location_id}/" +
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
  end

  def get_test_crypto_key project_id:, location_id:, key_ring_id:, crypto_key:
    kms_client = create_service_client

    resource = "projects/#{project_id}/locations/#{location_id}/" +
               "keyRings/#{key_ring_id}/cryptoKeys/#{crypto_key}"

    kms_client.get_project_location_key_ring_crypto_key resource
  end

  def get_test_crypto_key_version project_id:, location_id:, key_ring_id:, crypto_key:, version:

    kms_client = create_service_client

    name = "projects/#{project_id}/locations/#{location_id}/" +
           "keyRings/#{key_ring_id}/cryptoKeys/#{crypto_key}/" +
           "cryptoKeyVersions/#{version}"

    kms_client.get_project_location_key_ring_crypto_key_crypto_key_version name
  end

  def list_test_crypto_key_version project_id:, location_id:, key_ring_id:, crypto_key:
    kms_client = create_service_client

    resource = "projects/#{project_id}/locations/#{location_id}/" +
               "keyRings/#{key_ring_id}/cryptoKeys/#{crypto_key}"

    kms_client.list_project_location_key_ring_crypto_key_crypto_key_versions(
        resource
    )
  end

  def list_test_key_rings project_id:, location_id:
    kms_client = create_service_client

    resource = "projects/#{project_id}/locations/#{location_id}"

    kms_client.list_project_location_key_rings resource
  end

  def get_test_crypto_key_policy project_id:, location_id:, key_ring_id:, crypto_key:
    kms_client = create_service_client

    resource = "projects/#{project_id}/locations/#{location_id}/" +
               "keyRings/#{key_ring_id}/cryptoKeys/#{crypto_key}"

    kms_client.get_project_location_key_ring_crypto_key_iam_policy resource
  end

  def get_test_key_ring_policy project_id:, location_id:, key_ring_id:
    kms_client = create_service_client

    resource = "projects/#{project_id}/locations/#{location_id}/" +
               "keyRings/#{key_ring_id}"

    kms_client.get_project_location_key_ring_iam_policy resource
  end

  def add_test_member_to_crypto_key_policy project_id:, location_id:, key_ring_id:, crypto_key:, member:, role:
    kms_client = create_service_client

    resource = "projects/#{project_id}/locations/#{location_id}/" +
               "keyRings/#{key_ring_id}/cryptoKeys/#{crypto_key}"

    policy = kms_client.get_project_location_key_ring_crypto_key_iam_policy resource

    policy.bindings ||= []
    policy.bindings << Google::Apis::CloudkmsV1::Binding.new(
      members: [member],
      role: role
    )

    policy_request = Google::Apis::CloudkmsV1::SetIamPolicyRequest.new(
      policy: policy
    )

    kms_client.set_crypto_key_iam_policy resource, policy_request
  end

  def add_test_member_to_key_ring_policy project_id:, location_id:, key_ring_id:, member:, role:
    kms_client = create_service_client

    policy = get_test_key_ring_policy(
      project_id: project_id,
      location_id: location_id,
      key_ring_id: key_ring_id
    )

    resource = "projects/#{project_id}/locations/#{location_id}/" +
               "keyRings/#{key_ring_id}"


    policy.bindings ||= []
    policy.bindings << Google::Apis::CloudkmsV1::Binding.new(
      members: [member],
      role: role
    )

    policy_request = Google::Apis::CloudkmsV1::SetIamPolicyRequest.new(
      policy: policy
    )

    kms_client.set_key_ring_iam_policy resource, policy_request
  end

  def remove_test_member_to_key_ring_policy project_id:, location_id:, key_ring_id:, member:, role:
    kms_client = create_service_client

    policy = get_test_key_ring_policy(
      project_id: project_id,
      location_id: location_id,
      key_ring_id: key_ring_id
    )

    resource = "projects/#{project_id}/locations/#{location_id}/" +
               "keyRings/#{key_ring_id}"

    if policy.bindings
      policy.bindings.delete_if do |binding|
        binding.role.include?(role) && binding.members.include?(member)
      end
    end

    policy_request = Google::Apis::CloudkmsV1::SetIamPolicyRequest.new(
      policy: policy
    )

    kms_client.set_key_ring_iam_policy resource, policy_request
  end

  def encrypt_test_file project_id:, location_id:, key_ring_id:, crypto_key:, input_file:, output_file:
    kms_client = create_service_client

    name = "projects/#{project_id}/locations/#{location_id}/" +
           "keyRings/#{key_ring_id}/cryptoKeys/#{crypto_key}"

    plain_text = File.read input_file

    request = Google::Apis::CloudkmsV1::EncryptRequest.new(
      plaintext: plain_text
    )

    response = kms_client.encrypt_crypto_key name, request

    File.write output_file, response.ciphertext
  end

  def decrypt_test_file project_id:, location_id:, key_ring_id:, crypto_key:, input_file:, output_file:
    kms_client = create_service_client

    name = "projects/#{project_id}/locations/#{location_id}/" +
           "keyRings/#{key_ring_id}/cryptoKeys/#{crypto_key}"

    encrypted_text = File.read input_file

    request = Google::Apis::CloudkmsV1::DecryptRequest.new(
      ciphertext: encrypted_text
    )

    response = kms_client.decrypt_crypto_key name, request

    File.write output_file, response.plaintext
  end

  before :all do
    @project_id    = ENV["GOOGLE_CLOUD_PROJECT"]
    @location_id   = "global"
    @key_ring_id   = "#{@project_id}_key_ring_#{Time.now.to_i}"
    @crypto_key_id = "#{@project_id}_crypto_key_#{Time.now.to_i}"

    @test_key_ring = create_test_key_ring project_id: @project_id,
        location_id: @location_id, key_ring_id: @key_ring_id

    @test_crypto_key = create_test_crypto_key project_id: @project_id,
        location_id: @location_id, key_ring_id: @key_ring_id,
        crypto_key: @crypto_key_id

    @input_file = File.expand_path "resources/file.txt", __dir__

    # Note: All samples define a `Cloudkms` constant and cause
    #       "already initialized constant" warnings. $VERBOSE is disabled to
    #       silence these warnings.
    $VERBOSE = nil
  end

  it "can create key ring" do
    key_ring_id = "#{@project_id}-create-#{Time.now.to_i}"

    expect {
      $create_key_ring.call(
        project_id: @project_id,
        location_id: @location_id,
        key_ring_id: key_ring_id
      )
    }.to output(/#{key_ring_id}/).to_stdout

    test_key_ring = get_test_key_ring(
      project_id: @project_id,
      location_id: @location_id,
      key_ring_id: key_ring_id
    )

    expect(test_key_ring.name).to match /#{key_ring_id}/
  end

  it "can create a crypto key" do
    test_crypto_key_id = "#{@project_id}-crypto-#{Time.now.to_i}"

    expect {
      $create_crypto_key.call(
        project_id: @project_id,
        location_id: @location_id,
        key_ring_id: @key_ring_id,
        crypto_key: test_crypto_key_id
      )
    }.to output(/#{test_crypto_key_id}/).to_stdout

    test_crypto_key = get_test_crypto_key(
      project_id: @project_id,
      location_id: @location_id,
      key_ring_id: @key_ring_id,
      crypto_key: test_crypto_key_id
    )

    expect(test_crypto_key.name).to match /#{test_crypto_key_id}/
  end

  it "can encrypt a file" do
    temp_output = Tempfile.new "kms_encrypted_file"

    expect {
      $encrypt.call(
        project_id: @project_id,
        location_id: @location_id,
        key_ring_id: @key_ring_id,
        crypto_key: @crypto_key_id,
        input_file: @input_file,
        output_file: temp_output.path
      )
    }.to output(/#{@input_file}/).to_stdout

    decrypt_test_file(
      project_id: @project_id,
      location_id: @location_id,
      key_ring_id: @key_ring_id,
      crypto_key: @crypto_key_id,
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
      location_id: @location_id,
      key_ring_id: @key_ring_id,
      crypto_key: @crypto_key_id,
      input_file: @input_file,
      output_file: temp_output.path
    )

    expect {
      $decrypt.call(
        project_id: @project_id,
        location_id: @location_id,
        key_ring_id: @key_ring_id,
        crypto_key: @crypto_key_id,
        input_file: temp_output.path,
        output_file: temp_output.path
      )
    }.to output(/#{temp_output.path}/).to_stdout

    decrypted_file = File.read temp_output.path

    expect(decrypted_file).to match /Some information/
  end

  it "can create a crypto key version" do
    test_crypto_key_id = "#{@project_id}-version-#{Time.now.to_i}"

    create_test_crypto_key(
      project_id: @project_id,
      location_id: @location_id,
      key_ring_id: @key_ring_id,
      crypto_key: test_crypto_key_id
    )

    before_version_list = list_test_crypto_key_version(
      project_id: @project_id,
      location_id: @location_id,
      key_ring_id: @key_ring_id,
      crypto_key: test_crypto_key_id
    )

    expect {
      $create_crypto_key_version.call(
        project_id: @project_id,
        location_id: @location_id,
        key_ring_id: @key_ring_id,
        crypto_key: test_crypto_key_id
      )
    }.to output(/Created version/).to_stdout

    after_version_list = list_test_crypto_key_version(
      project_id: @project_id,
      location_id: @location_id,
      key_ring_id: @key_ring_id,
      crypto_key: test_crypto_key_id
    )

    expect(after_version_list.total_size).to be > before_version_list.total_size
  end

  it "can set a crypto key version as the primary version" do
    test_crypto_key_id = "#{@project_id}-primary-#{Time.now.to_i}"

    create_test_crypto_key(
      project_id: @project_id,
      location_id: @location_id,
      key_ring_id: @key_ring_id,
      crypto_key: test_crypto_key_id
    )

    crypto_key_version = create_test_crypto_key_version(
      project_id: @project_id,
      location_id: @location_id,
      key_ring_id: @key_ring_id,
      crypto_key: test_crypto_key_id
    )

    version = crypto_key_version.name.split("/").last

    expect {
      $set_crypto_key_primary_version.call(
        project_id: @project_id,
        location_id: @location_id,
        key_ring_id: @key_ring_id,
        crypto_key: test_crypto_key_id,
        version: version
      )
    }.to output(/Set #{version} as primary version/).to_stdout

    crypto_key = get_test_crypto_key(
      project_id: @project_id,
      location_id: @location_id,
      key_ring_id: @key_ring_id,
      crypto_key: test_crypto_key_id
    )

    expect(crypto_key.primary.name).to eq crypto_key_version.name
  end

  it "can enable a crypto key version" do
    test_crypto_key_id = "#{@project_id}-enable-#{Time.now.to_i}"

    crypto_key = create_test_crypto_key(
      project_id: @project_id,
      location_id: @location_id,
      key_ring_id: @key_ring_id,
      crypto_key: test_crypto_key_id
    )

    version = "1" # first version is labeled 1

    disabled_crypto_key_version = disable_test_crypto_key_version(
      project_id: @project_id,
      location_id: @location_id,
      key_ring_id: @key_ring_id,
      crypto_key: test_crypto_key_id,
      version: version
    )

    expect(disabled_crypto_key_version.state).to eq "DISABLED"

    expect {
      $enable_crypto_key_version.call(
        project_id: @project_id,
        location_id: @location_id,
        key_ring_id: @key_ring_id,
        crypto_key: test_crypto_key_id,
        version: version
      )
    }.to output(/Enabled version #{version} of #{test_crypto_key_id}/).to_stdout

    crypto_key = get_test_crypto_key_version(
      project_id: @project_id,
      location_id: @location_id,
      key_ring_id: @key_ring_id,
      crypto_key: test_crypto_key_id,
      version: version
    )

    expect(crypto_key.state).to eq "ENABLED"
  end

  it "can disable a crypto key version" do
    test_crypto_key_id = "#{@project_id}-disable-#{Time.now.to_i}"

    crypto_key = create_test_crypto_key(
      project_id: @project_id,
      location_id: @location_id,
      key_ring_id: @key_ring_id,
      crypto_key: test_crypto_key_id
    )

    version = "1" # first version is labeled 1

    expect {
      $disable_crypto_key_version.call(
        project_id: @project_id,
        location_id: @location_id,
        key_ring_id: @key_ring_id,
        crypto_key: test_crypto_key_id,
        version: version
      )
    }.to output(/Disabled version #{version} of #{test_crypto_key_id}/).to_stdout

    crypto_key = get_test_crypto_key_version(
      project_id: @project_id,
      location_id: @location_id,
      key_ring_id: @key_ring_id,
      crypto_key: test_crypto_key_id,
      version: version
    )

    expect(crypto_key.state).to eq "DISABLED"
  end

  it "can restore a crypto key version" do
    test_crypto_key_id = "#{@project_id}-restore-#{Time.now.to_i}"

    crypto_key = create_test_crypto_key(
      project_id: @project_id,
      location_id: @location_id,
      key_ring_id: @key_ring_id,
      crypto_key: test_crypto_key_id
    )

    version = "1" # first version is labeled 1

    scheduled_crypto_key_version = destroy_test_crypto_key_version(
      project_id: @project_id,
      location_id: @location_id,
      key_ring_id: @key_ring_id,
      crypto_key: test_crypto_key_id,
      version: version
    )

    expect(scheduled_crypto_key_version.state).to eq "DESTROY_SCHEDULED"

    expect {
      $restore_crypto_key_version.call(
        project_id: @project_id,
        location_id: @location_id,
        key_ring_id: @key_ring_id,
        crypto_key: test_crypto_key_id,
        version: version
      )
    }.to output(/Restored version #{version} of #{test_crypto_key_id}/).to_stdout

    crypto_key = get_test_crypto_key_version(
      project_id: @project_id,
      location_id: @location_id,
      key_ring_id: @key_ring_id,
      crypto_key: test_crypto_key_id,
      version: version
    )

    expect(crypto_key.state).to eq "DISABLED"
  end

  it "can destroy a crypto key version" do
    test_crypto_key_id = "#{@project_id}-destroy-#{Time.now.to_i}"

    crypto_key = create_test_crypto_key(
      project_id: @project_id,
      location_id: @location_id,
      key_ring_id: @key_ring_id,
      crypto_key: test_crypto_key_id
    )

    version = "1" # first version is labeled 1

    expect {
      $destroy_crypto_key_version.call(
        project_id: @project_id,
        location_id: @location_id,
        key_ring_id: @key_ring_id,
        crypto_key: test_crypto_key_id,
        version: version
      )
    }.to output(/Destroyed version #{version} of #{test_crypto_key_id}/).to_stdout

    crypto_key = get_test_crypto_key_version(
      project_id: @project_id,
      location_id: @location_id,
      key_ring_id: @key_ring_id,
      crypto_key: test_crypto_key_id,
      version: version
    )

    expect(crypto_key.state).to eq "DESTROY_SCHEDULED"
  end

  it "can add a member to a crypto key policy" do
    expect {
      $add_member_to_crypto_key_policy.call(
        project_id: @project_id,
        location_id: @location_id,
        key_ring_id: @key_ring_id,
        crypto_key: @crypto_key_id,
        member: "user:test@test.com",
        role: "roles/owner"
      )
    }.to output(/test@test.com/).to_stdout

    policy = get_test_crypto_key_policy(
      project_id: @project_id,
      location_id: @location_id,
      key_ring_id: @key_ring_id,
      crypto_key: @crypto_key_id
    )

    members = policy.bindings.map(&:members).flatten

    expect(members).to include("user:test@test.com")
  end

  it "can remove a member to a crypto key policy" do
    test_crypto_key_id = "#{@project_id}-remove-member-#{Time.now.to_i}"

    create_test_crypto_key(
      project_id: @project_id,
      location_id: @location_id,
      key_ring_id: @key_ring_id,
      crypto_key: test_crypto_key_id
    )

    add_test_member_to_crypto_key_policy(
      project_id: @project_id,
      location_id: @location_id,
      key_ring_id: @key_ring_id,
      crypto_key: test_crypto_key_id,
      member: "user:test@test.com",
      role: "roles/owner"
    )

    policy = get_test_crypto_key_policy(
      project_id: @project_id,
      location_id: @location_id,
      key_ring_id: @key_ring_id,
      crypto_key: test_crypto_key_id
    )

    expect(policy.bindings).to_not be nil

    expect {
      $remove_member_from_crypto_key_policy.call(
        project_id: @project_id,
        location_id: @location_id,
        key_ring_id: @key_ring_id,
        crypto_key: test_crypto_key_id,
        member: "user:test@test.com",
        role: "roles/owner"
      )
    }.to output(/test@test.com/).to_stdout

    policy = get_test_crypto_key_policy(
      project_id: @project_id,
      location_id: @location_id,
      key_ring_id: @key_ring_id,
      crypto_key: test_crypto_key_id
    )

    if policy.bindings
      members = policy.bindings.map(&:members).flatten

      expect(members).to_not include("test@test.com")
    end
  end

  it "can add a member to a key ring policy" do
    remove_test_member_to_key_ring_policy(
      project_id: @project_id,
      location_id: @location_id,
      key_ring_id: @key_ring_id,
      member: "serviceAccount:test-account@#{@project_id}.iam.gserviceaccount.com",
      role: "roles/owner"
    )

    policy = get_test_key_ring_policy(
      project_id: @project_id,
      location_id: @location_id,
      key_ring_id: @key_ring_id
    )

    if policy.bindings
      members = policy.bindings.map(&:members).flatten

      expect(members).to_not include("serviceAccount:test-account@#{@project_id}.iam.gserviceaccount.com")
    end

    expect {
      $add_member_to_key_ring_policy.call(
        project_id: @project_id,
        location_id: @location_id,
        key_ring_id: @key_ring_id,
        member: "serviceAccount:test-account@#{@project_id}.iam.gserviceaccount.com",
        role: "roles/owner"
      )
    }.to output(/serviceAccount:test-account@#{@project_id}.iam.gserviceaccount.com/).to_stdout

    policy = get_test_key_ring_policy(
      project_id: @project_id,
      location_id: @location_id,
      key_ring_id: @key_ring_id
    )

    members = policy.bindings.map(&:members).flatten

    expect(members).to include("serviceAccount:test-account@#{@project_id}.iam.gserviceaccount.com")
  end

  it "can get a key ring policy" do
    add_test_member_to_key_ring_policy(
      project_id: @project_id,
      location_id: @location_id,
      key_ring_id: @key_ring_id,
      member: "serviceAccount:test-account@#{@project_id}.iam.gserviceaccount.com",
      role: "roles/owner"
    )

    expect {
      $get_key_ring_policy.call(
        project_id: @project_id,
        location_id: @location_id,
        key_ring_id: @key_ring_id
      )
    }.to output(/serviceAccount:test-account@#{@project_id}.iam.gserviceaccount.com/).to_stdout
  end
end

