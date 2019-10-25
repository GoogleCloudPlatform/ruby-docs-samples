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

def translate_v3_batch_translate_text_with_glossary_and_model
  # [START translate_v3_batch_translate_text_with_glossary_and_model]
  require "google/cloud/translate"

  client = Google::Cloud::Translate.new

  input_uri = "gs://cloud-samples-data/text.txt"
  output_uri = "gs://YOUR_BUCKET_ID/path_to_store_results/"
  project_id = "[Google Cloud Project ID]"
  location_id = "us-central1"
  source_lang = "en"
  target_lang = "ja"

  input_config = {
    gcs_source: {
      input_uri: input_uri
    },
    # Optional. Can be "text/plain" or "text/html".
    mime_type:  "text/plain"
  }
  output_config = {
    gcs_destination: {
      output_uri_prefix: output_uri
    }
  }
  parent = client.class.location_path project_id, location_id
  # The models to use for translation. Map's key is target language code.
  models = {
    target_lang => "projects/[PROJECT_ID]/locations/[LOCATION]/models/[YOUR_MODEL_ID]"
  }
  glossaries = {
    target_lang => Google::Cloud::Translate::V3::TranslateTextGlossaryConfig.new(
      # Required. Specifies the glossary used for this translation.
      glossary: "projects/[PROJECT_ID]/locations/[LOCATION]/glossaries/[YOUR_GLOSSARY_ID]"
    )
  }

  operation = client.batch_translate_text(
    parent, source_lang, [target_lang], [input_config], output_config,
    models:     models,
    glossaries: glossaries
  )

  # Wait until the long running operation is done
  operation.wait_until_done!

  response = operation.response

  puts "Total Characters: #{response.total_characters}"
  puts "Translated Characters: #{response.translated_characters}"
  # [END translate_v3_batch_translate_text_with_glossary_and_model]
end
