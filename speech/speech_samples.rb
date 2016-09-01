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

# Required to load locally generated Cloud Speech API client
# TODO remove once Cloud Speech API client is released in google-api-client gem
$LOAD_PATH.unshift File.expand_path("generated", __dir__)

def initialize_speech_client
  # [START initialize_speech_client]
  require "google/apis/speech_v1beta1"

  speech_service = Google::Apis::SpeechV1beta1::CloudSpeechAPIService.new

  speech_service.authorization = Google::Auth.get_application_default(
    %[ https://www.googleapis.com/auth/cloud-platform ]
  )
  # [END initialize_speech_client]

  speech_service
end

def transcript_from_audio_file audio_file_path:
  speech_service = initialize_speech_client

  # [START transcript_from_audio_file]
  # audio_file_path = "Path to local audio file"

  request        = Google::Apis::SpeechV1beta1::SyncRecognizeRequest.new
  request.audio  = { content: File.read(audio_file_path) }
  request.config = { encoding: "LINEAR16", sample_rate: 16000 }

  response = speech_service.sync_recognize_speech request

  if response.results
    response.results.each do |recognize_result|
      recognize_result.alternatives.each do |alternative_hypothesis|
        puts "Text: #{alternative_hypothesis.transcript}"
      end
    end
  end
  # [END transcript_from_audio_file]
end

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

if __FILE__ == $PROGRAM_NAME
  command = ARGV.shift

  case command
  when "recognize"
    transcript_from_audio_file audio_file_path: ARGV.first
  when "async_recognize"
    begin_async_operation audio_file_path: ARGV.first
  when "async_recognize_results"
    get_async_operation_results operation_name: ARGV.first
  else
    puts <<-usage
Usage: ruby speech_samples.rb <command> [arguments]

Commands:
  recognize               <audio-file.raw>
  async_recognize         <audio-file.raw>
  async_recognize_results <operation name>
    usage
  end
end
