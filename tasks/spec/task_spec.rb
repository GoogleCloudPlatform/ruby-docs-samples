# Copyright 2018 Google, Inc
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

    client = Google::Cloud::Tasks.new
    parent = client.queue_path GOOGLE_CLOUD_PROJECT, location_id, QUEUE_ID

    begin
      client.get_queue parent
    rescue StandardError
      location_id = "us-east4"
    end
    LOCATION_ID = location_id.freeze
  end

  it "can create an HTTP task" do
    current_directory = File.expand_path(File.dirname(__FILE__))
    snippet_filepath  = File.join current_directory, "..", "create_http_task.rb"

    output = `ruby #{snippet_filepath} #{LOCATION_ID} #{QUEUE_ID} \
            #{"http://example.com/log_payload"}`

    expect(output).to include "Created task"
  end
end
