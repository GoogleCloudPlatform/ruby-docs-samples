# frozen_string_literal: true

# Copyright 2026 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

ENV["RACK_ENV"] = "test"

require "json"
require "minitest/autorun"
require "net/http"
require "openssl"
require "rack/test"

IAP_TEST_EC_KEY = OpenSSL::PKey::EC.generate "prime256v1"
IAP_OTHER_EC_KEY = OpenSSL::PKey::EC.generate "prime256v1"
IAP_TEST_KID = "test-key-1"
IAP_EXPECTED_AUD = "/projects/123456/apps/my-project-id"
IAP_EXPECTED_ISS = "https://cloud.google.com/iap"

fake_cert_response = Struct.new(:body).new(
  JSON.generate(IAP_TEST_KID => IAP_TEST_EC_KEY.public_to_pem)
)
fake_metadata_http = Object.new
def fake_metadata_http.request req
  value = req.path.end_with?("numeric-project-id") ? "123456" : "my-project-id"
  Struct.new(:body).new value
end

Net::HTTP.stub :get_response, fake_cert_response do
  Net::HTTP.stub :new, fake_metadata_http do
    require_relative "../app"
  end
end

describe "authenticating-users app" do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def call_validate_assertion token
    result = nil
    capture_io do
      result = Sinatra::Application.new!.send :validate_assertion, token
    end
    result
  end

  def build_iap_jwt(aud: IAP_EXPECTED_AUD,
                    iss: IAP_EXPECTED_ISS,
                    exp: Time.now.to_i + 300,
                    email: "user@example.com",
                    key: IAP_TEST_EC_KEY,
                    kid: IAP_TEST_KID)
    payload = {
      "aud" => aud,
      "iss" => iss,
      "exp" => exp,
      "iat" => Time.now.to_i - 10,
      "email" => email,
      "sub" => "accounts.google.com:12345"
    }.compact
    JWT.encode payload, key, "ES256", { "kid" => kid }
  end

  it "accepts a valid IAP JWT with matching audience and issuer" do
    token = build_iap_jwt
    assert_equal ["user@example.com", "accounts.google.com:12345"],
                 call_validate_assertion(token)

    header "X-Goog-Iap-Jwt-Assertion", token
    get "/"

    assert_equal 200, last_response.status
    assert_equal "<h1>Hello user@example.com</h1>", last_response.body
  end

  it "rejects an IAP JWT signed for a different project audience" do
    token = build_iap_jwt aud: "/projects/999999/apps/attacker-project",
                          email: "attacker@example.com"
    assert_equal [nil, nil], call_validate_assertion(token)

    header "X-Goog-Iap-Jwt-Assertion", token
    capture_io { get "/" }

    assert_equal "<h1>Hello </h1>", last_response.body
  end

  it "rejects an IAP JWT missing the aud claim" do
    token = build_iap_jwt aud: nil
    assert_equal [nil, nil], call_validate_assertion(token)
  end

  it "rejects an IAP JWT with the wrong issuer" do
    token = build_iap_jwt iss: "https://accounts.google.com"
    assert_equal [nil, nil], call_validate_assertion(token)
  end

  it "rejects an IAP JWT missing the iss claim" do
    token = build_iap_jwt iss: nil
    assert_equal [nil, nil], call_validate_assertion(token)
  end

  it "rejects an expired IAP JWT or invalid signature" do
    expired_token = build_iap_jwt exp: Time.now.to_i - 60
    wrong_sig_token = build_iap_jwt key: IAP_OTHER_EC_KEY

    assert_equal [nil, nil], call_validate_assertion(expired_token)
    assert_equal [nil, nil], call_validate_assertion(wrong_sig_token)
  end

  it "renders empty greeting when no IAP header is present" do
    capture_io { get "/" }

    assert_equal 200, last_response.status
    assert_equal "<h1>Hello </h1>", last_response.body
  end
end
