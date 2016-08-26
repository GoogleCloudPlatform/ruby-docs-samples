$LOAD_PATH.unshift File.expand_path("lib", __dir__)

require "grpc"
require "googleauth"
require_relative "./lib/google/cloud/speech/v1/cloud_speech_services_pb"

audio_file = ARGV.shift

unless audio_file
  puts "Usage: ruby grpc_recognize.rb [file or gs:// uri]"
  puts
  puts "       ruby grpc_recognize audio.raw"
  puts "       ruby grpc_recognize gs://bucket/audio.raw"
  exit 1
end

client = Google::Auth.get_application_default(
  %[ https://www.googleapis.com/auth/cloud-platform ]
)

credentials = GRPC::Core::ChannelCredentials.new.compose(
  GRPC::Core::CallCredentials.new client.updater_proc
)

speech = Google::Cloud::Speech::V1::Speech::Stub.new(
  "speech.googleapis.com", credentials
)

# Recognize can accept audio file bytes or a URI to a file stored in GCS
# This sample demonstrates both.  URI is used if argument starts with gs://
if audio_file.start_with? "gs://"
  audio_request = Google::Cloud::Speech::V1::AudioRequest.new(
    uri: audio_file
  )
else
  audio_request = Google::Cloud::Speech::V1::AudioRequest.new(
    content: File.binread(audio_file)
  )
end

request = Google::Cloud::Speech::V1::RecognizeRequest.new(
  audio_request:   audio_request,
  initial_request: Google::Cloud::Speech::V1::InitialRecognizeRequest.new(
    encoding:      Google::Cloud::Speech::V1::InitialRecognizeRequest::AudioEncoding::LINEAR16,
    sample_rate:   16000
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
