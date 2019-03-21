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

SENDGRID_API_KEY = ENV["SENDGRID_API_KEY"]
SENDGRID_SENDER  = ENV["SENDGRID_SENDER"]

# [START gae_flex_sendgrid]
require "sinatra"
require "sendgrid-ruby"

get "/" do
  '
    <form method="post" action="/send/email">
      <input type="text" name="recipient" placeholder="Enter recipient email">
      <input type="submit" value="Send email">
    </form>
  '
end

post "/send/email" do
  # Define necessary information for a new email
  from    = SendGrid::Email.new email: SENDGRID_SENDER
  to      = SendGrid::Email.new email: params[:recipient]
  subject = "Hello from Google Cloud Ruby SendGrid Sample"
  content = SendGrid::Content.new type:  "text/plain",
                                  value: "Congratulations it works!"

  # Define the new email with provided information
  mail = SendGrid::Mail.new from, subject, to, content

  # Create a new API Client to send the new email
  sendgrid = SendGrid::API.new api_key: SENDGRID_API_KEY

  begin
    # Send request to "mail/send"
    response = sendgrid.client.mail._("send").post request_body: mail.to_json

    "Email sent. #{response.status_code} #{response.body}"
  rescue Exception => ex
    "An error occurred: #{ex.message}"
  end
end
# [END gae_flex_sendgrid]
