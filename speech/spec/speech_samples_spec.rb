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

require_relative "../speech_samples"
require "rspec"

describe "Google Cloud Speech API samples" do

  before do
    # Path to RAW audio file with sample rate of 16000 using LINEAR16 encoding
    @audio_file_path = File.expand_path "../audio_files/audio.raw", __dir__

    # Expected transcript of spoken English recorded in the audio.raw file
    @audio_file_transcript = "how old is the Brooklyn Bridge"
  end

  # Capture and return STDOUT output by block
  def capture &block
    real_stdout = $stdout
    $stdout = StringIO.new
    block.call
    @captured_output = $stdout.string
  ensure
    $stdout = real_stdout
  end
  attr_reader :captured_output

  example "transcribe audio file" do
    expect {
      transcript_from_audio_file audio_file_path: @audio_file_path
    }.to output("Text: #{@audio_file_transcript}\n").to_stdout
  end

  example "begin async operation to transcribe audio file" do
    expect {
      begin_async_operation audio_file_path: @audio_file_path
    }.to output(/Operation identifier: \d+/).to_stdout
  end

  example "get results of async operation to transcribe audio file" do
    capture do
      begin_async_operation audio_file_path: @audio_file_path
    end

    name = captured_output.match(/Operation identifier: (\d+)/).captures.first

    # TODO: Remove use of `sleep` and Update to use wait_until with timeout
    sleep 1

    capture { get_async_operation_results operation_name: name }

    unless captured_output.include? "Operation complete: true"
      sleep 5
      capture { get_async_operation_results operation_name: name }
    end

    expect(captured_output).to include "Operation complete: true"
    expect(captured_output).to include "Text: #{@audio_file_transcript}"
  end

end
