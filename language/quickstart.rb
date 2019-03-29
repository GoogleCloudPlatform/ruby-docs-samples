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

# [START language_quickstart]
# Imports the Google Cloud client library
# [START language_ruby_migration_import]
require "google/cloud/language"
# [END language_ruby_migration_import]

# Instantiates a client
# [START language_ruby_migration_client]
language = Google::Cloud::Language.new
# [END language_ruby_migration_client]

# The text to analyze
text = "Hello, world!"

# Detects the sentiment of the text
response = language.analyze_sentiment content: text, type: :PLAIN_TEXT

# Get document sentiment from response
sentiment = response.document_sentiment

puts "Text: #{text}"
puts "Score: #{sentiment.score}, #{sentiment.magnitude}"
# [END language_quickstart]
