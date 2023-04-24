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

require "sinatra"
require "slim"
require "json"
require "base64"
require "google/cloud/pubsub"
require "googleauth"

pubsub = Google::Cloud::Pubsub.new

# [START gae_flex_pubsub_env]
topic = pubsub.topic ENV["PUBSUB_TOPIC"]
PUBSUB_VERIFICATION_TOKEN = ENV["PUBSUB_VERIFICATION_TOKEN"]
# [END gae_flex_pubsub_env]

claims = []

# [START gae_flex_pubsub_messages]
# List of all messages received by this instance
messages = []
# [END gae_flex_pubsub_messages]

# [START gae_flex_pubsub_index]
get "/" do
  @claims = claims
  @messages = messages

  slim :index
end

post "/publish" do
  topic.publish params[:payload]

  redirect "/", 303
end
# [END gae_flex_pubsub_index]

# [START gae_flex_pubsub_push]
post "/pubsub/push" do
  halt 400 if params[:token] != PUBSUB_VERIFICATION_TOKEN

  message = JSON.parse request.body.read
  payload = Base64.decode64 message["message"]["data"]

  messages.push payload
end
# [END gae_flex_pubsub_push]

# [START gaestd_ruby_pubsub_auth_push]
post "/pubsub/authenticated-push" do
  halt 400 if params[:token] != PUBSUB_VERIFICATION_TOKEN

  begin
    bearer = request.env["HTTP_AUTHORIZATION"]
    token = /Bearer (.*)/.match(bearer)[1]
    claim = Google::Auth::IDTokens.verify_oidc token, aud: "example.com"

    # IMPORTANT: you should validate claim details not covered by signature
    # and audience verification above, including:
    #   - Ensure that `claim["email"]` is equal to the expected service
    #     account set up in the push subscription settings.
    #   - Ensure that `claim["email_verified"]` is set to true.

    claims.push claim
  rescue Google::Auth::IDTokens::VerificationError => e
    puts "VerificationError: #{e.message}"
    halt 400, "Invalid token"
  end

  message = JSON.parse request.body.read
  payload = Base64.decode64 message["message"]["data"]

  messages.push payload
end
# [END gaestd_ruby_pubsub_auth_push]

__END__

@@index
doctype html
html
  head
    title Pub/Sub Ruby on Google App Engine Managed VMs
  body
    p Print CLAIMS:
    ul
      - @claims.each do |claim|
        li = claim
    p Messages received by this instance:
    ul
      - @messages.each do |message|
        li = message
    p
      small
        | Note: because your application is likely running multiple instances,
        | each instance will have a different list of messages.

    form method="post" action="publish"
      textarea name="payload" placeholder="Enter message here."
      input type="submit" value="Send"
