# Copyright 2018 Google, Inc
#
# Licensed under the Apache License, Version 2.0 (the "License");
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
require 'base64'

def create_task project, location, queue, payload: nil, seconds: nil
  require "google/cloud/tasks"

  cloud_tasks = Google::Cloud::Tasks.new
  # TODO(developer): Uncomment these lines and replace with your values.
  # const project = 'my-project-id';
  # const queue = 'my-appengine-queue';
  # const location = 'us-central1';
  # const options = {payload: 'hello'};

  parent = "projects/#{project}/locations/#{location}/queues/#{queue}"

  task = {
    app_engine_http_request: {
      http_method: 'POST',
      relative_uri: '/log_payload'
    }
  }

  if payload
    task['app_engine_http_request']['body'] = Base64.encode64(payload)
  end

  if seconds
    task['schedule_time']['seconds'] = Time.now + seconds
  end

  puts "Sending task #{task}"
  cloud_tasks.create_task(parent, task)
end

if __FILE__ == $PROGRAM_NAME
  project_id  = ENV["PROJECT_ID"]
  queue_id    = ENV["QUEUE_ID"]
  location_id = ENV["LOCATION_ID"]
  payload     = ARGV.shift

  if payload

  else
    puts <<-usage
Usage: ruby speech_samples.rb <command> [arguments]
Commands:
  recognize                 <filename> Detects speech in a local audio file.
  recognize_words           <filename> Detects speech in a local audio file with word offsets.
  recognize_gcs             <gcsUri>   Detects speech in an audio file located in a Google Cloud Storage bucket.
  async_recognize           <filename> Creates a job to detect speech in a local audio file, and waits for the job to complete.
  async_recognize_gcs       <gcsUri>   Creates a job to detect speech in an audio file located in a Google Cloud Storage bucket, and waits for the job to complete.
  async_recognize_gcs_words <gcsUri>   Creates a job to detect speech with wordsoffsets in an audio file located in a Google Cloud Storage bucket, and waits for the job to complete.
  stream_recognize          <filename> Detects speech in a local audio file by streaming it to the Speech API.
  auto_punctuation          <filename> Detects speech in a local audio file, including automatic punctuation in the transcript.
  enhanced_model            <filename> Detects speech in a local audio file, using a model enhanced for phone call audio.
  model_selection           <filename> Detects speech in a local file, using a specific model.
    usage
  end
end
