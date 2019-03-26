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

def sentiment_from_text text_content:
  # [START language_sentiment_text]
  # [START language_ruby_migration_sentiment_text]
  # text_content = "Text to run sentiment analysis on"

  require "google/cloud/language"

  language = Google::Cloud::Language.new

  response = language.analyze_sentiment content: text_content, type: :PLAIN_TEXT

  sentiment = response.document_sentiment
  # [END language_ruby_migration_sentiment_text]

  puts "Overall document sentiment: (#{sentiment.score})"
  puts "Sentence level sentiment:"

  sentences = response.sentences

  sentences.each do |sentence|
    sentiment = sentence.sentiment
    puts "#{sentence.text.content}: (#{sentiment.score})"
  end
  # [END language_sentiment_text]
end

def sentiment_from_cloud_storage_file storage_path:
  # [START language_sentiment_gcs]
  # [START language_ruby_migration_sentiment_gcs]
  # storage_path = "Path to file in Google Cloud Storage, eg. gs://bucket/file"

  require "google/cloud/language"

  language = Google::Cloud::Language.new

  response = language.analyze_sentiment gcs_content_uri: storage_path, type: :PLAIN_TEXT

  sentiment = response.document_sentiment
  # [END language_ruby_migration_sentiment_gcs]

  puts "Overall document sentiment: (#{sentiment.score})"
  puts "Sentence level sentiment:"

  sentences = response.sentences

  sentences.each do |sentence|
    sentiment = sentence.sentiment
    puts "#{sentence.text.content}: (#{sentiment.score})"
  end
  # [END language_sentiment_gcs]
end

def entities_from_text text_content:
  # [START language_entities_text]
  # text_content = "Text to extract entities from"

  require "google/cloud/language"

  language = Google::Cloud::Language.new

  response = language.analyze_entities content: text_content, type: :PLAIN_TEXT

  entities = response.entities

  entities.each do |entity|
    puts "Entity #{entity.name} #{entity.type}"

    if entity.metadata["wikipedia_url"]
      puts "URL: #{entity.metadata['wikipedia_url']}"
    end
  end
  # [END language_entities_text]
end

def entities_from_cloud_storage_file storage_path:
  # [START language_entities_gcs]
  # storage_path = "Path to file in Google Cloud Storage, eg. gs://bucket/file"

  require "google/cloud/language"

  language = Google::Cloud::Language.new
  response = language.analyze_entities gcs_content_uri: storage_path, type: :PLAIN_TEXT

  entities = response.entities

  entities.each do |entity|
    puts "Entity #{entity.name} #{entity.type}"

    if entity.metadata["wikipedia_url"]
      puts "URL: #{entity.metadata['wikipedia_url']}"
    end
  end
  # [END language_entities_gcs]
end

def syntax_from_text text_content:
  # [START language_syntax_text]
  # text_content = "Text to analyze syntax of"

  require "google/cloud/language"

  language = Google::Cloud::Language.new
  response = language.analyze_syntax content: text_content, type: :PLAIN_TEXT

  sentences = response.sentences
  tokens    = response.tokens

  puts "Sentences: #{sentences.count}"
  puts "Tokens: #{tokens.count}"

  tokens.each do |token|
    puts "#{token.part_of_speech.tag} #{token.text.content}"
  end
  # [END language_syntax_text]
end

def syntax_from_cloud_storage_file storage_path:
  # [START language_syntax_gcs]
  # storage_path = "Path to file in Google Cloud Storage, eg. gs://bucket/file"

  require "google/cloud/language"

  language = Google::Cloud::Language.new
  response = language.analyze_syntax gcs_content_uri: storage_path, type: :PLAIN_TEXT

  sentences = response.sentences
  tokens    = response.tokens

  puts "Sentences: #{sentences.count}"
  puts "Tokens: #{tokens.count}"

  tokens.each do |token|
    puts "#{token.part_of_speech.tag} #{token.text.content}"
  end
  # [END language_syntax_gcs]
end

def classify_text text_content:
  # [START language_classify_text]
  # text_content = "Text to classify"

  require "google/cloud/language"

  language = Google::Cloud::Language.new
  response = language.classify_text content: text_content, type: :PLAIN_TEXT

  categories = response.categories

  categories.each do |category|
    puts "Name: #{category.name} Confidence: #{category.confidence}"
  end
  # [END language_classify_text]
end

def classify_text_from_cloud_storage_file storage_path:
  # [START language_classify_gcs]
  # storage_path = "Path to file in Google Cloud Storage, eg. gs://bucket/file"

  require "google/cloud/language"

  language = Google::Cloud::Language.new
  response = language.classify_text gcs_content_uri: storage_path, type: :PLAIN_TEXT

  categories = response.categories

  categories.each do |category|
    puts "Name: #{category.name} Confidence: #{category.confidence}"
  end
  # [END language_classify_gcs]
end


if $PROGRAM_NAME == __FILE__

  if ARGV.length == 1
    puts "Sentiment:"
    sentiment_from_text text_content: ARGV.first
    puts "Entities:"
    entities_from_text text_content: ARGV.first
    puts "Syntax:"
    syntax_from_text text_content: ARGV.first
    puts "Classify:"
    classify_text text_content: ARGV.first
  else
    puts "Usage: ruby language_samples.rb <text-to-analyze>"
  end
end
