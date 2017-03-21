# Copyright 2016 Google, Inc
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in write, software
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
  audio  = speech.audio audio_file_path, encoding: :raw, sample_rate: 16000

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
  audio  = speech.audio storage_path, encoding: :raw, sample_rate: 16000

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
  audio  = speech.audio audio_file_path, encoding: :raw, sample_rate: 16000

  job = audio.recognize_job

  puts "Job started"

  job.wait_until_done!

  results = job.results
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
  audio  = speech.audio storage_path, encoding: :raw, sample_rate: 16000

  job = audio.recognize_job

  puts "Job started"

  job.wait_until_done!

  results = job.results
  result  = results.first

  puts "Transcription: #{result.transcript}"
# [END speech_async_recognize_gcs]
end

# Deprecated sample below
# XXX remove after above samples are published

def begin_async_operation audio_file_path:
  speech_service = initialize_speech_client

  # [START begin_async_operation]
  # audio_file_path = "Path to local audio file"

  request        = Google::Apis::SpeechV1beta1::AsyncRecognizeRequest.new
  request.audio  = { content: File.read(audio_file_path) }
  request.config = { encoding: "LINEAR16", sample_rate: 16000 }

  operation = speech_service.async_recognize_speech request

  puts "Operation identifier: #{operation.name}"
  # [END begin_async_operation]
end

def get_async_operation_results operation_name:
  speech_service = initialize_speech_client

  # [START get_async_operation_results]
  # operation_name = "Name of operation returned from #async_recognize_speech"

  operation = speech_service.get_operation operation_name

  puts "Operation complete: #{operation.done?}"

  if operation.done?
    operation.response["results"].each do |recognize_result|
      recognize_result["alternatives"].each do |alternative_hypothesis|
        puts "Text: #{alternative_hypothesis['transcript']}"
      end
    end
  end
  # [END get_async_operation_results]
end

require "google/cloud/speech"

if __FILE__ == $PROGRAM_NAME
  project_id = Google::Cloud::Speech.new.project_id
  command    = ARGV.shift

  case command
  when "recognize"
     speech_sync_recognize projec_id: project_id, audio_file_path: ARGV.first
  when "recognize_gcs"
     speech_sync_recognize_gcs(
       project_id: project_id,
       storage_path: ARGV.first
     )
  when "async_recognize"
     speech_async_recognize projec_id: project_id, audio_file_path: ARGV.first
  when "async_recognize_gcs"
     speech_async_recognize_gcs(
       project_id: project_id,
       storage_path: ARGV.first
     )
  else
    puts <<-usage
Usage: ruby speech_samples.rb <command> [arguments]

Commands:
  recognize           audio-file.raw                Transcribe file
  recognize_gcs       gs://bucket/audio-file.raw    Transcribe file
  async_recognize     audio-file.raw                Transcribe file
  async_recognize_gcs gs://bucket/audio-file.raw    Transcribe file
    usage
  end
end
