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

def translate_v3_get_glossary
  # [START translate_v3_get_glossary]
  require "google/cloud/translate"

  client = Google::Cloud::Translate.new

  project_id  = "[Google Cloud Project ID]"
  location_id = "[LOCATION ID]"
  glossary_id = "[YOUR_GLOSSARY_ID]"

  name = client.class.glossary_path project_id, location_id, glossary_id

  response = client.get_glossary name

  puts "Glossary name: #{response.name}"
  puts "Entry count: #{response.entry_count}"
  puts "Input URI: #{response.input_config.gcs_source.input_uri}"
  # [END translate_v3_get_glossary]
end
