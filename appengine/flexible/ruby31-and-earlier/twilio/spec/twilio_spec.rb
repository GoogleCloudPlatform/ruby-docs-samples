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

require_relative "../app.rb"
require "rspec"
require "rack/test"
require "rest-client"

describe "Twilio", type: :feature do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  it "can send SMS" do
    # Server will raise Twilio::REST::RequestError because Twilio account
    # information is fake
    get "/sms/send", to: "+15551112222"
    expect(last_response.status).to eq 500
  end

  it "can receive SMS" do
    post "/sms/receive", From: "+15551112222",
                         Body: "Hello"

    expect(last_response.ok?).to eq(true)
    expect(last_response.headers["Content-Type"]).to eq(
      "application/xml;charset=utf-8"
    )
    expect(last_response.body).to include(
      "<Message>Hello +15551112222, you said Hello</Message>"
    )
  end

  it "can receive call" do
    post "/call/receive", From: "+15551112222"

    expect(last_response.ok?).to eq(true)
    expect(last_response.headers["Content-Type"]).to eq(
      "application/xml;charset=utf-8"
    )
    expect(last_response.body).to include(
      "<Say>Hello from Twilio!</Say>"
    )
  end
end
