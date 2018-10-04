# Copyright 2018 Google, Inc
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

require "rspec"

describe "Google Translate API samples" do

  # Capture and return STDOUT output by block
  def capture &block
    real_stdout = $stdout
    $stdout     = StringIO.new
    block.call
    @captured_output = $stdout.string
  ensure
    $stdout = real_stdout
  end
  attr_reader :captured_output

  example "translate text" do
    capture do
      # [START translate_translate_text]
      require "google/cloud/translate"

      translate     = Google::Cloud::Translate.new
      text          = "Alice and Bob are kind"
      language_code = "fr"  # The ISO 639-1 code of language to translate to
      translation   = translate.translate text, to: language_code

      puts "Translated '#{text}' to '#{translation.text.inspect}'"
      puts "Original language: #{translation.from} translated to: #{translation.to}"
      # [END translate_translate_text]
    end

    expect(captured_output).to include "Original language: en translated to: fr"
    expect(captured_output).to include(
      %{Translated 'Alice and Bob are kind' to '"Alice et Bob sont gentils"'}
    )
  end

  example "translate text with model" do
    capture do
      # [START translate_text_with_model]
      require "google/cloud/translate"

      translate     = Google::Cloud::Translate.new
      text          = "Alice and Bob are kind"
      language_code = "fr"  # The ISO 639-1 code of language to translate to
      translation   = translate.translate text, to: language_code, model: "nmt"

      puts "Translated '#{text}' to '#{translation.text.inspect}'"
      puts "Original language: #{translation.from} translated to: #{translation.to}"
      # [END translate_text_with_model]
    end

    expect(captured_output).to include "Original language: en translated to: fr"
    expect(captured_output).to include(
      %{Translated 'Alice and Bob are kind' to '"Alice et Bob sont gentils"'}
    )
  end

  example "detect language" do
    expect {
      # [START translate_detect_language]
      require "google/cloud/translate"

      translate = Google::Cloud::Translate.new
      text      = "Sample text written in English"
      detection = translate.detect text

      puts "'#{text}' detected as language: #{detection.language}"
      puts "Confidence: #{detection.confidence}"
      # [END translate_detect_language]
    }.to output(
      /'Sample text written in English' detected as language: en/
    ).to_stdout
  end

  example "list supported language codes" do
    capture do
      # [START translate_list_codes]
      require "google/cloud/translate"

      translate = Google::Cloud::Translate.new
      languages = translate.languages

      puts "Supported language codes:"
      languages.each do |language|
        puts language.code
      end
      # [END translate_list_codes]
    end

    # Check for a few supported language codes (first sorted alphabetically)
    expect(captured_output).to include "af"
    expect(captured_output).to include "am"
    expect(captured_output).to include "ar"
    expect(captured_output).to include "az"
    expect(captured_output).to include "be"
  end

  example "list supported language names" do
    capture do
      # [START translate_list_language_names]
      require "google/cloud/translate"

      translate = Google::Cloud::Translate.new

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

    # Check for a few supported language codes (first sorted alphabetically)
    expect(captured_output).to include "af Afrikaans"
    expect(captured_output).to include "am Amharic"
    expect(captured_output).to include "ar Arabic"
    expect(captured_output).to include "az Azerbaijani"
    expect(captured_output).to include "be Belarusian"
  end
end
