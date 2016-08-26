$LOAD_PATH.unshift File.expand_path("lib", __dir__)

require "grpc"
require "googleauth"
require_relative "./lib/google/cloud/speech/v1/cloud_speech_services_pb"

audio_file_uri = ARGV.shift

unless audio_file_uri
  puts "Usage: ruby grpc_recognize.rb gs://bucket/audio-file.raw"
  exit 1
end

client = Google::Auth.get_application_default(
  %[ https://www.googleapis.com/auth/cloud-platform ]
)

credentials = GRPC::Core::ChannelCredentials.new.compose(
  GRPC::Core::CallCredentials.new client.updater_proc
)

speech = Google::Cloud::Speech::V1::Speech::Stub.new(
  "speech.googleapis.com",
  credentials
)

request = Google::Cloud::Speech::V1::RecognizeRequest.new(
  initial_request: Google::Cloud::Speech::V1::InitialRecognizeRequest.new(
    encoding:    Google::Cloud::Speech::V1::InitialRecognizeRequest::AudioEncoding::LINEAR16,
    sample_rate: 16000
  ),
  audio_request: Google::Cloud::Speech::V1::AudioRequest.new(
    uri: audio_file_uri
  )
)

recognize_response = speech.non_streaming_recognize request

recognize_response.responses.each do |response|
  response.results.each           do |result|
    result.alternatives.each      do |alternative|
      puts "Text: #{alternative.transcript}"
    end
  end
end
