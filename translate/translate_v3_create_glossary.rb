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

def translate_v3_create_glossary
  # [START translate_v3_create_glossary]
  require "google/cloud/translate"

  client = Google::Cloud::Translate.new

  project_id = "[Google Cloud Project ID]"
  location_id = "[LOCATION ID]"
  glossary_id = "your-glossary-display-name"

  project_2 = "[Your Google Cloud Project ID]"
  input_uri = "gs://translation_samples_beta/glossaries/glossary.csv"

  parent = client.class.location_path project_id, location_id
  glossary = {
    name:               client.class.glossary_path(project_2, location_id, glossary_id),
    language_codes_set: {
      language_codes: ["en", "ja"]
    },
    input_config:       {
      gcs_source: {
        input_uri: input_uri
      }
    }
  }

  operation = client.create_glossary parent, glossary

  # Wait until the long running operation is done
  operation.wait_until_done!
  response = operation.response

  puts "Created Glossary."
  puts "Glossary name: #{response.name}"
  puts "Entry count: #{response.entry_count}"
  puts "Input URI: #{response.input_config.gcs_source.input_uri}"
  # [END translate_v3_create_glossary]
end
