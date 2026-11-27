# Copyright 2024 Google LLC

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

#     https://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "googleauth"
require "google/cloud/iam_credentials/v1"
require "jwt"

def generate_jwt_payload(service_account_email, resource_url)
  iat = Time.now.utc
  exp = iat + 3600

  {
    iss: service_account_email,
    sub: service_account_email,
    aud: resource_url,
    iat: iat.to_i,  # Use integer timestamp for JWT compatibility
    exp: exp.to_i,
  }.to_json
end

def sign_jwt(target_sa, resource_url)
  scope = "https://www.googleapis.com/auth/iam"
  credentials = Google::Auth.get_application_default([scope])
  iam_client = Google::Cloud::IamCredentials::V1::IAMCredentials::Client.new(credentials: credentials)

  response = iam_client.sign_jwt(
    name: iam_client.service_account_path('-', target_sa),
    payload: generate_jwt_payload(target_sa, resource_url),
  )
  response.signed_jwt
end

def sign_jwt_with_key_file(credential_key_file_path, resource_url)
  key_data = JSON.parse(File.read(credential_key_file_path))
  private_key = key_data["private_key"]
  private_key_id = key_data["private_key_id"]
  service_account_email = key_data["client_email"]

  payload = generate_jwt_payload(service_account_email, resource_url)

  JWT.encode(
    payload,
    OpenSSL::PKey::RSA.new(private_key),
    "RS256",
    kid: private_key_id  # Include key ID in header
  )
end
