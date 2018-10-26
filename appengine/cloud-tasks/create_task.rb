# Copyright 2018 Google, Inc
# Licensed under the Apache License, Version 2.0 (the "License")
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http:#www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

def create_task project, location, queue, payload: nil, seconds: nil
  # [START cloud_tasks_appengine_create_task]
  require "google/cloud/tasks"
  require "base64"

  # Instantiates a client.
  cloud_tasks = Google::Cloud::Tasks.new
  # TODO(developer): Uncomment these lines and replace with your values.
  # project = "my-project-id"
  # queue = "my-appengine-queue"
  # location = "us-central1"
  # payload = "hello"

  # Construct the fully qualified queue name.
  parent = "projects/#{project}/locations/#{location}/queues/#{queue}"

  # Construct task.
  task = {
    app_engine_http_request: {
      http_method: "POST",
      relative_uri: "/log_payload"
    }
  }

  if payload
    task[:app_engine_http_request][:body] = payload;
  end

  if seconds
    timestamp = Google::Protobuf::Timestamp.new
    timestamp.seconds = Time.now.to_i + seconds.to_i
    task[:schedule_time] = timestamp
  end

  # Send create task request.
  puts "Sending task #{task}"
  response = cloud_tasks.create_task parent, task

  if response.name
    puts "Created task #{response.name}"
  end
  # [END cloud_tasks_appengine_create_task]
end

if __FILE__ == $PROGRAM_NAME
  project_id  = ENV["GOOGLE_CLOUD_PROJECT"]
  queue_id    = ENV["QUEUE_ID"]
  location_id = ENV["LOCATION_ID"]
  payload     = ARGV.shift
  seconds     = ARGV.shift

  if project_id && queue_id && location_id
  create_task(
    project_id,
    location_id,
    queue_id,
    payload: payload,
    seconds: seconds
  )
  else
    puts <<-usage
Usage: ruby create_task.rb <payload> <seconds>

Environment variables:
  GOOGLE_CLOUD_PROJECT must be set to your Google Cloud project ID
  QUEUE_ID must be set to your Google App Engine queue ID
  LOCATION_ID must be set to your Google App Engine location
  GOOGLE_APPLICATION_CREDENTIALS set to the path to your JSON credentials

    usage
  end
end
