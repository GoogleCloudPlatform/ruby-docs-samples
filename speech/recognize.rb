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

request        = Google::Apis::SpeechV1beta1::SyncRecognizeRequest.new
request.audio  = { content: File.read(audio_file) }
request.config = { encoding: "LINEAR16", sample_rate: 16000 }

response = speech.syncrecognize_speech request

if response.results
  response.results.each do |recognize_result|
    recognize_result.alternatives.each do |alternative_hypothesis|
      puts "Text: #{alternative_hypothesis.transcript}"
    end
  end
end
