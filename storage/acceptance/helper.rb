require "google/cloud/errors"
require "google/cloud/kms"
require "google/cloud/storage"
require "minitest/autorun"
require "net/http"
require "securerandom"
require "uri"

def create_bucket_helper bucket_name
  storage_client = Google::Cloud::Storage.new

  5.times do
    begin
      return storage_client.create_bucket bucket_name
    rescue Google::Cloud::ResourceExhaustedError => e
      puts e
      puts "trying again"
      sleep rand(1..3)
    end
  end
end

def delete_bucket_helper bucket_name
  storage_client = Google::Cloud::Storage.new
  bucket = storage_client.bucket bucket_name
  return unless bucket

  5.times do
    begin
      bucket.files.each(&:delete)
      bucket.delete
      return
    rescue Google::Cloud::ResourceExhaustedError => e
      puts e
      puts "trying again"
      sleep rand(1..3)
    end
  end
end

def get_kms_key project_id
  kms_client = Google::Cloud::Kms.new

  key_ring_id = "gapic_test_ring_id"
  location_path = kms_client.location_path project_id, "us"
  key_ring_path = kms_client.key_ring_path project_id, "us", key_ring_id
  begin
    kms_client.create_key_ring location_path, key_ring_id, {}
  rescue Google::Gax::GaxError
    kms_client.get_key_ring key_ring_path
  end

  crypto_key_id = "gapic_test_key"
  crypto_key = {
    purpose: :ENCRYPT_DECRYPT
  }
  crypto_key_path = kms_client.crypto_key_path project_id, "us", key_ring_id, crypto_key_id
  begin
    kms_client.create_crypto_key(key_ring_id, crypto_key_id, crypto_key).name
  rescue Google::Gax::GaxError
    kms_client.get_crypto_key(crypto_key_path).name
  end
end

def delete_hmac_key_helper hmac_key
  hmac_key.refresh!
  return if hmac_key.deleted?

  hmac_key.inactive! if hmac_key.active?
  hmac_key.delete!
end
