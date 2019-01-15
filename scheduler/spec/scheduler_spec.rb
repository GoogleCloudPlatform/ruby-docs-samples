# Copyright 2018 Google LLC
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

require_relative "../app"
require_relative "../create_job"
require "rspec"
require "rack/test"

describe "CloudScheduler", type: :feature do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  it "returns Hello World" do
    get "/"
    expect(last_response.body).to include("Hello World!")
  end

  it "posts to /log_payload" do
    post "/log_payload", "Hello"
    expect(last_response.body).to include("Printed job payload")
  end

  it "can create and delete a job" do
    GOOGLE_CLOUD_PROJECT = ENV["GOOGLE_CLOUD_PROJECT"]
    LOCATION_ID          = "us-central1"

    # expect {
    #   create_scheduler_job(GOOGLE_CLOUD_PROJECT, LOCATION_ID, "my-service")
    # }.to output("Created job").to_stdout
    output = create__job(GOOGLE_CLOUD_PROJECT, LOCATION_ID, "my-service")
  end
end
