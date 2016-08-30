audio_file = ARGV.shift

unless audio_file
  puts "Usage: ruby recognize.rb [audio file.raw]"
  exit 1
end

require_relative "google/apis/speech_v1beta1"

speech = Google::Apis::SpeechV1beta1::CloudSpeechAPIService.new

speech.authorization = Google::Auth.get_application_default(
  %[ https://www.googleapis.com/auth/cloud-platform ]
)

request        = Google::Apis::SpeechV1beta1::AsyncRecognizeRequest.new
request.audio  = { content: File.read(audio_file) }
request.config = { encoding: "LINEAR16", sample_rate: 16000 }

operation = speech.asyncrecognize_speech request

puts "Operation identifier: #{operation.name}"

operation = speech.get_operation operation.name

until operation.done?
  puts "Waiting for operation #{operation.name} to complete"
  sleep 0.1
  operation = speech.get_operation operation.name
end

puts "Operation complete"

operation.response["results"].each do |recognize_result|
  recognize_result["alternatives"].each do |alternative_hypothesis|
    puts "Text: #{alternative_hypothesis["transcript"]}"
  end
end
