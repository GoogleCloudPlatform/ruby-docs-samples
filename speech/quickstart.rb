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
require "google/cloud"

# Your Google Cloud Platform project ID
project_id = "YOUR_PROJECT_ID"

# Instantiates a client
gcloud = Google::Cloud.new project_id
speech = gcloud.speech

# The name of the audio file to transcribe
fileName = "./audio_files/audio.raw"

# The audio file's encoding and sample rate
audio = speech.audio fileName, encoding: :raw, sample_rate: 16000

# Detects speech in the audio file
results = audio.recognize
result  = results.first

puts "Transcription: #{result.transcript}"
# [END speech_quickstart]

