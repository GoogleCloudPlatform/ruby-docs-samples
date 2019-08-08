# Copyright 2019 Google LLC
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

ENV["RACK_ENV"] = "test"

require_relative "../app"
require "rspec"
require "rack/test"
require "json"
require "base64"

describe "Pub/Sub app" do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  it "sends 400 with empty payload" do
    message = JSON.generate ""
    post "/", message
    expect(last_response.status).to eq(400)
  end

  it "sends 400 with invalid payload" do
    body = {no_message: "invalid"}
    message = JSON.generate body
    post "/", message
    expect(last_response.status).to eq(400)
  end

  it " sends 400 with invalid mimetype" do
    headers = {CONTENT_TYPE: "text"}
    message = "{message: true}"
    post "/", message, headers
    expect(last_response.status).to eq(400)
  end

  it "sends 204 with minimal message" do
    body = {message: "message"}
    message = JSON.generate body
    post "/", message
    expect(last_response.status).to eq(204)
  end

  it "sends 204 with message" do
    data = Base64.encode64 "Hello World!"
    body = {message: {data: data}}
    message = JSON.generate body
    post "/", message
    expect(last_response.status).to eq(204)
  end
end
