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

def translate_text project_id:
  # [START translate_translate_text]
  # TODO(developer): Uncomment this line and replace with your Project ID.
  # project_id = "your-project-id"

  require "google/cloud/translate"

  translate     = Google::Cloud::Translate.new project: project_id
  text          = "Alice and Bob are kind"
  language_code = "fr"  # The ISO 639-1 code of language to translate to
  translation   = translate.translate text, to: language_code

  puts "Translated '#{text}' to '#{translation.text.inspect}'"
  puts "Original language: #{translation.from} translated to: #{translation.to}"
  # [END translate_translate_text]
end

def translate_text_with_model project_id:
  # [START translate_text_with_model]
  # TODO(developer): Uncomment this line and replace with your Project ID.
  # project_id = "your-project-id"

  require "google/cloud/translate"

  translate     = Google::Cloud::Translate.new project: project_id
  text          = "Alice and Bob are kind"
  language_code = "fr"  # The ISO 639-1 code of language to translate to
  translation   = translate.translate text, to: language_code, model: "nmt"

  puts "Translated '#{text}' to '#{translation.text.inspect}'"
  puts "Original language: #{translation.from} translated to: #{translation.to}"
  # [END translate_text_with_model]
end

def detect_language project_id:
  # [START translate_detect_language]
  # TODO(developer): Uncomment this line and replace with your Project ID.
  # project_id = "your-project-id"

  require "google/cloud/translate"

  translate = Google::Cloud::Translate.new project: project_id
  text      = "Sample text written in English"
  detection = translate.detect text

  puts "'#{text}' detected as language: #{detection.language}"
  puts "Confidence: #{detection.confidence}"
  # [END translate_detect_language]
end

def list_supported_language_codes project_id:
  # [START translate_list_codes]
  # TODO(developer): Uncomment this line and replace with your Project ID.
  # project_id = "your-project-id"

  require "google/cloud/translate"

  translate = Google::Cloud::Translate.new project: project_id
  languages = translate.languages

  puts "Supported language codes:"
  languages.each do |language|
    puts language.code
  end
  # [END translate_list_codes]
end

def list_supported_language_names project_id:
  # [START translate_list_language_names]
  # TODO(developer): Uncomment this line and replace with your Project ID.
  # project_id = "your-project-id"

  require "google/cloud/translate"

  translate = Google::Cloud::Translate.new project: project_id

  # To receive the names of the supported languages, provide the code
  # for the language in which you wish to receive the names
  language_code = "en"
  languages     = translate.languages language_code

  puts "Supported languages:"
  languages.each do |language|
    puts "#{language.code} #{language.name}"
  end
  # [END translate_list_language_names]
end
