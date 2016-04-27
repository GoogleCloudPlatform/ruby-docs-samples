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

# [START config]
MAILGUN_API_KEY = ENV["MAILGUN_API_KEY"]
MAILGUN_DOMAIN_NAME = ENV["MAILGUN_DOMAIN_NAME"]
# [END config]

require "sinatra"
require "mailgun"

get "/" do
  '
    <h3>Plain Text</h3>
    <form id="plaintext" method="post" action="/send/plaintext_email">
      <input type="text" name="recipient" placeholder="Enter recipient email">
      <input type="submit" value="Send email">
    </form>

    <h3>Complex</h3>
    <form id="complex" method="post" action="/send/complex_email">
      <input type="text" name="recipient" placeholder="Enter recipient email">
      <input type="submit" value="Send email">
    </form>
  '
end

# [START plaintext_email]
# Send simple plaintext email message
post "/send/plaintext_email" do
  mailgun = Mailgun::Client.new MAILGUN_API_KEY

  mailgun.send_message MAILGUN_DOMAIN_NAME,
                       to:      params[:recipient],
                       from:    "Mailgun User <mailgun@#{MAILGUN_DOMAIN_NAME}>",
                       subject: "Simple Mailgun Example",
                       text:    "Plaintext content"

  "Email sent."
end
# [END plaintext_email]

# [START complex_email]
# Send HTML email message with attachment
post "/send/complex_email" do
  mailgun = Mailgun::Client.new MAILGUN_API_KEY
  message = Mailgun::MessageBuilder.new

  message.add_recipient  :to, params[:recipient]
  message.add_recipient  :from, "Mailgun User <mailgun@#{MAILGUN_DOMAIN_NAME}>"
  message.subject        "Complex Mailgun Example"
  message.body_text      "Plaintext content"
  message.body_html      "<html>HTML <strong>content</strong></html>"
  message.add_attachment "./example-attachment.txt", "attachment"

  mailgun.send_message MAILGUN_DOMAIN_NAME, message

  "Email sent."
end
# [END complex_email]

error do
  if env["sinatra.error"].is_a? Mailgun::CommunicationError
    "Email failed to send"
  else
    env["sinatra.error"].message
  end
end
