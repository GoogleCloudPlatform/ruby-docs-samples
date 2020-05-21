# Copyright 2020 Google, Inc
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

require "securerandom"
require "uri"

require_relative "spec_helper"
require_relative "../snippets"

describe "Cloud KMS samples" do
  before :all do
    @client      = Google::Cloud::Kms.new
    @project_id  = ENV["GOOGLE_CLOUD_PROJECT"] || raise("missing GOOGLE_CLOUD_PROJECT")
    @location_id = "us-east1"

    @key_ring_id = SecureRandom.uuid
    location_name = @client.location_path(@project_id, @location_id)
    @client.create_key_ring(location_name, @key_ring_id, {})

    key_ring_name = @client.key_ring_path(@project_id, @location_id, @key_ring_id)

    @asymmetric_decrypt_key_id = SecureRandom.uuid
    @client.create_crypto_key(key_ring_name, @asymmetric_decrypt_key_id, {
      purpose: :ASYMMETRIC_DECRYPT,
      version_template: {
        algorithm: :RSA_DECRYPT_OAEP_2048_SHA256
      },
      labels: { "foo" => "bar", "zip" => "zap" }
    })

    @asymmetric_sign_ec_key_id = SecureRandom.uuid
    @client.create_crypto_key(key_ring_name, @asymmetric_sign_ec_key_id, {
      purpose: :ASYMMETRIC_SIGN,
      version_template: {
        algorithm: :EC_SIGN_P256_SHA256
      },
      labels: { "foo" => "bar", "zip" => "zap" }
    })

    @asymmetric_sign_rsa_key_id = SecureRandom.uuid
    @client.create_crypto_key(key_ring_name, @asymmetric_sign_rsa_key_id, {
      purpose: :ASYMMETRIC_SIGN,
      version_template: {
        algorithm: :RSA_SIGN_PSS_2048_SHA256
      },
      labels: { "foo" => "bar", "zip" => "zap" }
    })

    @hsm_key_id = SecureRandom.uuid
    @client.create_crypto_key(key_ring_name, @hsm_key_id, {
      purpose: :ENCRYPT_DECRYPT,
      version_template: {
        algorithm: :GOOGLE_SYMMETRIC_ENCRYPTION,
        protection_level: "HSM"
      },
      labels: { "foo" => "bar", "zip" => "zap" }
    })

    @symmetric_key_id = SecureRandom.uuid
    @client.create_crypto_key(key_ring_name, @symmetric_key_id, {
      purpose: :ENCRYPT_DECRYPT,
      version_template: {
        algorithm: :GOOGLE_SYMMETRIC_ENCRYPTION
      },
      labels: { "foo" => "bar", "zip" => "zap" }
    })
  end

  after :all do
    key_ring_name = @client.key_ring_path(@project_id, @location_id, @key_ring_id)
    @client.list_crypto_keys(key_ring_name).each do |key|
      if key.rotation_period || key.next_rotation_time
        updated_key = {
          name: key.name,
          rotation_period: nil,
          next_rotation_time: nil
        }
        update_mask = { paths: ["rotation_period", "next_rotation_time"] }
        @client.update_crypto_key(updated_key, update_mask)
      end

      filter = "state != DESTROYED AND state != DESTROY_SCHEDULED"
      @client.list_crypto_key_versions(key.name, filter: filter).each do |version|
        @client.destroy_crypto_key_version(version.name)
      end
    end
  end

  describe "#create_key_asymmetric_decrypt" do
    it "creates the key" do
      expect {
        key = create_key_asymmetric_decrypt(
          project_id:  @project_id,
          location_id: @location_id,
          key_ring_id: @key_ring_id,
          id:          SecureRandom.uuid
        )

        expect(key).to be
        expect(key.version_template).to be
        expect(key.purpose).to eq(:ASYMMETRIC_DECRYPT)
        expect(key.version_template.algorithm).to eq(:RSA_DECRYPT_OAEP_2048_SHA256)
      }.to output(/Created asymmetric decryption key/).to_stdout
    end
  end

  describe "#create_key_asymmetric_sign" do
    it "creates the key" do
      expect {
        key = create_key_asymmetric_sign(
          project_id:  @project_id,
          location_id: @location_id,
          key_ring_id: @key_ring_id,
          id:          SecureRandom.uuid
        )

        expect(key).to be
        expect(key.version_template).to be
        expect(key.purpose).to eq(:ASYMMETRIC_SIGN)
        expect(key.version_template.algorithm).to eq(:RSA_SIGN_PKCS1_2048_SHA256)
      }.to output(/Created asymmetric signing key/).to_stdout
    end
  end

  describe "#create_key_hsm" do
    it "creates the key" do
      expect {
        key = create_key_hsm(
          project_id:  @project_id,
          location_id: @location_id,
          key_ring_id: @key_ring_id,
          id:          SecureRandom.uuid
        )

        expect(key).to be
        expect(key.version_template).to be
        expect(key.purpose).to eq(:ENCRYPT_DECRYPT)
        expect(key.version_template.algorithm).to eq(:GOOGLE_SYMMETRIC_ENCRYPTION)
        expect(key.version_template.protection_level).to eq(:HSM)
      }.to output(/Created hsm key/).to_stdout
    end
  end

  describe "#create_key_labels" do
    it "creates the key" do
      expect {
        key = create_key_labels(
          project_id:  @project_id,
          location_id: @location_id,
          key_ring_id: @key_ring_id,
          id:          SecureRandom.uuid
        )

        expect(key).to be
        expect(key.labels).to be
        expect(key.labels["team"]).to eq("alpha")
        expect(key.labels["cost_center"]).to eq("cc1234")
      }.to output(/Created labeled key/).to_stdout
    end
  end

  describe "#create_key_ring" do
    it "creates the key ring" do
      expect {
        key_ring = create_key_ring(
          project_id:  @project_id,
          location_id: @location_id,
          id:          SecureRandom.uuid
        )

        expect(key_ring).to be
        expect(key_ring.name).to include(@location_id)
      }.to output(/Created key ring/).to_stdout
    end
  end

  describe "#create_key_rotation_schedule" do
    it "creates the key" do
      expect {
        key = create_key_rotation_schedule(
          project_id:  @project_id,
          location_id: @location_id,
          key_ring_id: @key_ring_id,
          id:          SecureRandom.uuid
        )

        expect(key).to be
        expect(key.rotation_period).to be
        expect(key.next_rotation_time).to be
        expect(key.rotation_period.seconds).to eq(60*60*24*30)
      }.to output(/Created rotating key/).to_stdout
    end
  end

  describe "#create_key_symmetric_encrypt_decrypt" do
    it "creates the key" do
      expect {
        key = create_key_symmetric_encrypt_decrypt(
          project_id:  @project_id,
          location_id: @location_id,
          key_ring_id: @key_ring_id,
          id:          SecureRandom.uuid
        )

        expect(key).to be
        expect(key.version_template).to be
        expect(key.purpose).to eq(:ENCRYPT_DECRYPT)
        expect(key.version_template.algorithm).to eq(:GOOGLE_SYMMETRIC_ENCRYPTION)
      }.to output(/Created symmetric key/).to_stdout
    end
  end

  describe "#create_key_version" do
    it "creates the key" do
      expect {
        version = create_key_version(
          project_id:  @project_id,
          location_id: @location_id,
          key_ring_id: @key_ring_id,
          key_id:      @symmetric_key_id
        )

        expect(version).to be
        expect(version.name).to include(@key_ring_id)
      }.to output(/Created key version/).to_stdout
    end
  end

  describe "#decrypt_asymmetric" do
    it "decrypts the data" do
      skip "Ruby does not support customizing MGF or hash"
    end
  end

  describe "#decrypt_symmetric" do
    it "decrypts the data" do
      plaintext = "my message"

      key_name = @client.crypto_key_path(@project_id, @location_id, @key_ring_id, @symmetric_key_id)
      encrypt_response = @client.encrypt(key_name, plaintext)
      ciphertext = encrypt_response.ciphertext

      expect {
        decrypt_response = decrypt_symmetric(
          project_id:  @project_id,
          location_id: @location_id,
          key_ring_id: @key_ring_id,
          key_id:      @symmetric_key_id,
          ciphertext:  ciphertext
        )

        expect(decrypt_response).to be
        expect(decrypt_response.plaintext).to eq(plaintext)
      }.to output(/Plaintext/).to_stdout
    end
  end

  describe "#(destroy|restore)_key_version" do
    it "destroys and restores the key" do
      key_name = @client.crypto_key_path(@project_id, @location_id, @key_ring_id, @symmetric_key_id)
      version = @client.create_crypto_key_version(key_name, {})
      version_id = version.name.split("/").last

      expect {
        version = destroy_key_version(
          project_id:  @project_id,
          location_id: @location_id,
          key_ring_id: @key_ring_id,
          key_id:      @symmetric_key_id,
          version_id:  version_id
        )

        expect(version).to be
        expect([:DESTROYED, :DESTROY_SCHEDULED]).to include(version.state)
      }.to output(/Destroyed key version/).to_stdout

      expect {
        version = restore_key_version(
          project_id:  @project_id,
          location_id: @location_id,
          key_ring_id: @key_ring_id,
          key_id:      @symmetric_key_id,
          version_id:  version_id
        )

        expect(version).to be
        expect(version.state).to eq(:DISABLED)
      }.to output(/Restored key version/).to_stdout
    end
  end

  describe "#(disable|enable)_key_version" do
    it "disables and enables the key" do
      key_name = @client.crypto_key_path(@project_id, @location_id, @key_ring_id, @symmetric_key_id)
      version = @client.create_crypto_key_version(key_name, {})
      version_id = version.name.split("/").last

      expect {
        version = disable_key_version(
          project_id:  @project_id,
          location_id: @location_id,
          key_ring_id: @key_ring_id,
          key_id:      @symmetric_key_id,
          version_id:  version_id
        )

        expect(version).to be
        expect(version.state).to eq(:DISABLED)
      }.to output(/Disabled key version/).to_stdout

      expect {
        version = enable_key_version(
          project_id:  @project_id,
          location_id: @location_id,
          key_ring_id: @key_ring_id,
          key_id:      @symmetric_key_id,
          version_id:  version_id
        )

        expect(version).to be
        expect(version.state).to eq(:ENABLED)
      }.to output(/Enabled key version/).to_stdout
    end
  end

  describe "#encrypt_asymmetric" do
    it "encrypts data" do
      skip "Ruby does not support customizing MGF or hash"
    end
  end

  describe "#encrypt_symmetric" do
    it "encrypts the data" do
      plaintext = "my message"
      ciphertext = nil

      expect {
        encrypt_response = encrypt_symmetric(
          project_id:  @project_id,
          location_id: @location_id,
          key_ring_id: @key_ring_id,
          key_id:      @symmetric_key_id,
          plaintext:   plaintext
        )

        expect(encrypt_response).to be
        expect(encrypt_response.ciphertext).to be
        ciphertext = encrypt_response.ciphertext
      }.to output(/Ciphertext/).to_stdout

      key_name = @client.crypto_key_path(@project_id, @location_id, @key_ring_id, @symmetric_key_id)
      decrypt_response = @client.decrypt(key_name, ciphertext)
      expect(decrypt_response.plaintext).to eq(plaintext)
    end
  end

  describe "#get_key_labels" do
    it "gets the key" do
      expect {
        key = get_key_labels(
          project_id:  @project_id,
          location_id: @location_id,
          key_ring_id: @key_ring_id,
          key_id:      @symmetric_key_id
        )

        expect(key).to be
        expect(key.labels).to be
        expect(key.labels["foo"]).to eq("bar")
      }.to output(/foo = bar/).to_stdout
    end
  end

  describe "#get_key_version_attestation" do
    it "gets the attestation" do
      expect {
        attestation = get_key_version_attestation(
          project_id:  @project_id,
          location_id: @location_id,
          key_ring_id: @key_ring_id,
          key_id:      @hsm_key_id,
          version_id:  "1"
        )

        expect(attestation).to be
        expect(attestation.content).to be
      }.to output(/Attestation/).to_stdout
    end
  end

  describe "#get_key_version_attestation" do
    it "gets the public key" do
      expect {
        public_key = get_public_key(
          project_id:  @project_id,
          location_id: @location_id,
          key_ring_id: @key_ring_id,
          key_id:      @asymmetric_decrypt_key_id,
          version_id:  "1"
        )

        expect(public_key).to be
        expect(public_key.pem).to be
      }.to output(/Public key/).to_stdout
    end
  end

  describe "#iam_add_member" do
    it "adds the IAM member" do
      expect {
        policy = iam_add_member(
          project_id:  @project_id,
          location_id: @location_id,
          key_ring_id: @key_ring_id,
          key_id:      @symmetric_key_id,
          member:      "group:test@google.com"
        )

        expect(policy).to be
        bind = policy.bindings.find do |b|
          b.role == "roles/cloudkms.cryptoKeyEncrypterDecrypter"
        end

        expect(bind).to be
        expect(bind.members).to include("group:test@google.com")
      }.to output(/Added/).to_stdout
    end
  end

  describe "#iam_get_policy" do
    it "gets the policy" do
      expect {
        policy = iam_get_policy(
          project_id:  @project_id,
          location_id: @location_id,
          key_ring_id: @key_ring_id,
          key_id:      @symmetric_key_id
        )

        expect(policy).to be
      }.to output(/Policy for/).to_stdout
    end
  end

  describe "#iam_remove_member" do
    it "removes the IAM member" do
      expect {
        policy = iam_remove_member(
          project_id:  @project_id,
          location_id: @location_id,
          key_ring_id: @key_ring_id,
          key_id:      @symmetric_key_id,
          member:      "group:test@google.com"
        )

        expect(policy).to be
        bind = policy.bindings.find do |b|
          b.role == "roles/cloudkms.cryptoKeyEncrypterDecrypter"
        end

        expect(bind).to_not be
      }.to output(/Removed/).to_stdout
    end
  end

  describe "#quickstart" do
    it "lists key rings" do
      expect {
        key_rings = quickstart(
          project_id:  @project_id,
          location_id: @location_id
        )

        expect(key_rings).to be
      }.to output(/Key rings/).to_stdout
    end
  end

  describe "#sign_asymmetric" do
    it "signs payloads" do
      message = "my message"

      expect {
        signature = sign_asymmetric(
          project_id:  @project_id,
          location_id: @location_id,
          key_ring_id: @key_ring_id,
          key_id:      @asymmetric_sign_ec_key_id,
          version_id:  "1",
          message:     message
        )

        expect(signature).to be
        # Note: we can't verify the signature because we can't customize the
        # padding.
      }.to output(/Signature/).to_stdout
    end
  end

  describe "#update_key_add_rotation" do
    it "adds a rotation schedule" do
      expect {
        key = update_key_add_rotation(
          project_id:  @project_id,
          location_id: @location_id,
          key_ring_id: @key_ring_id,
          key_id:      @symmetric_key_id,
        )

        expect(key).to be
        expect(key.rotation_period).to be
        expect(key.next_rotation_time).to be
        expect(key.rotation_period.seconds).to eq(60*60*24*30)
      }.to output(/Updated/).to_stdout
    end
  end

  describe "#update_key_remove_labels" do
    it "removes labels" do
      expect {
        key = update_key_remove_labels(
          project_id:  @project_id,
          location_id: @location_id,
          key_ring_id: @key_ring_id,
          key_id:      @asymmetric_decrypt_key_id,
        )

        expect(key).to be
        expect(key.labels.to_h).to be_empty
      }.to output(/Updated/).to_stdout
    end
  end

  describe "#update_key_remove_rotation" do
    it "removes a rotation schedule" do
      expect {
        key = update_key_remove_rotation(
          project_id:  @project_id,
          location_id: @location_id,
          key_ring_id: @key_ring_id,
          key_id:      @symmetric_key_id,
        )

        expect(key).to be
        expect(key.rotation_period).to_not be
        expect(key.next_rotation_time).to_not be
      }.to output(/Updated/).to_stdout
    end
  end

  describe "#update_key_set_primary" do
    it "updates the primary version" do
      expect {
        key = update_key_set_primary(
          project_id:  @project_id,
          location_id: @location_id,
          key_ring_id: @key_ring_id,
          key_id:      @symmetric_key_id,
          version_id:  "1"
        )

        expect(key).to be
        expect(key.primary).to be
        expect(key.primary.name).to match(/cryptoKeyVersions\/1/)
      }.to output(/Updated/).to_stdout
    end
  end

  describe "#update_key_update_labels" do
    it "updates labels" do
      expect {
        key = update_key_update_labels(
          project_id:  @project_id,
          location_id: @location_id,
          key_ring_id: @key_ring_id,
          key_id:      @asymmetric_sign_ec_key_id,
        )

        expect(key).to be
        expect(key.labels.to_h).to include({ "new_label" => "new_value" })
      }.to output(/Updated/).to_stdout
    end
  end

  describe "#verify_asymmetric_signature_ec" do
    it "verifies the signature" do
      message = "my message"
      key_version_name = @client.crypto_key_version_path(@project_id, @location_id, @key_ring_id, @asymmetric_sign_ec_key_id, "1")
      sign_response = @client.asymmetric_sign(key_version_name, {
        sha256: Digest::SHA256.digest(message)
      })

      expect {
        verified = verify_asymmetric_signature_ec(
          project_id:  @project_id,
          location_id: @location_id,
          key_ring_id: @key_ring_id,
          key_id:      @asymmetric_sign_ec_key_id,
          version_id:  "1",
          message:     message,
          signature:   sign_response.signature
        )

        expect(verified).to be(true)
      }.to output(/Verified/).to_stdout
    end
  end

  if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new("2.5.0")
    describe "#verify_asymmetric_signature_rsa" do
      it "verifies the signature" do
        message = "my message"
        key_version_name = @client.crypto_key_version_path(@project_id, @location_id, @key_ring_id, @asymmetric_sign_rsa_key_id, "1")
        sign_response = @client.asymmetric_sign(key_version_name, {
          sha256: Digest::SHA256.digest(message)
        })

        expect {
          verified = verify_asymmetric_signature_rsa(
            project_id:  @project_id,
            location_id: @location_id,
            key_ring_id: @key_ring_id,
            key_id:      @asymmetric_sign_rsa_key_id,
            version_id:  "1",
            message:     message,
            signature:   sign_response.signature
          )

          expect(verified).to be(true)
        }.to output(/Verified/).to_stdout
      end
    end
  end
end
