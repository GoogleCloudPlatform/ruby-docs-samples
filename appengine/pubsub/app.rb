# Copyright 2016 Google, Inc
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

# [START gae_flex_pubsub_messages]
# List of all messages received by this instance
messages = []
# [END gae_flex_pubsub_messages]

claims = []

# [START gae_flex_pubsub_index]
get "/" do
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

# [START gaeflex_net_pubsub_auth_push]
post "/pubsub/authenticated-push" do
  halt 400 if params[:token] != PUBSUB_VERIFICATION_TOKEN

  bearer = request.env["Authorization"]
  token = bearer.split(" ")[1]
  begin
    claim = Google::Auth::IDTokens.verify_oidc token, aud: "example.com"
    claims.push claim
  rescue Google::Auth::IDTokens::VerificationError => e
    puts "VerificationError: #{e.message}"
    halt 400, "Invalid token"
  end

  message = JSON.parse request.body.read
  payload = Base64.decode64 message["message"]["data"]

  messages.push payload
end
# [END gaeflex_net_pubsub_auth_push]

__END__

@@index
doctype html
html
  head
    title Pub/Sub Ruby on Google App Engine Managed VMs
  body
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
