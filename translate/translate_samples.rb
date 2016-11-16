# Copyright 2016 Google, Inc
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in write, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

def translate_text project_id:, text:, language_code:
  # [START translate_text]
  # project_id   = "Your Google Cloud project ID"
  # text          = "The text you would like to translate"
  # language_code = "The ISO 639-1 code of language to translate to, eg. 'en'"

  require "google/cloud"

  gcloud      = Google::Cloud.new project_id
  translate   = gcloud.translate
  translation = translate.translate text, to: language_code

  puts "Translated '#{text}' to '#{translation.text.inspect}'"
  puts "Original language: #{translation.from} translated to: #{translation.to}"
  # [END translate_text]
end

def detect_language project_id:, text:
  # [START detect_language]
  # project_id   = "Your Google Cloud project ID"
  # text    = "The text you would like to detect the language of"

  require "google/cloud"

  gcloud    = Google::Cloud.new project_id
  translate = gcloud.translate
  detection = translate.detect text

  puts "'#{text}' detected as language: #{detection.language}"
  puts "Confidence: #{detection.confidence}"
  # [END detect_language]
end

def list_supported_language_codes project_id:
  # [START list_supported_language_codes]
  # project_id   = "Your Google Cloud project ID"

  require "google/cloud"

  gcloud    = Google::Cloud.new project_id
  translate = gcloud.translate
  languages = translate.languages

  puts "Supported language codes:"
  languages.each do |language|
    puts language.code
  end
  # [END list_supported_language_codes]
end

def list_supported_language_names project_id:, language_code: "en"
  # [START list_supported_language_names]
  # project_id   = "Your Google Cloud project ID"

  # To receive the names of the supported languages, provide the code
  # for the language in which you wish to receive the names
  # language_code = "en"

  require "google/cloud"

  gcloud    = Google::Cloud.new project_id
  translate = gcloud.translate
  languages = translate.languages language_code

  puts "Supported languages:"
  languages.each do |language|
    puts "#{language.code} #{language.name}"
  end
  # [END list_supported_language_names]
end

if __FILE__ == $PROGRAM_NAME
  project_id = ENV["GOOGLE_CLOUD_PROJECT"]
  command = ARGV.shift

  case command
  when "translate"
    translate_text project_id: project_id,
                   language_code: ARGV.shift,
                   text:          ARGV.shift
  when "detect_language"
    detect_language project_id: project_id,
                    text: ARGV.shift
  when "list_codes"
    list_supported_language_codes project_id: project_id
  when "list_names"
    list_supported_language_names project_id: project_id,
                                  language_code: ARGV.shift
  else
    puts <<-usage
Usage: ruby translate_samples.rb <command> [arguments]

Commands:
  translate       <desired-language-code> <text>
  detect_language <text>
  list_names      <language-code-for-display>
  list_codes

Examples:
  ruby translate_samples.rb translate fr "Hello World"
  ruby translate_samples.rb detect_language "Hello World"
  ruby translate_samples.rb list_codes
  ruby translate_samples.rb list_names en
    usage
  end
end
