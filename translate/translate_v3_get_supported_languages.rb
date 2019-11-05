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

def translate_v3_get_supported_languages
  # [START translate_v3_get_supported_languages]
  require "google/cloud/translate"

  client = Google::Cloud::Translate.new

  project_id  = "[Google Cloud Project ID]"
  location_id = "[LOCATION ID]"

  parent = client.class.location_path project_id, location_id

  response = client.get_supported_languages parent

  # List language codes of supported languages
  response.languages.each do |language|
    puts "Language Code: #{language.language_code}"
  end
  # [END translate_v3_get_supported_languages]
end
