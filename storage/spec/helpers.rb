require "google/apis/cloudkms_v1"

def create_kms_key project_id
  kms_key_ring = ENV["GOOGLE_CLOUD_KMS_KEY_RING"]
  kms_key_name = ENV["GOOGLE_CLOUD_KMS_KEY_NAME"]

  kms_client = Google::Apis::CloudkmsV1::CloudKMSService.new
  kms_client.authorization = Google::Auth.get_application_default(
    "https://www.googleapis.com/auth/cloud-platform"
  )
  resource          = "projects/#{project_id}/locations/us"
  key_ring_resource = "#{resource}/keyRings/#{kms_key_ring}"
  key_resource      = "#{key_ring_resource}/cryptoKeys/#{kms_key_name}"

  kms_client.get_project_location_key_ring(
    key_ring_resource
  ) do |result, err|
    if !err.nil?
      kms_client.create_project_location_key_ring(
        resource,
        Google::Apis::CloudkmsV1::KeyRing.new,
        key_ring_id: kms_key_ring
      )
    end
  end

  kms_client.get_project_location_key_ring_crypto_key(
    key_resource
  ) do |result, err|
    if !err.nil?
      kms_client.create_project_location_key_ring_crypto_key(
        key_ring_resource,
        Google::Apis::CloudkmsV1::CryptoKey.new(
          purpose: "ENCRYPT_DECRYPT"
        ),
        crypto_key_id: kms_key_name
      )
    end
  end

  key_resource

end