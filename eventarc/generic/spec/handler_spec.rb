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

describe "eventarc_generic_handler" do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  it "Service can accept POST requests and prints headers and body" do
    message_hash = { data: "some data" }
    message_json = JSON.generate message_hash
    post "/", message_json, {
      'HTTP_CE_ID' => '1234'
    }
    expect(last_response.status).to eq 200
    expect(last_response.body).to include 'some data'
    expect(last_response.body).to include 'CE_ID: 1234'
  end
end
