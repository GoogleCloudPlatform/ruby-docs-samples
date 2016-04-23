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
SENDGRID_API_KEY = ENV["SENDGRID_API_KEY"]
SENDGRID_SENDER  = ENV["SENDGRID_SENDER"]
# [END config]

# [START all]
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
  email = SendGrid::Mail.new do |e|
    e.to      = params[:recipient]
    e.from    = SENDGRID_SENDER
    e.subject = "Hello world!"
    e.text    = "Sendgrid on Google App Engine with Ruby"
  end

  sendgrid = SendGrid::Client.new api_key: SENDGRID_API_KEY

  begin
    response = sendgrid.send email
    "Email sent. #{response.code} #{response.body}"
  rescue SendGrid::Exception => ex
    "An error occurred: #{ex.message}"
  end
end
# [END all]
