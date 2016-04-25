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

require File.expand_path("../../../../spec/e2e", __FILE__)
require "rspec"
require "rest-client"

RSpec.describe "Twilio on Google App Engine", type: :feature do
  before :all do
    @url = E2E.url
  end

  it "can send SMS" do
    # Server will raise Twilio::REST::RequestError because Twilio account
    # information is fake
    expect {
      RestClient.get "#{@url}/sms/send", to: "+15551112222"
    }.to raise_error(
      RestClient::InternalServerError
    )
  end

  it "can receive SMS" do
    response = RestClient.post "#{@url}/sms/receive", From: "+15551112222",
                                                      Body: "Hello"

    expect(response.code).to eq 200
    expect(response.headers[:content_type]).to eq(
      "application/xml;charset=utf-8"
    )
    expect(response.body).to include(
      "<Message>Hello +15551112222, you said Hello</Message>"
    )
  end

  it "can receive call" do
    response = RestClient.post "#{@url}/call/receive", From: "+15551112222"

    expect(response.code).to eq 200
    expect(response.headers[:content_type]).to eq(
      "application/xml;charset=utf-8"
    )
    expect(response.body).to include(
      "<Response><Say>Hello from Twilio!</Say></Response>"
    )
  end
end
