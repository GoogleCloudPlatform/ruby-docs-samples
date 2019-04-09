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

def translate_text project_id:, text:, language_code:
  # [START translate_translate_text]
  # project_id    = "Your Google Cloud project ID"
  # text          = "The text you would like to translate"
  # language_code = "The ISO 639-1 code of language to translate to, eg. 'en'"

  require "google/cloud/translate"

  translate   = Google::Cloud::Translate.new project: project_id
  translation = translate.translate text, to: language_code

  puts "Translated '#{text}' to '#{translation.text.inspect}'"
  puts "Original language: #{translation.from} translated to: #{translation.to}"
  # [END translate_translate_text]
end

def translate_text_with_model project_id:, text:, language_code:
  # [START translate_text_with_model]
  # project_id    = "Your Google Cloud project ID"
  # text          = "The text you would like to translate"
  # language_code = "The ISO 639-1 code of language to translate to, eg. 'en'"

  require "google/cloud/translate"

  translate   = Google::Cloud::Translate.new project: project_id
  translation = translate.translate text, to: language_code, model: "nmt"

  puts "Translated '#{text}' to '#{translation.text.inspect}'"
  puts "Original language: #{translation.from} translated to: #{translation.to}"
  # [END translate_text_with_model]
end

def detect_language project_id:, text:
  # [START translate_detect_language]
  # project_id = "Your Google Cloud project ID"
  # text       = "The text you would like to detect the language of"

  require "google/cloud/translate"

  translate = Google::Cloud::Translate.new project: project_id
  detection = translate.detect text

  puts "'#{text}' detected as language: #{detection.language}"
  puts "Confidence: #{detection.confidence}"
  # [END translate_detect_language]
end

def list_supported_language_codes project_id:
  # [START translate_list_codes]
  # project_id = "Your Google Cloud project ID"

  require "google/cloud/translate"

  translate = Google::Cloud::Translate.new project: project_id
  languages = translate.languages

  puts "Supported language codes:"
  languages.each do |language|
    puts language.code
  end
  # [END translate_list_codes]
end

def list_supported_language_names project_id:, language_code: "en"
  # [START translate_list_language_names]
  # project_id = "Your Google Cloud project ID"

  # To receive the names of the supported languages, provide the code
  # for the language in which you wish to receive the names
  # language_code = "en"

  require "google/cloud/translate"

  translate = Google::Cloud::Translate.new project: project_id
  languages = translate.languages language_code

  puts "Supported languages:"
  languages.each do |language|
    puts "#{language.code} #{language.name}"
  end
  # [END translate_list_language_names]
end

if $PROGRAM_NAME == __FILE__
  project_id = ENV["GOOGLE_CLOUD_PROJECT"]
  command    = ARGV.shift

  case command
  when "translate"
    translate_text project_id:    project_id,
                   language_code: ARGV.shift,
                   text:          ARGV.shift
  when "translate_premium"
    translate_text_with_model project_id:    project_id,
                              language_code: ARGV.shift,
                              text:          ARGV.shift
  when "detect_language"
    detect_language project_id: project_id,
                    text:       ARGV.shift
  when "list_codes"
    list_supported_language_codes project_id: project_id
  when "list_names"
    list_supported_language_names project_id:    project_id,
                                  language_code: ARGV.shift
  else
    puts <<~USAGE
      Usage: ruby translate_samples.rb <command> [arguments]

      Commands:
        translate           <desired-language-code> <text>
        translate_premium   <desired-language-code> <text>
        detect_language     <text>
        list_names          <language-code-for-display>
        list_codes

      Examples:
        ruby translate_samples.rb translate fr "Hello World"
        ruby translate_samples.rb translate_premium fr "Hello World"
        ruby translate_samples.rb detect_language "Hello World"
        ruby translate_samples.rb list_codes
        ruby translate_samples.rb list_names en
    USAGE
  end
end
