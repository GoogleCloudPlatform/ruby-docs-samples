# Copyright 2020 Google LLC
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
require "rspec"
require "rack/test"
require "google/cloud/tasks"
require "cgi"

describe "CloudTasks", type: :feature do
  include Rack::Test::Methods

  before :all do
    GOOGLE_CLOUD_PROJECT = ENV["GOOGLE_CLOUD_PROJECT"]
    location_id          = ENV["LOCATION_ID"] || "us-east1"
    QUEUE_ID             = "my-appengine-queue".freeze

    client = Google::Cloud::Tasks.cloud_tasks
    parent = client.queue_path project: GOOGLE_CLOUD_PROJECT, location: location_id, queue: QUEUE_ID

    begin
      client.get_queue name: parent
    rescue StandardError
      location_id = "us-east4"
    end
    LOCATION_ID = location_id.freeze
  end

  def app
    Sinatra::Application
  end

  it "returns Hello World" do
    get "/"
    expect(last_response.body).to include("Hello World!")
  end

  it "posts to /log_payload" do
    post "/log_payload", "Hello"
    expect(last_response.body).to include("Printed task payload")
  end

  it "can create a task" do
    current_directory = __dir__
    snippet_filepath  = File.join current_directory, "..", "create_task.rb"
    payload = "Hello"

    output = `ruby #{snippet_filepath} #{GOOGLE_CLOUD_PROJECT} #{LOCATION_ID} \
              #{QUEUE_ID} #{payload}`

    expect(output).to include "Created task"
  end
end
