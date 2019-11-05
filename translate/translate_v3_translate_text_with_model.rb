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

def translate_v3_translate_text_with_model
  # [START translate_v3_translate_text_with_model]
  require "google/cloud/translate"

  client = Google::Cloud::Translate.new

  project_id  = "[Google Cloud Project ID]"
  location_id = "[LOCATION ID]"
  model_id    = "[MODEL ID]"

  # The `model` type requested for this translation.
  model           = "projects/#{project_id}/locations/#{location_id}/models/#{model_id}"
  # The content to translate in string format
  contents        = ["Hello, world!"]
  # Required. The BCP-47 language code to use for translation.
  target_language = "fr"
  # Optional. The BCP-47 language code of the input text.
  source_language = "en"
  # Optional. Can be "text/plain" or "text/html".
  mime_type       = "text/plain"
  parent          = client.class.location_path project_id, location_id

  response = client.translate_text(
    contents, target_language, parent,
    source_language_code: source_language,
    model:                model,
    mime_type:            mime_type
  )

  # Display the translation for each input text provided
  response.translations.each do |translation|
    puts "Translated text: #{translation.translated_text}"
  end
  # [END translate_v3_translate_text_with_model]
end
