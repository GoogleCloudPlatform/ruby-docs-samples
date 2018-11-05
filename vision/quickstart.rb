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

# [START vision_quickstart]
# Imports the Google Cloud client library
require "google/cloud/vision"

# Instantiates a client
vision = Google::Cloud::Vision::ImageAnnotator.new

# The name of the image file to annotate
file_name = "./resources/cat.jpg"

# Build the request body
content = File.binread file_name
image = { content: content }
feature = { type: :LABEL_DETECTION }
request = { image: image, features: [feature] }

# Performs label detection on the image file
response = vision.batch_annotate_images([request])
response.responses.each do |res|
  puts "Labels:"
  res.label_annotations.each do |label|
    puts label.description
  end
end
# [END vision_quickstart]
