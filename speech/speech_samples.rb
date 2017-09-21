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

def speech_sync_recognize audio_file_path: nil
# [START speech_sync_recognize]
  # audio_file_path = "Path to file on which to perform speech recognition"

  require "google/cloud/speech"

  speech = Google::Cloud::Speech.new

  audio_file = File.binread audio_file_path
  config     = { encoding: :LINEAR16, sample_rate_hertz: 16000, language_code: "en-US" }
  audio      = { content: audio_file }

  response = speech.recognize config, audio

  alternatives = response.results.first.alternatives

  alternatives.each do |alternative|
    puts "Transcription: #{alternative.transcript}"
  end
# [END speech_sync_recognize]
end

def speech_sync_recognize_words audio_file_path: nil
# [START speech_sync_recognize_words]
  # audio_file_path = "Path to file on which to perform speech recognition"

  require "google/cloud/speech"

  speech = Google::Cloud::Speech.new

  audio_file = File.binread audio_file_path
  config     = { encoding: :LINEAR16, sample_rate_hertz: 16000, language_code: "en-US", enable_word_time_offsets: true }
  audio      = { content: audio_file }

  response = speech.recognize config, audio

  alternatives = response.results.first.alternatives

  alternatives.each do |alternative|
    puts "Transcription: #{alternative.transcript}"

    alternative.words.each do |word|
      start_time = word.start_time.seconds + word.start_time.nanos/1000000000.0
      end_time   = word.end_time.seconds + word.end_time.nanos/1000000000.0

      puts "Word: #{word.word} #{start_time} #{end_time}"
    end
  end
# [END speech_sync_recognize_words]
end

def speech_sync_recognize_gcs storage_path: nil
# [START speech_sync_recognize_gcs]
  # storage_path = "Path to file in Cloud Storage, eg. gs://bucket/audio.raw"

  require "google/cloud/speech"

  speech = Google::Cloud::Speech.new

  config = { encoding: :LINEAR16, sample_rate_hertz: 16000, language_code: "en-US" }
  audio  = { uri: storage_path }

  response = speech.recognize config, audio

  alternatives = response.results.first.alternatives

  alternatives.each do |alternative|
    puts "Transcription: #{alternative.transcript}"
  end
# [END speech_sync_recognize_gcs]
end

def speech_async_recognize audio_file_path: nil
# [START speech_async_recognize]
  # audio_file_path = "Path to file on which to perform speech recognition"

  require "google/cloud/speech"

  speech = Google::Cloud::Speech.new

  audio_file = File.binread audio_file_path
  config     = { encoding: :LINEAR16, sample_rate_hertz: 16000, language_code: "en-US" }
  audio      = { content: audio_file }

  operation = speech.long_running_recognize config, audio

  puts "Operation started"

  operation.wait_until_done!

  raise operation.results.message if operation.error?

  alternatives = operation.response.results.first.alternatives

  alternatives.each do |alternative|
    puts "Transcription: #{alternative.transcript}"
  end
# [END speech_async_recognize]
end

def speech_async_recognize_gcs storage_path: nil
# [START speech_async_recognize_gcs]
  # storage_path = "Path to file in Cloud Storage, eg. gs://bucket/audio.raw"

  require "google/cloud/speech"

  speech = Google::Cloud::Speech.new

  config = { encoding: :LINEAR16, sample_rate_hertz: 16000, language_code: "en-US" }
  audio  = { uri: storage_path }

  operation = speech.long_running_recognize config, audio

  puts "Operation started"

  operation.wait_until_done!

  raise operation.results.message if operation.error?

  alternatives = operation.response.results.first.alternatives

  alternatives.each do |alternative|
    puts "Transcription: #{alternative.transcript}"
  end
# [END speech_async_recognize_gcs]
end

def speech_async_recognize_gcs_words storage_path: nil
# [START speech_async_recognize_gcs_words]
  # storage_path = "Path to file in Cloud Storage, eg. gs://bucket/audio.raw"

  require "google/cloud/speech"

  speech = Google::Cloud::Speech.new

  config = { encoding: :LINEAR16, sample_rate_hertz: 16000, language_code: "en-US", enable_word_time_offsets: true }
  audio  = { uri: storage_path }

  operation = speech.long_running_recognize config, audio

  puts "Operation started"

  operation.wait_until_done!

  raise operation.results.message if operation.error?

  alternatives = operation.response.results.first.alternatives

  alternatives.each do |alternative|
    puts "Transcription: #{alternative.transcript}"

    alternative.words.each do |word|
      start_time = word.start_time.seconds + word.start_time.nanos/1000000000.0
      end_time   = word.end_time.seconds + word.end_time.nanos/1000000000.0

      puts "Word: #{word.word} #{start_time} #{end_time}"
    end
  end
