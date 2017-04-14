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

def speech_sync_recognize project_id:, audio_file_path:
# [START speech_sync_recognize]
  # project_id      = "Your Google Cloud project ID"
  # audio_file_path = "Path to file on which to perform speech recognition"

  require "google/cloud/speech"

  speech = Google::Cloud::Speech.new project: project_id
  audio  = speech.audio audio_file_path, encoding:    :LINEAR16,
                                         sample_rate: 16000,
                                         language:    "en-US"

  results = audio.recognize
  result  = results.first

  puts "Transcription: #{result.transcript}"
# [END speech_sync_recognize]
end

def speech_sync_recognize_gcs project_id:, storage_path:
# [START speech_sync_recognize_gcs]
  # project_id   = "Your Google Cloud project ID"
  # storage_path = "Path to file in Cloud Storage, eg. gs://bucket/audio.raw"

  require "google/cloud/speech"

  speech = Google::Cloud::Speech.new project: project_id
  audio  = speech.audio storage_path, encoding:    :LINEAR16,
                                      sample_rate: 16000,
                                      language:    "en-US"

  results = audio.recognize
  result  = results.first

  puts "Transcription: #{result.transcript}"
# [END speech_sync_recognize_gcs]
end

def speech_async_recognize project_id:, audio_file_path:
# [START speech_async_recognize]
  # project_id      = "Your Google Cloud project ID"
  # audio_file_path = "Path to file on which to perform speech recognition"

  require "google/cloud/speech"

  speech = Google::Cloud::Speech.new project: project_id
  audio  = speech.audio audio_file_path, encoding:    :LINEAR16,
                                         sample_rate: 16000,
                                         language:    "en-US"

  operation = audio.process

  puts "Operation started"

  operation.wait_until_done!

  results = operation.results
  result  = results.first

  puts "Transcription: #{result.transcript}"
# [END speech_async_recognize]
end

def speech_async_recognize_gcs project_id:, storage_path:
# [START speech_async_recognize_gcs]
  # project_id   = "Your Google Cloud project ID"
  # storage_path = "Path to file in Cloud Storage, eg. gs://bucket/audio.raw"

  require "google/cloud/speech"

  speech = Google::Cloud::Speech.new project: project_id
  audio  = speech.audio storage_path, encoding:    :LINEAR16,
                                      sample_rate: 16000,
                                      language:    "en-US"

  operation = audio.process

  puts "Operation started"

  operation.wait_until_done!

  results = operation.results
  result  = results.first

  puts "Transcription: #{result.transcript}"
# [END speech_async_recognize_gcs]
end

require "google/cloud/speech"

if __FILE__ == $PROGRAM_NAME
  project_id = Google::Cloud::Speech.new.project
  command    = ARGV.shift

  case command
  when "recognize"
    speech_sync_recognize project_id: project_id, audio_file_path: ARGV.first
  when "recognize_gcs"
    speech_sync_recognize_gcs project_id: project_id, storage_path: ARGV.first
  when "async_recognize"
    speech_async_recognize project_id: project_id, audio_file_path: ARGV.first
  when "async_recognize_gcs"
    speech_async_recognize_gcs project_id: project_id, storage_path: ARGV.first
  else
    puts <<-usage
Usage: ruby speech_samples.rb <command> [arguments]

Commands:
  recognize           <filename> Detects speech in a local audio file.
  recognize_gcs       <gcsUri>   Detects speech in an audio file located in a Google Cloud Storage bucket.
  async_recognize     <filename> Creates a job to detect speech in a local audio file, and waits for the job to complete.
  async_recognize_gcs <gcsUri>   Creates a job to detect speech in an audio file located in a Google Cloud Storage bucket, and
                                 waits for the job to complete.
    usage
  end
end
