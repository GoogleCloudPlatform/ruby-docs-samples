# Copyright 2023 Google LLC
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
require "google/cloud/pubsub"
require "rack/test"
require "googleauth"
require "jwt"

describe "PubSub", type: :feature do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  before :all do
    ENV["PUBSUB_TOPIC"] = "flexible-topic" unless ENV["PUBSUB_TOPIC"]
    ENV["PUBSUB_VERIFICATION_TOKEN"] = "abc123" unless ENV["PUBSUB_VERIFICATION_TOKEN"]
    @topic_name = ENV["PUBSUB_TOPIC"]
    @pubsub = Google::Cloud::Pubsub.new

    topic = @pubsub.topic @topic_name
    @pubsub.create_topic @topic_name if topic.nil?
    require_relative "../app.rb"
  end

  it "returns what we expect" do
    get "/"

    expect(last_response.body).to include(
      "Print CLAIMS:"
    )
    expect(last_response.body).to include(
      "Messages received by this instance:"
    )
  end

  it "accepts a publish" do
    post "/publish", payload: "A Message"

    expect(last_response.status).to eq 303
  end

  it "accepts a push" do
    post "/pubsub/push?token=#{ENV["PUBSUB_VERIFICATION_TOKEN"]}",
         JSON.generate({"message" => { "data" => Base64.encode64("A Message") }})

    expect(last_response.status).to eq 200
  end

  it "accepts an authenticated push" do
    public_cert_str = File.read "spec/fixtures/public_cert.pem"
    key = OpenSSL::X509::Certificate.new(public_cert_str).public_key
    key_info = Google::Auth::IDTokens::KeyInfo.new id: "test-key", key: key, algorithm: "RS256"
    key_source = Google::Auth::IDTokens::StaticKeySource.new key_info
    Google::Auth::IDTokens.instance_variable_set(:@oidc_key_source, key_source)

    now = Time.now.to_i
    jwt_payload = {
      aud: 'example.com',
      azp: '1234567890',
      email: 'pubsub@example.iam.gserviceaccount.com',
      email_verified: true,
      iat: now - 60, # Prevent any flakiness that might come from clock skew.
      exp: now + 3600,
      iss: 'https://accounts.google.com',
      sub: '1234567890'
    }
    private_key = OpenSSL::PKey::RSA.new File.read("spec/fixtures/private_key.pem")
    jwt_token = JWT.encode jwt_payload, private_key, "RS256"

    post "/pubsub/authenticated-push?token=#{ENV["PUBSUB_VERIFICATION_TOKEN"]}",
         JSON.generate({ "message" => { "data" => Base64.encode64("A Message") } }),
         { "HTTP_AUTHORIZATION" => "Bearer #{jwt_token}" }

    expect(last_response.status).to eq 200
  end

  after :all do
    topic = @pubsub.topic @topic_name
    topic&.delete
    Google::Auth::IDTokens.forget_sources!
  end
end
