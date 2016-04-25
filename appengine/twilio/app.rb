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

# [START configuration]
TWILIO_ACCOUNT_SID = ENV["TWILIO_ACCOUNT_SID"]
TWILIO_AUTH_TOKEN  = ENV["TWILIO_AUTH_TOKEN"]
TWILIO_NUMBER      = ENV["TWILIO_NUMBER"]

Twilio.configure do |config|
  config.account_sid = TWILIO_ACCOUNT_SID
  config.auth_token  = TWILIO_AUTH_TOKEN
end
# [END configuration]

# [START receive_call]
# Answers a call and replies with a simple greeting.
post "/call/receive" do
  content_type :xml

  response = Twilio::TwiML::Response.new do |r|
    r.Say "Hello from Twilio!"
  end

  response.text
end
# [END receive_call]

# [START send_sms]
# Sends a simple SMS message.
get "/sms/send" do
  client = Twilio::REST::Client.new

  client.messages.create(
    from: TWILIO_NUMBER,
    to:   params[:to],
    body: "Hello from Google App Engine"
  )
end
# [END send_sms]

# [START receive_sms]
post "/sms/receive" do
  content_type :xml

  sender  = params[:From]
  message = params[:Body]

  response = Twilio::TwiML::Response.new do |r|
    r.Message "Hello #{sender}, you said #{message}"
  end

  response.text
end
# [END receive_sms]
