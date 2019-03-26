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
require "tempfile"
require "google/cloud/kms/v1"
require_relative "../kms"

RSpec.configure do |config|
  # show retry status in spec process
  config.verbose_retry = true
  # show exception that triggers a retry if verbose_retry is set to true
  config.display_try_failure_messages = true

  # set retry count and retry sleep interval to 10 seconds
  config.default_retry_count = 5
  config.default_sleep_interval = 10
end

describe "Key Management Service" do
  CloudKMS = Google::Cloud::Kms::V1

  def create_test_key_ring project_id:, location_id:, key_ring_id:
    client = CloudKMS::KeyManagementServiceClient.new
    location_path = CloudKMS::KeyManagementServiceClient.location_path project_id, location_id

    client.create_key_ring location_path, key_ring_id, nil
  end

  def get_test_key_ring project_id:, location_id:, key_ring_id:
    client = CloudKMS::KeyManagementServiceClient.new
    key_ring_path = CloudKMS::KeyManagementServiceClient.key_ring_path(
      project_id, location_id, key_ring_id
    )

    client.get_key_ring key_ring_path
  end

  def create_test_crypto_key project_id:, location_id:, key_ring_id:, crypto_key_id:
    client = CloudKMS::KeyManagementServiceClient.new
    key_ring_path = CloudKMS::KeyManagementServiceClient.key_ring_path(
      project_id, location_id, key_ring_id
    )

    crypto_key_spec = CloudKMS::CryptoKey.new
    crypto_key_spec.purpose = CloudKMS::CryptoKey::CryptoKeyPurpose::ENCRYPT_DECRYPT

    client.create_crypto_key key_ring_path, crypto_key_id, crypto_key_spec
  end

  def create_test_crypto_key_version project_id:, location_id:, key_ring_id:, crypto_key_id:
    client = CloudKMS::KeyManagementServiceClient.new
    crypto_key_path = CloudKMS::KeyManagementServiceClient.crypto_key_path(
      project_id, location_id, key_ring_id, crypto_key_id
    )

    client.create_crypto_key_version crypto_key_path, nil
  end

  def destroy_test_crypto_key_version project_id:, location_id:, key_ring_id:, crypto_key_id:, version_id:
    client = CloudKMS::KeyManagementServiceClient.new
    crypto_key_version_path = CloudKMS::KeyManagementServiceClient.crypto_key_version_path(
      project_id, location_id, key_ring_id, crypto_key_id, version_id
    )

    # Destroy specific version of the crypto key
    client.destroy_crypto_key_version crypto_key_version_path
  end

  def disable_test_crypto_key_version project_id:, location_id:, key_ring_id:, crypto_key_id:, version_id:
    client = CloudKMS::KeyManagementServiceClient.new
    crypto_key_version_path = CloudKMS::KeyManagementServiceClient.crypto_key_version_path(
      project_id, location_id, key_ring_id, crypto_key_id, version_id
    )

    version = client.get_crypto_key_version crypto_key_version_path

    # Set the version state to disabled for update
    version.state = CloudKMS::CryptoKeyVersion::CryptoKeyVersionState::DISABLED
    update_mask = Google::Protobuf::FieldMask.new
    update_mask.paths << "state"

    client.update_crypto_key_version version, update_mask
  end

  def get_test_crypto_key project_id:, location_id:, key_ring_id:, crypto_key_id:
    client = CloudKMS::KeyManagementServiceClient.new
    crypto_key_path = CloudKMS::KeyManagementServiceClient.crypto_key_path(
      project_id, location_id, key_ring_id, crypto_key_id
    )

    client.get_crypto_key crypto_key_path
  end

  def get_test_crypto_key_version project_id:, location_id:, key_ring_id:, crypto_key_id:, version_id:
    client = CloudKMS::KeyManagementServiceClient.new
    crypto_key_version_path = CloudKMS::KeyManagementServiceClient.crypto_key_version_path(
      project_id, location_id, key_ring_id, crypto_key_id, version_id
    )

    client.get_crypto_key_version crypto_key_version_path
  end

  def list_test_crypto_key_version project_id:, location_id:, key_ring_id:, crypto_key_id:
    client = CloudKMS::KeyManagementServiceClient.new
    crypto_key_path = CloudKMS::KeyManagementServiceClient.crypto_key_path(
      project_id, location_id, key_ring_id, crypto_key_id
    )

    client.list_crypto_key_versions crypto_key_path
  end

  def list_test_key_rings project_id:, location_id:
    client = CloudKMS::KeyManagementServiceClient.new
    location_path = CloudKMS::KeyManagementServiceClient.location_path project_id, location_id

    client.list_key_rings location_path
  end

  def get_test_crypto_key_policy project_id:, location_id:, key_ring_id:, crypto_key_id:
    client = CloudKMS::KeyManagementServiceClient.new
    crypto_key_path = CloudKMS::KeyManagementServiceClient.crypto_key_path(
      project_id, location_id, key_ring_id, crypto_key_id
    )

    client.get_iam_policy crypto_key_path
  end

  def get_test_key_ring_policy project_id:, location_id:, key_ring_id:
    client = CloudKMS::KeyManagementServiceClient.new
    key_ring_path = CloudKMS::KeyManagementServiceClient.key_ring_path(
      project_id, location_id, key_ring_id
    )

    client.get_iam_policy key_ring_path
  end

  def add_test_member_to_crypto_key_policy project_id:, location_id:, key_ring_id:, crypto_key_id:, member:, role:
    client = CloudKMS::KeyManagementServiceClient.new
    crypto_key_path = CloudKMS::KeyManagementServiceClient.crypto_key_path(
      project_id, location_id, key_ring_id, crypto_key_id
    )

    policy = client.get_iam_policy crypto_key_path

    policy.bindings ||= []
    policy.bindings << Google::Iam::V1::Binding.new(members: [member], role: role)

    client.set_iam_policy crypto_key_path, policy
  end

  def add_test_member_to_key_ring_policy project_id:, location_id:, key_ring_id:, member:, role:
    client = CloudKMS::KeyManagementServiceClient.new
    key_ring_path = CloudKMS::KeyManagementServiceClient.key_ring_path(
      project_id, location_id, key_ring_id
    )

    policy = client.get_iam_policy key_ring_path

    policy.bindings ||= []
    policy.bindings << Google::Iam::V1::Binding.new(members: [member], role: role)

    client.set_iam_policy key_ring_path, policy
  end

  def remove_test_member_to_key_ring_policy project_id:, location_id:, key_ring_id:, member:, role:
    client = CloudKMS::KeyManagementServiceClient.new
    key_ring_path = CloudKMS::KeyManagementServiceClient.key_ring_path(
      project_id, location_id, key_ring_id
    )

    policy = client.get_iam_policy key_ring_path

    policy.bindings&.delete_if do |binding|
      binding.role == role && binding.members.include?(member)
    end

    client.set_iam_policy key_ring_path, policy
  end

  def encrypt_test_file project_id:, location_id:, key_ring_id:, crypto_key_id:, plaintext_file:, ciphertext_file:
    client = CloudKMS::KeyManagementServiceClient.new
    crypto_key_path = CloudKMS::KeyManagementServiceClient.crypto_key_path(
      project_id, location_id, key_ring_id, crypto_key_id
    )

    plaintext = File.open(plaintext_file, "rb", &:read)

    response = client.encrypt crypto_key_path, plaintext

    File.open(ciphertext_file, "wb") { |f| f.write response.ciphertext }
  end

  def decrypt_test_file project_id:, location_id:, key_ring_id:, crypto_key_id:, ciphertext_file:, plaintext_file:
    client = CloudKMS::KeyManagementServiceClient.new
    crypto_key_path = CloudKMS::KeyManagementServiceClient.crypto_key_path(
      project_id, location_id, key_ring_id, crypto_key_id
    )

    ciphertext = File.open(ciphertext_file, "rb", &:read)

    response = client.decrypt crypto_key_path, ciphertext

    File.open(plaintext_file, "wb") { |f| f.write response.plaintext }
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
        crypto_key_id: @crypto_key_id

    @plaintext_file = File.expand_path "resources/file.txt", __dir__

    # Note: All samples define a `CloudKMS` constant and cause
    #       "already initialized constant" warnings. $VERBOSE is disabled to
    #       silence these warnings.
    $VERBOSE = nil
  end

  it "can create key ring" do
    key_ring_id = "#{@project_id}-create-#{Time.now.to_i}"

    expect {
      $create_key_ring.call(
        project_id:  @project_id,
        location_id: @location_id,
        key_ring_id: key_ring_id
      )
    }.to output(/#{key_ring_id}/).to_stdout

    test_key_ring = get_test_key_ring(
      project_id:  @project_id,
      location_id: @location_id,
      key_ring_id: key_ring_id
    )

    expect(test_key_ring.name).to match /#{key_ring_id}/
  end

  it "can create a crypto key" do
    test_crypto_key_id = "#{@project_id}-crypto-#{Time.now.to_i}"

    expect {
      $create_crypto_key.call(
        project_id:    @project_id,
        location_id:   @location_id,
        key_ring_id:   @key_ring_id,
        crypto_key_id: test_crypto_key_id
      )
    }.to output(/#{test_crypto_key_id}/).to_stdout

    test_crypto_key = get_test_crypto_key(
      project_id:    @project_id,
      location_id:   @location_id,
      key_ring_id:   @key_ring_id,
      crypto_key_id: test_crypto_key_id
    )

    expect(test_crypto_key.name).to match /#{test_crypto_key_id}/
  end

  it "can encrypt a file" do
    temp_output = Tempfile.new "kms_encrypted_file"

    expect {
      $encrypt.call(
        project_id:      @project_id,
        location_id:     @location_id,
        key_ring_id:     @key_ring_id,
        crypto_key_id:   @crypto_key_id,
        plaintext_file:  @plaintext_file,
        ciphertext_file: temp_output.path
      )
    }.to output(/#{@plaintext_file}/).to_stdout

    decrypt_test_file(
      project_id:      @project_id,
      location_id:     @location_id,
      key_ring_id:     @key_ring_id,
      crypto_key_id:   @crypto_key_id,
      ciphertext_file: temp_output.path,
      plaintext_file:  temp_output.path
    )

    plaintext = File.read temp_output.path

    expect(plaintext).to match /Some information/
  end

  it "can decrypt an encrypted file" do
    temp_output = Tempfile.new "kms_encrypted_file"

    encrypt_test_file(
      project_id:      @project_id,
      location_id:     @location_id,
      key_ring_id:     @key_ring_id,
      crypto_key_id:   @crypto_key_id,
      plaintext_file:  @plaintext_file,
      ciphertext_file: temp_output.path
    )

    expect {
      $decrypt.call(
        project_id:      @project_id,
        location_id:     @location_id,
        key_ring_id:     @key_ring_id,
        crypto_key_id:   @crypto_key_id,
        ciphertext_file: temp_output.path,
        plaintext_file:  temp_output.path
      )
    }.to output(/#{temp_output.path}/).to_stdout

    plaintext = File.read temp_output.path

    expect(plaintext).to match /Some information/
  end

  it "can create a crypto key version" do
    test_crypto_key_id = "#{@project_id}-version-#{Time.now.to_i}"

    create_test_crypto_key(
      project_id:    @project_id,
      location_id:   @location_id,
      key_ring_id:   @key_ring_id,
      crypto_key_id: test_crypto_key_id
    )

    before_version_list = list_test_crypto_key_version(
      project_id:    @project_id,
      location_id:   @location_id,
      key_ring_id:   @key_ring_id,
      crypto_key_id: test_crypto_key_id
    )

    expect {
      $create_crypto_key_version.call(
        project_id:    @project_id,
        location_id:   @location_id,
        key_ring_id:   @key_ring_id,
        crypto_key_id: test_crypto_key_id
      )
    }.to output(/Created version/).to_stdout

    after_version_list = list_test_crypto_key_version(
      project_id:    @project_id,
      location_id:   @location_id,
      key_ring_id:   @key_ring_id,
      crypto_key_id: test_crypto_key_id
    )

    expect(after_version_list.count).to be > before_version_list.count
  end

  it "can set a crypto key version as the primary version" do
    test_crypto_key_id = "#{@project_id}-primary-#{Time.now.to_i}"

    create_test_crypto_key(
      project_id:    @project_id,
      location_id:   @location_id,
      key_ring_id:   @key_ring_id,
      crypto_key_id: test_crypto_key_id
    )

    crypto_key_version = create_test_crypto_key_version(
      project_id:    @project_id,
      location_id:   @location_id,
      key_ring_id:   @key_ring_id,
      crypto_key_id: test_crypto_key_id
    )

    version_id = crypto_key_version.name.split("/").last

    expect {
      $set_crypto_key_primary_version.call(
        project_id:    @project_id,
        location_id:   @location_id,
        key_ring_id:   @key_ring_id,
        crypto_key_id: test_crypto_key_id,
        version_id:    version_id
      )
    }.to output(/Set #{version_id} as primary version/).to_stdout

    crypto_key = get_test_crypto_key(
      project_id:    @project_id,
      location_id:   @location_id,
      key_ring_id:   @key_ring_id,
      crypto_key_id: test_crypto_key_id
    )

    expect(crypto_key.primary.name).to eq crypto_key_version.name
  end

  it "can enable a crypto key version" do
    test_crypto_key_id = "#{@project_id}-enable-#{Time.now.to_i}"

    crypto_key = create_test_crypto_key(
      project_id:    @project_id,
      location_id:   @location_id,
      key_ring_id:   @key_ring_id,
      crypto_key_id: test_crypto_key_id
    )

    version_id = "1" # first version is labeled 1

    disabled_crypto_key_version = disable_test_crypto_key_version(
      project_id:    @project_id,
      location_id:   @location_id,
      key_ring_id:   @key_ring_id,
      crypto_key_id: test_crypto_key_id,
      version_id:    version_id
    )

    expect(disabled_crypto_key_version.state).to eq :DISABLED

    expect {
      $enable_crypto_key_version.call(
        project_id:    @project_id,
        location_id:   @location_id,
        key_ring_id:   @key_ring_id,
        crypto_key_id: test_crypto_key_id,
        version_id:    version_id
      )
    }.to output(/Enabled version #{version_id} of #{test_crypto_key_id}/).to_stdout

    crypto_key = get_test_crypto_key_version(
      project_id:    @project_id,
      location_id:   @location_id,
      key_ring_id:   @key_ring_id,
      crypto_key_id: test_crypto_key_id,
      version_id:    version_id
    )

    expect(crypto_key.state).to eq :ENABLED
  end

  it "can disable a crypto key version" do
    test_crypto_key_id = "#{@project_id}-disable-#{Time.now.to_i}"

    crypto_key = create_test_crypto_key(
      project_id:    @project_id,
      location_id:   @location_id,
      key_ring_id:   @key_ring_id,
      crypto_key_id: test_crypto_key_id
    )

    version_id = "1" # first version is labeled 1

    expect {
      $disable_crypto_key_version.call(
        project_id:    @project_id,
        location_id:   @location_id,
        key_ring_id:   @key_ring_id,
        crypto_key_id: test_crypto_key_id,
        version_id:    version_id
      )
    }.to output(/Disabled version #{version_id} of #{test_crypto_key_id}/).to_stdout

    crypto_key = get_test_crypto_key_version(
      project_id:    @project_id,
      location_id:   @location_id,
      key_ring_id:   @key_ring_id,
      crypto_key_id: test_crypto_key_id,
      version_id:    version_id
    )

    expect(crypto_key.state).to eq :DISABLED
  end

  it "can restore a crypto key version" do
    test_crypto_key_id = "#{@project_id}-restore-#{Time.now.to_i}"

    crypto_key = create_test_crypto_key(
      project_id:    @project_id,
      location_id:   @location_id,
      key_ring_id:   @key_ring_id,
      crypto_key_id: test_crypto_key_id
    )

    version_id = "1" # first version is labeled 1

    scheduled_crypto_key_version = destroy_test_crypto_key_version(
      project_id:    @project_id,
      location_id:   @location_id,
      key_ring_id:   @key_ring_id,
      crypto_key_id: test_crypto_key_id,
      version_id:    version_id
    )

    expect(scheduled_crypto_key_version.state).to eq :DESTROY_SCHEDULED

    expect {
      $restore_crypto_key_version.call(
        project_id:    @project_id,
        location_id:   @location_id,
        key_ring_id:   @key_ring_id,
        crypto_key_id: test_crypto_key_id,
        version_id:    version_id
      )
    }.to output(/Restored version #{version_id} of #{test_crypto_key_id}/).to_stdout

    crypto_key = get_test_crypto_key_version(
      project_id:    @project_id,
      location_id:   @location_id,
      key_ring_id:   @key_ring_id,
      crypto_key_id: test_crypto_key_id,
      version_id:    version_id
    )

    expect(crypto_key.state).to eq :DISABLED
  end

  it "can destroy a crypto key version" do
    test_crypto_key_id = "#{@project_id}-destroy-#{Time.now.to_i}"

    crypto_key = create_test_crypto_key(
      project_id:    @project_id,
      location_id:   @location_id,
      key_ring_id:   @key_ring_id,
      crypto_key_id: test_crypto_key_id
    )

    version_id = "1" # first version is labeled 1

    expect {
      $destroy_crypto_key_version.call(
        project_id:    @project_id,
        location_id:   @location_id,
        key_ring_id:   @key_ring_id,
        crypto_key_id: test_crypto_key_id,
        version_id:    version_id
      )
    }.to output(/Destroyed version #{version_id} of #{test_crypto_key_id}/).to_stdout

    crypto_key = get_test_crypto_key_version(
      project_id:    @project_id,
      location_id:   @location_id,
      key_ring_id:   @key_ring_id,
      crypto_key_id: test_crypto_key_id,
      version_id:    version_id
    )

    expect(crypto_key.state).to eq :DESTROY_SCHEDULED
  end

  it "can add a member to a crypto key policy" do
    expect {
      $add_member_to_crypto_key_policy.call(
        project_id:    @project_id,
        location_id:   @location_id,
        key_ring_id:   @key_ring_id,
        crypto_key_id: @crypto_key_id,
        member:        "user:test@test.com",
        role:          "roles/owner"
      )
    }.to output(/test@test.com/).to_stdout

    policy = get_test_crypto_key_policy(
      project_id:    @project_id,
      location_id:   @location_id,
      key_ring_id:   @key_ring_id,
      crypto_key_id: @crypto_key_id
    )

    members = policy.bindings.map(&:members).flatten

    expect(members).to include("user:test@test.com")
  end

  it "can remove a member to a crypto key policy" do
    test_crypto_key_id = "#{@project_id}-remove-member-#{Time.now.to_i}"

    create_test_crypto_key(
      project_id:    @project_id,
      location_id:   @location_id,
      key_ring_id:   @key_ring_id,
      crypto_key_id: test_crypto_key_id
    )

    add_test_member_to_crypto_key_policy(
      project_id:    @project_id,
      location_id:   @location_id,
      key_ring_id:   @key_ring_id,
      crypto_key_id: test_crypto_key_id,
      member:        "user:test@test.com",
      role:          "roles/owner"
    )

    policy = get_test_crypto_key_policy(
      project_id:    @project_id,
      location_id:   @location_id,
      key_ring_id:   @key_ring_id,
      crypto_key_id: test_crypto_key_id
    )

    expect(policy.bindings).to_not be nil

    expect {
      $remove_member_from_crypto_key_policy.call(
        project_id:    @project_id,
        location_id:   @location_id,
        key_ring_id:   @key_ring_id,
        crypto_key_id: test_crypto_key_id,
        member:        "user:test@test.com",
        role:          "roles/owner"
      )
    }.to output(/test@test.com/).to_stdout

    policy = get_test_crypto_key_policy(
      project_id:    @project_id,
      location_id:   @location_id,
      key_ring_id:   @key_ring_id,
      crypto_key_id: test_crypto_key_id
    )

    if policy.bindings
      members = policy.bindings.map(&:members).flatten

      expect(members).to_not include("test@test.com")
    end
  end

  it "can add a member to a key ring policy" do
    remove_test_member_to_key_ring_policy(
      project_id:  @project_id,
      location_id: @location_id,
      key_ring_id: @key_ring_id,
      member:      "serviceAccount:test-account@#{@project_id}.iam.gserviceaccount.com",
      role:        "roles/owner"
    )

    policy = get_test_key_ring_policy(
      project_id:  @project_id,
      location_id: @location_id,
      key_ring_id: @key_ring_id
    )

    if policy.bindings
      members = policy.bindings.map(&:members).flatten

      expect(members).to_not include("serviceAccount:test-account@#{@project_id}.iam.gserviceaccount.com")
    end

    expect {
      $add_member_to_key_ring_policy.call(
        project_id:  @project_id,
        location_id: @location_id,
        key_ring_id: @key_ring_id,
        member:      "serviceAccount:test-account@#{@project_id}.iam.gserviceaccount.com",
        role:        "roles/owner"
      )
    }.to output(/serviceAccount:test-account@#{@project_id}.iam.gserviceaccount.com/).to_stdout

    policy = get_test_key_ring_policy(
      project_id:  @project_id,
      location_id: @location_id,
      key_ring_id: @key_ring_id
    )

    members = policy.bindings.map(&:members).flatten

    expect(members).to include("serviceAccount:test-account@#{@project_id}.iam.gserviceaccount.com")
  end

  it "can get a key ring policy" do
    add_test_member_to_key_ring_policy(
      project_id:  @project_id,
      location_id: @location_id,
      key_ring_id: @key_ring_id,
      member:      "serviceAccount:test-account@#{@project_id}.iam.gserviceaccount.com",
      role:        "roles/owner"
    )

    expect {
      $get_key_ring_policy.call(
        project_id:  @project_id,
        location_id: @location_id,
        key_ring_id: @key_ring_id
      )
    }.to output(/serviceAccount:test-account@#{@project_id}.iam.gserviceaccount.com/).to_stdout
  end
end
