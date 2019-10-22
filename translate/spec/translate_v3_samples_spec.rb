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

Dir.glob("translate_v3_*.rb").each { |sample| require_relative "../#{sample}" }

require "rspec"
require "google/cloud/translate"
require "google/cloud/translate/v3"
require "google/cloud/storage"
require "securerandom"

describe "Google Translate API samples (V3)" do
  let(:uuid)            { SecureRandom.uuid }
  let(:translate)       { Google::Cloud::Translate::V3::TranslationServiceClient.new }
  let(:credentials)     { Google::Cloud::Translate::V3::Credentials.default }
  let(:project_id)      { credentials.project_id }
  let(:location_id)     { "us-central1" }
  let(:glossary_id)     { "glossary-#{uuid}" }
  let(:glossary_uri)    { "gs://cloud-samples-data/translation/glossary_ja.csv" }
  let(:model_id)        { ENV["AUTOML_TRANSLATION_MODEL_ID"] }
  let(:storage)         { Google::Cloud::Storage.new }
  let(:bucket)          { ENV["TRANSLATE_BUCKET"] }
  let(:client_double) do
    client = double("translate")
    allow(client.class).to receive(:location_path) { "location_path" }
    allow(client.class).to receive(:glossary_path) { "glossary_path" }
    client
  end

  def create_glossary!
    parent   = translate.class.location_path project_id, location_id
    name     = translate.class.glossary_path project_id, location_id, glossary_id
    glossary = { name: name,
                 language_codes_set: { language_codes: ["en", "ja"] },
                 input_config: { gcs_source: { input_uri: glossary_uri } }
               }

    operation = translate.create_glossary parent, glossary
    operation.wait_until_done!
  end

  def delete_glossary!
    name = translate.class.glossary_path project_id, location_id, glossary_id

    operation = translate.delete_glossary name
    operation.wait_until_done!
  end

  def ensure_storage_setup! bucket_name, file_name, text
    b = storage.bucket(bucket_name) || storage.create_bucket(bucket_name)
    f = b.file(file_name) || b.create_file(StringIO.new(text), file_name)
  end

  example "Translating Text", :translate_v3_translate_text do
    text = "Hello, world!"
    target_language = "fr"
    parent = translate.class.location_path project_id, "global"

    response = translate.translate_text [text], target_language, parent

    allow(Google::Cloud::Translate).to receive(:new).and_return(client_double)
    allow(client_double).to receive(:translate_text).and_return(response)

    expect do
      translate_v3_translate_text
    end.to output("Translated text: Bonjour le monde!\n").to_stdout
  end

  example "Translating Text with Glossary", :translate_v3_translate_text_with_glossary do
    text = "Hello, world!"
    target_language = "fr"
    source_language = "en"
    parent = translate.class.location_path project_id, location_id
    glossary_config = { glossary: translate.class.glossary_path(project_id, location_id, glossary_id) }

    create_glossary!

    response = translate.translate_text [text], target_language, parent,
      glossary_config: glossary_config, source_language_code: source_language, mime_type: "text/plain"

    delete_glossary!

    allow(Google::Cloud::Translate).to receive(:new).and_return(client_double)
    allow(client_double).to receive(:translate_text).and_return(response)

    expect do
      translate_v3_translate_text_with_glossary
    end.to output("Translated text: Bonjour le monde!\n").to_stdout
  end

  example "Translating Text with Glossary and Model", :translate_v3_translate_text_with_glossary_and_model do
    skip "AUTOML_TRANSLATION_MODEL_ID not set" if model_id.nil?

    text = "Hello, world!"
    target_language = "ja"
    source_language = "en"
    parent = translate.class.location_path project_id, location_id
    model = "projects/#{project_id}/locations/#{location_id}/models/#{model_id}"
    glossary_config = { glossary: translate.class.glossary_path(project_id, location_id, glossary_id) }

    create_glossary!

    response = translate.translate_text [text], target_language, parent,
      model: model, glossary_config: glossary_config,
      source_language_code: source_language, mime_type: "text/plain"

    delete_glossary!

    allow(Google::Cloud::Translate).to receive(:new).and_return(client_double)
    allow(client_double).to receive(:translate_text).and_return(response)

    expect do
      translate_v3_translate_text_with_glossary_and_model
    end.to output("Translated text: こんにちは、世界！\n").to_stdout
  end

  example "Translating Text with Model", :translate_v3_translate_text_with_model do
    skip "AUTOML_TRANSLATION_MODEL_ID not set" if model_id.nil?

    text = "Hello, world!"
    target_language = "ja"
    source_language = "en"
    parent = translate.class.location_path project_id, location_id
    model = "projects/#{project_id}/locations/#{location_id}/models/#{model_id}"

    response = translate.translate_text [text], target_language, parent,
      model: model, source_language_code: source_language, mime_type: "text/plain"

    allow(Google::Cloud::Translate).to receive(:new).and_return(client_double)
    allow(client_double).to receive(:translate_text).and_return(response)

    expect do
      translate_v3_translate_text_with_model
    end.to output("Translated text: こんにちは、世界！\n").to_stdout
  end

  example "Get Glossary", :translate_v3_get_glossary do
    name = translate.class.glossary_path project_id, location_id, glossary_id

    create_glossary!

    response = translate.get_glossary name

    delete_glossary!

    allow(Google::Cloud::Translate).to receive(:new).and_return(client_double)
    allow(client_double).to receive(:get_glossary).and_return(response)

    expect do
      translate_v3_get_glossary
    end.to output("Glossary name: #{response.name}\nEntry count: #{response.entry_count}\nInput URI: #{response.input_config.gcs_source.input_uri}\n").to_stdout
  end

  example "Create Glossary", :translate_v3_create_glossary do
    parent = translate.class.location_path project_id, location_id
    glossary = {
      name: translate.class.glossary_path(project_id, location_id, glossary_id),
      language_codes_set: {
        language_codes: ["en", "ja"]
      },
      input_config: {
        gcs_source: {
          input_uri: glossary_uri
        }
      }
    }

    operation = translate.create_glossary parent, glossary
    operation.wait_until_done!
    response = operation.response

    allow(Google::Cloud::Translate).to receive(:new).and_return(client_double)
    allow(client_double).to receive(:create_glossary).and_return(operation)

    expect do
      translate_v3_create_glossary
      delete_glossary!
    end.to output("Created Glossary.\nGlossary name: #{response.name}\nEntry count: #{response.entry_count}\nInput URI: #{response.input_config.gcs_source.input_uri}\n").to_stdout
  end

  example "Delete Glossary", :translate_v3_delete_glossary do
    name = translate.class.glossary_path project_id, location_id, glossary_id

    create_glossary!

    operation = translate.delete_glossary name
    operation.wait_until_done!
    response = operation.response

    allow(Google::Cloud::Translate).to receive(:new).and_return(client_double)
    allow(client_double).to receive(:delete_glossary).and_return(operation)

    expect do
      translate_v3_delete_glossary
    end.to output("Deleted Glossary.\n").to_stdout
  end

  example "List Glossaries", :translate_v3_list_glossary do
    parent = translate.class.location_path project_id, location_id

    create_glossary!

    responses = translate.list_glossaries parent

    delete_glossary!

    allow(Google::Cloud::Translate).to receive(:new).and_return(client_double)
    allow(client_double).to receive(:list_glossaries).and_return(responses)

    expected_output = responses.map { |response| "Glossary name: #{response.name}\nEntry count: #{response.entry_count}\nInput URI: #{response.input_config.gcs_source.input_uri}\n" }.join ""

    expect do
      translate_v3_list_glossary
    end.to output(expected_output).to_stdout
  end

  example "Getting a list of supported language codes", :translate_v3_get_supported_languages do
    parent = translate.class.location_path project_id, location_id

    response = translate.get_supported_languages parent

    allow(Google::Cloud::Translate).to receive(:new).and_return(client_double)
    allow(client_double).to receive(:get_supported_languages).and_return(response)

    expected_output = response.languages.map { |language| "Language Code: #{language.language_code}\n" }.join ""

    expect do
      translate_v3_get_supported_languages
    end.to output(expected_output).to_stdout
  end

  example "Listing supported languages with target language name", :translate_v3_get_supported_languages_for_target do
    parent = translate.class.location_path project_id, location_id

    response = translate.get_supported_languages parent, display_language_code: "en"

    allow(Google::Cloud::Translate).to receive(:new).and_return(client_double)
    allow(client_double).to receive(:get_supported_languages).and_return(response)

    expected_output = response.languages.map { |language| "Language Code: #{language.language_code}\nDisplay Name: #{language.display_name}\n" }.join ""

    expect do
      translate_v3_get_supported_languages_for_target
    end.to output(expected_output).to_stdout
  end

  example "Detecting the language of a text string", :translate_v3_detect_language do
    content = "Hello, world!"
    # Optional. Can be "text/plain" or "text/html".
    mime_type = "text/plain"
    parent = translate.class.location_path project_id, location_id

    response = translate.detect_language parent, content: content, mime_type: mime_type

    allow(Google::Cloud::Translate).to receive(:new).and_return(client_double)
    allow(client_double).to receive(:detect_language).and_return(response)

    expected_output = response.languages.map { |language| "Language Code: #{language.language_code}\nConfidence: #{language.confidence}\n" }.join ""

    expect do
      translate_v3_detect_language
    end.to output(expected_output).to_stdout
  end

  example "Batch Translate Text", :translate_v3_batch_translate_text do
    skip "TRANSLATE_BUCKET not set" if bucket.nil?

    ensure_storage_setup! bucket, "text.txt", "Hello, world!"

    input_uri = "gs://#{bucket}/text.txt"
    output_uri = "gs://#{bucket}/results/#{uuid}/"
    source_lang = "en"
    target_lang = "ja"

    input_config = {
      gcs_source: {
        input_uri: input_uri
      },
      # Optional. Can be "text/plain" or "text/html".
      mime_type: "text/plain"
    }
    output_config = {
      gcs_destination: {
        output_uri_prefix: output_uri
      }
    }
    parent = translate.class.location_path project_id, location_id

    operation = translate.batch_translate_text \
      parent, source_lang, [target_lang], [input_config], output_config
    operation.wait_until_done!
    response = operation.response

    allow(Google::Cloud::Translate).to receive(:new).and_return(client_double)
    allow(client_double).to receive(:batch_translate_text).and_return(operation)

    expect do
      translate_v3_batch_translate_text
    end.to output("Total Characters: 13\nTranslated Characters: 13\n").to_stdout
  end

  example "Batch Translate Text with Glossary a given URI using a glossary", :translate_v3_batch_translate_text_with_glossary do
    skip "TRANSLATE_BUCKET not set" if bucket.nil?

    ensure_storage_setup! bucket, "text.txt", "Hello, world!"
    create_glossary!

    input_uri = "gs://#{bucket}/text.txt"
    output_uri = "gs://#{bucket}/results/#{uuid}/"
    source_lang = "en"
    target_lang = "ja"

    input_config = {
      gcs_source: {
        input_uri: input_uri
      },
      # Optional. Can be "text/plain" or "text/html".
      mime_type: "text/plain"
    }
    output_config = {
      gcs_destination: {
        output_uri_prefix: output_uri
      }
    }
    parent = translate.class.location_path project_id, location_id
    glossaries = {
      "ja" => Google::Cloud::Translate::V3::TranslateTextGlossaryConfig.new(
        # Required. Specifies the glossary used for this translation.
        glossary: "projects/#{project_id}/locations/#{location_id}/glossaries/#{glossary_id}"
      )
    }

    operation = translate.batch_translate_text \
      parent, source_lang, [target_lang], [input_config], output_config,
      glossaries: glossaries
    operation.wait_until_done!
    response = operation.response

    delete_glossary!

    allow(Google::Cloud::Translate).to receive(:new).and_return(client_double)
    allow(client_double).to receive(:batch_translate_text).and_return(operation)

    expect do
      translate_v3_batch_translate_text_with_glossary
    end.to output("Total Characters: 13\nTranslated Characters: 13\n").to_stdout
  end

  example "Batch Translate Text using AutoML Translation Model", :translate_v3_batch_translate_text_with_model do
    skip "TRANSLATE_BUCKET not set" if bucket.nil?
    skip "AUTOML_TRANSLATION_MODEL_ID not set" if model_id.nil?

    ensure_storage_setup! bucket, "text.txt", "Hello, world!"

    input_uri = "gs://#{bucket}/text.txt"
    output_uri = "gs://#{bucket}/results/#{uuid}/"
    source_lang = "en"
    target_lang = "ja"

    input_config = {
      gcs_source: {
        input_uri: input_uri
      },
      # Optional. Can be "text/plain" or "text/html".
      mime_type: "text/plain"
    }
    output_config = {
      gcs_destination: {
        output_uri_prefix: output_uri
      }
    }
    parent = translate.class.location_path project_id, location_id
    models = {
      "ja" => "projects/#{project_id}/locations/#{location_id}/models/#{model_id}"
    }

    operation = translate.batch_translate_text \
      parent, source_lang, [target_lang], [input_config], output_config,
      models: models
    operation.wait_until_done!
    response = operation.response

    allow(Google::Cloud::Translate).to receive(:new).and_return(client_double)
    allow(client_double).to receive(:batch_translate_text).and_return(operation)

    expect do
      translate_v3_batch_translate_text_with_model
    end.to output("Total Characters: 13\nTranslated Characters: 13\n").to_stdout
  end

  example "Batch Translate Text with Model and Glossary", :translate_v3_batch_translate_text_with_glossary_and_model do
    skip "TRANSLATE_BUCKET not set" if bucket.nil?
    skip "AUTOML_TRANSLATION_MODEL_ID not set" if model_id.nil?

    ensure_storage_setup! bucket, "text.txt", "Hello, world!"
    create_glossary!

    input_uri = "gs://#{bucket}/text.txt"
    output_uri = "gs://#{bucket}/results/#{uuid}/"
    source_lang = "en"
    target_lang = "ja"

    input_config = {
      gcs_source: {
        input_uri: input_uri
      },
      # Optional. Can be "text/plain" or "text/html".
      mime_type: "text/plain"
    }
    output_config = {
      gcs_destination: {
        output_uri_prefix: output_uri
      }
    }
    parent = translate.class.location_path project_id, location_id
    models = {
      "ja" => "projects/#{project_id}/locations/#{location_id}/models/#{model_id}"
    }
    glossaries = {
      "ja" => Google::Cloud::Translate::V3::TranslateTextGlossaryConfig.new(
        # Required. Specifies the glossary used for this translation.
        glossary: "projects/#{project_id}/locations/#{location_id}/glossaries/#{glossary_id}"
      )
    }

    operation = translate.batch_translate_text \
      parent, source_lang, [target_lang], [input_config], output_config,
      models: models, glossaries: glossaries
    operation.wait_until_done!
    response = operation.response

    delete_glossary!

    allow(Google::Cloud::Translate).to receive(:new).and_return(client_double)
    allow(client_double).to receive(:batch_translate_text).and_return(operation)

    expect do
      translate_v3_batch_translate_text_with_glossary_and_model
    end.to output("Total Characters: 13\nTranslated Characters: 13\n").to_stdout
  end
end
