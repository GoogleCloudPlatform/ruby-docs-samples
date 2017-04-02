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

def sentiment_from_text project_id:, text_content:
  # [START sentiment_from_text]
  # project_id   = "Your Google Cloud project ID"
  # text_content = "Text to run sentiment analysis on"

  require "google/cloud/language"

  language = Google::Cloud::Language.new project: project_id
  document = language.document text_content
  sentiment = document.sentiment

  puts "Overall document sentiment: (#{sentiment.score})"
  puts "Sentence level sentiment:"

  document.sentiment.sentences.each do |sentence|
    sentiment = sentence.sentiment
    puts "#{sentence.text}: (#{sentiment.score})"
  end
  # [END sentiment_from_text]
end

def sentiment_from_cloud_storage_file project_id:, storage_path:
  # [START sentiment_from_cloud_storage_file]
  # project_id   = "Your Google Cloud project ID"
  # storage_path = "Path to file in Google Cloud Storage, eg. gs://bucket/file"

  require "google/cloud/language"

  language = Google::Cloud::Language.new project: project_id
  document = language.document storage_path
  sentiment = document.sentiment

  puts "Overall document sentiment: (#{sentiment.score})"
  puts "Sentence level sentiment:"

  document.sentiment.sentences.each do |sentence|
    sentiment = sentence.sentiment
    puts "#{sentence.text}: (#{sentiment.score})"
  end
  # [END sentiment_from_cloud_storage_file]
end

def entities_from_text project_id:, text_content:
  # [START entities_from_text]
  # project_id   = "Your Google Cloud project ID"
  # text_content = "Text to extract entities from"

  require "google/cloud/language"

  language = Google::Cloud::Language.new project: project_id
  document = language.document text_content
  entities = document.entities

  entities.each do |entity|
    puts "Entity #{entity.name} #{entity.type}"

    if entity.metadata["wikipedia_url"]
      puts "URL: #{entity.metadata['wikipedia_url']}"
    end
  end
  # [END entities_from_text]
end

def entities_from_cloud_storage_file project_id:, storage_path:
  # [START entities_from_cloud_storage_file]
  # project_id   = "Your Google Cloud project ID"
  # storage_path = "Path to file in Google Cloud Storage, eg. gs://bucket/file"

  require "google/cloud/language"

  language = Google::Cloud::Language.new project: project_id
  document = language.document storage_path
  entities = document.entities

  entities.each do |entity|
    puts "Entity #{entity.name} #{entity.type}"

    if entity.metadata["wikipedia_url"]
      puts "URL: #{entity.metadata['wikipedia_url']}"
    end
  end
  # [END entities_from_cloud_storage_file]
end

def syntax_from_text project_id:, text_content:
  # [START syntax_from_text]
  # project_id   = "Your Google Cloud project ID"
  # text_content = "Text to analyze syntax of"

  require "google/cloud/language"

  language = Google::Cloud::Language.new project: project_id
  document = language.document text_content
  syntax   = document.syntax

  puts "Sentences: #{syntax.sentences.count}"
  puts "Tokens: #{syntax.tokens.count}"

  syntax.tokens.each do |token|
    puts "#{token.part_of_speech.tag} #{token.text_span.text}"
  end
  # [END syntax_from_text]
end

def syntax_from_cloud_storage_file project_id:, storage_path:
  # [START syntax_from_cloud_storage_file]
  # project_id   = "Your Google Cloud project ID"
  # storage_path = "Path to file in Google Cloud Storage, eg. gs://bucket/file"

  require "google/cloud/language"

  language = Google::Cloud::Language.new project: project_id
  document = language.document storage_path
  syntax   = document.syntax

  puts "Sentences: #{syntax.sentences.count}"
  puts "Tokens: #{syntax.tokens.count}"

  syntax.tokens.each do |token|
    puts "#{token.part_of_speech.tag} #{token.text_span.text}"
  end
  # [END syntax_from_cloud_storage_file]
end

if __FILE__ == $PROGRAM_NAME
  project_id = ENV["GOOGLE_CLOUD_PROJECT"]

  if ARGV.length == 1
    puts "Sentiment:"
    sentiment_from_text project_id: project_id, text_content: ARGV.first
    puts "Entities:"
    entities_from_text project_id: project_id, text_content: ARGV.first
    puts "Syntax:"
    syntax_from_text project_id: project_id, text_content: ARGV.first
  else
    puts "Usage: ruby language_samples.rb <text-to-analyze>"
  end
end
