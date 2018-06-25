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

# Your Google Cloud Platform project ID
project_id = "YOUR_PROJECT_ID"

# Instantiates a client
vision = Google::Cloud::Vision.new project: project_id

# The name of the image file to annotate
file_name = "./resources/cat.jpg"

# Performs label detection on the image file
labels = vision.image(file_name).labels

puts "Labels:"
labels.each do |label|
  puts label.description
end
# [END vision_quickstart]
