# Copyright 2020 Google, LLC
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

describe "run_events_pubsub_handler" do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  it "Service can accept POST with empty message" do
    message_hash = { message: { data: "" } }
    message_json = JSON.generate message_hash
    post "/", message_json, {
      'ce-id' => '1234'
    }
    expect(last_response.status).to eq 200
    expect(last_response.body).to eq 'Hello World! ID: 1234'
  end
  
  it "Service can accept POST with message" do
    message = "Daniel"
    message_enc = Base64.encode64 message
    message_hash = { message: { data: message_enc } }
    message_json = JSON.generate message_hash
    post "/", message_json, {
      'ce-id' => '5678'
    }
    expect(last_response.status).to eq 200
    expect(last_response.body).to eq 'Hello Daniel! ID: 5678'
  end
  
  it "Service can accept POST without a ce-id for some reason" do
    message = "Daniel"
    message_enc = Base64.encode64 message
    message_hash = { message: { data: message_enc } }
    message_json = JSON.generate message_hash
    post "/", message_json, {
    }
    expect(last_response.status).to eq 200
    expect(last_response.body).to eq 'Hello Daniel! ID: '
  end
end
