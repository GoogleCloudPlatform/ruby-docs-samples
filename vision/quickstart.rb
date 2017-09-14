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
vision = Google::Cloud::Vision.new

# The name of the image file to annotate
file_name = "./images/cat.jpg"

# Read image
image = File.binread file_name

# Construct the request for label detection
request  = [image:    { content: image },
            features: [{ type: :LABEL_DETECTION }]]

# Perform label detection on the image file
response = vision.batch_annotate_images request

# Get labels from first element in the response as we only annotated one image.
labels = response.responses.first.label_annotations

puts "Labels:"
labels.each do |label|
  puts label.description
end
# [END vision_quickstart]

