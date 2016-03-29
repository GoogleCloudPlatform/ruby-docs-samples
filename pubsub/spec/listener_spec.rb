# Copyright 2015 Google, Inc
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

require_relative "../listener"
require "spec_helper"
require "json"
require "base64"

describe "Pub/Sub listener" do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  it "accepts push" do
    message = "Hello!"
    message_enc = Base64.encode64 message
    message_hash = { message: { data: message_enc } }
    message_json = JSON.generate message_hash

    post "/push", message_json

    expect(last_response.status).to eq(204)
  end
end
