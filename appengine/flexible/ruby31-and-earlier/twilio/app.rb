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
require "twilio-ruby"

TWILIO_ACCOUNT_SID = ENV["TWILIO_ACCOUNT_SID"]
TWILIO_AUTH_TOKEN  = ENV["TWILIO_AUTH_TOKEN"]
TWILIO_NUMBER      = ENV["TWILIO_NUMBER"]

Twilio.configure do |config|
  config.account_sid = TWILIO_ACCOUNT_SID
  config.auth_token  = TWILIO_AUTH_TOKEN
end

# [START gae_flex_twilio_receive_call]
# Answers a call and replies with a simple greeting.
post "/call/receive" do
  content_type :xml

  response = Twilio::TwiML::VoiceResponse.new do |r|
    r.say message: "Hello from Twilio!"
  end

  response.to_s
end
# [END gae_flex_twilio_receive_call]

# [START gae_flex_twilio_send_sms]
# Sends a simple SMS message.
get "/sms/send" do
  client = Twilio::REST::Client.new

  client.messages.create(
    from: TWILIO_NUMBER,
    to:   params[:to],
    body: "Hello from Google App Engine"
  )
end
# [END gae_flex_twilio_send_sms]

# [START gae_flex_twilio_receive_sms]
post "/sms/receive" do
  content_type :xml

  sender  = params[:From]
  message = params[:Body]

  response = Twilio::TwiML::MessagingResponse.new do |r|
    r.message body: "Hello #{sender}, you said #{message}"
  end

  response.to_s
end
# [END gae_flex_twilio_receive_sms]
