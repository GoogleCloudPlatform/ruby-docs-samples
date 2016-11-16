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

# [START translate_quickstart]
# Imports the Google Cloud client library
require "google/cloud"

# Your Google Cloud Platform project ID
project_id = "nodejs-docs-samples"

# Instantiates a client
gcloud    = Google::Cloud.new project_id
translate = gcloud.translate

# The text to translate
text = "Hello, world!"
# The target language
target = "ru"

# Translates some text into Russian
translation = translate.translate text, to: target

puts "Text: #{text}"
puts "Translation: #{translation}"
# [END translate_quickstart]