# [END speech_async_recognize_gcs_words]
end

def speech_streaming_recognize_sync audio_file_path: nil
# [START speech_streaming]
  # audio_file_path = "Path to file on which to perform speech recognition"

  require "google/cloud/speech"

  speech = Google::Cloud::Speech.new

  audio_content = File.binread audio_file_path
  bytes_total   = audio_content.size
  bytes_sent    = 0
  chunk_size    = 32000
  final_result  = []

  requests = Enumerator.new do |enum|
    streaming_config = {config:{encoding:                :LINEAR16,
                                sample_rate_hertz:       16000,
                                language_code:           "en-US",
                                enable_word_time_offsets: true     }}
    enum << {streaming_config: streaming_config}

    while bytes_sent < bytes_total do
      enum << {audio_content: audio_content[bytes_sent, chunk_size]}
      bytes_sent += chunk_size
      sleep 1
    end
  end

  responses = speech.streaming_recognize requests
  responses.each do |response|
    response.results.each do |result|
      result.alternatives.each do |alternative|
        final_result << alternative.transcript if result.is_final
      end
    end
  end

  puts final_result.join " "
# [END speech_streaming]
end

class EnumeratorQueue
  extend Forwardable
  def_delegators :@q, :push

  # @private
  def initialize sentinel
    @q = Queue.new
    @sentinel = sentinel
  end

  # @private
  def each_item
    return enum_for(:each_item) unless block_given?
    loop do
      r = @q.pop
      break if r.equal? @sentinel
      fail r if r.is_a? Exception
      yield r
    end
  end
end

def speech_streaming_recognize audio_file_path: nil
# [START speech_streaming]
  # audio_file_path = "Path to file on which to perform speech recognition"

  require "google/cloud/speech"
  require "monitor"

  speech = Google::Cloud::Speech.new

  audio_content  = File.binread audio_file_path
  bytes_total    = audio_content.size
  bytes_sent     = 0
  chunk_size     = 32000
  final_results  = []


  streaming_config = {config: {encoding:                :LINEAR16,
                               sample_rate_hertz:       16000,
                               language_code:           "en-US",
                               enable_word_time_offsets: true     },
                      interim_results: true}

  completed      = false
  request_queue  = EnumeratorQueue.new(speech)
  request_queue.push({streaming_config: streaming_config})

  # Thread waits for responses from a request
  Thread.new do
    # Errors are ignored in this sample
    speech.streaming_recognize(request_queue.each_item).each do |response|
      response.results.each do |result|
        result.alternatives.each do |alternative|
          # print interim results and save the final result
          puts alternative.transcript
          final_results << alternative if result.is_final
        end
      end
    end

    completed = true
  end

  while bytes_sent < bytes_total do
    request_queue.push({audio_content: audio_content[bytes_sent, chunk_size]})
    bytes_sent += chunk_size
    sleep 1
  end

  # Equivalent to done in veneer
  puts "Stopped passing"
  request_queue.push(speech)

  # Equivalent to wait_until_complete!
  loop do
    break if completed
    sleep 1
  end

  final_results.each do |result|
    puts "Transcript: #{result.transcript}"
  end
  # [END speech_streaming]
end

require "google/cloud/speech"

if __FILE__ == $PROGRAM_NAME
  command    = ARGV.shift

  case command
  when "recognize"
    speech_sync_recognize audio_file_path: ARGV.first
  when "recognize_words"
    speech_sync_recognize_words audio_file_path: ARGV.first
  when "recognize_gcs"
    speech_sync_recognize_gcs storage_path: ARGV.first
  when "async_recognize"
    speech_async_recognize audio_file_path: ARGV.first
  when "async_recognize_gcs"
    speech_async_recognize_gcs storage_path: ARGV.first
  when "async_recognize_gcs_words"
    speech_async_recognize_gcs_words storage_path: ARGV.first
  when "stream_recognize"
    speech_streaming_recognize audio_file_path: ARGV.first
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
    usage
  end
end
