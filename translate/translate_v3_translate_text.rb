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

def translate_v3_translate_text
  # [START translate_v3_translate_text]
  require "google/cloud/translate"

  client = Google::Cloud::Translate.new

  project = "[Google Cloud Project ID]"

  # The content to translate in string format
  contents        = ["Hello, world!"]
  # Required. The BCP-47 language code to use for translation.
  target_language = "fr"
  parent          = client.class.location_path project, "global"

  response = client.translate_text contents, target_language, parent

  # Display the translation for each input text provided
  response.translations.each do |translation|
    puts "Translated text: #{translation.translated_text}"
  end
  # [END translate_v3_translate_text]
end
