# Copyright 2019 Google, Inc
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

def translate_v3_detect_language
  # [START translate_v3_detect_language]
  require "google/cloud/translate"

  client = Google::Cloud::Translate.new

  project_id  = "[Google Cloud Project ID]"
  location_id = "[LOCATION ID]"
  # The text string for performing language detection
  content     = "Hello, world!"
  # Optional. Can be "text/plain" or "text/html".
  mime_type   = "text/plain"

  parent = client.class.location_path project_id, location_id

  response = client.detect_language parent, content: content, mime_type: mime_type

  # Display list of detected languages sorted by detection confidence.
  # The most probable language is first.
  response.languages.each do |language|
    # The language detected
    puts "Language Code: #{language.language_code}"
    # Confidence of detection result for this language
    puts "Confidence: #{language.confidence}"
  end
  # [END translate_v3_detect_language]
end
