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

def translate_v3_translate_text project_id:, text: "Hello, world!", target_language: "fr"
  # Store the method arguments to be set later on.
  sample_original_args = { project_id: project_id, text: text, target_language: target_language }

  # [START translate_v3_translate_text]
  require "google/cloud/translate"

  client = Google::Cloud::Translate.new

  project_id = "[Google Cloud Project ID]"

  # The content to translate in string format
  text = "Hello, world!"
  # Required. The BCP-47 language code to use for translation.
  target_language = "fr"
  # [END translate_v3_translate_text]
  # Set the real values for these variables from the method arguments.
  project_id      = sample_original_args[:project_id]
  text            = sample_original_args[:text]
  target_language = sample_original_args[:target_language]
  # [START translate_v3_translate_text]
  parent = client.class.location_path project_id, "global"
  contents = [text]

  response = client.translate_text contents, target_language, parent

  # Display the translation for each input text provided
  response.translations.each do |translation|
    puts "Translated text: #{translation.translated_text}"
  end
  # [END translate_v3_translate_text]
end

if $PROGRAM_NAME == __FILE__
  # Code below processes command-line arguments to execute this code sample.
  args = {}

  require "optparse"
  ARGV.options do |opts|
    opts.on("--project_id=val")      { |val| args[:project_id] = val }
    opts.on("--text_content=val")    { |val| args[:text] = val }
    opts.on("--target_language=val") { |val| args[:target_language] = val }
    opts.parse!
  end

  translate_v3_translate_text args
end
