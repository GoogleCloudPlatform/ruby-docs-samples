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

# [START speech_quickstart]
# Imports the Google Cloud client library
# [START speech_require]
require "google/cloud/speech"
# [END speech_require]

# Instantiates a client
# [START speech_create]
speech = Google::Cloud::Speech.new
# [END speech_create]

# The name of the audio file to transcribe
file_name = "./audio_files/audio.raw"

# The raw audio
audio_file = File.binread file_name

# The audio file's encoding and sample rate
config = { encoding: :LINEAR16, sample_rate_hertz: 16000, language_code: "en-US" }
audio  = { content: audio_file }

# Detects speech in the audio file
response = speech.recognize config, audio

# Get first result because we only processed a single audio file
alternatives = response.results.first.alternatives

# Each result represents a consecutive portion of the audio
alternatives.each do |alternatives|
  puts "Transcription: #{alternatives.transcript}"
end
# [END speech_quickstart]

