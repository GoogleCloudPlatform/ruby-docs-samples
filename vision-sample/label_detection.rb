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

def detect_labels path_to_image_file
# [START detect_labels]
  # [START importing_libraries]
  require "gcloud"
  # [END importing_libraries]

  # [START create_vision_client]
  gcloud = Gcloud.new
  vision = gcloud.vision
  # [END create_vision_client]

  # [START annotate_image]
  image      = vision.image path_to_image_file
  annotation = vision.annotate image, labels: true
  labels     = annotation.labels
  # [END annotate_image]

  # [START print_labels]
  puts "Image labels:"
  labels.each do |label|
    puts label.description
  end
  # [END print_labels]
# [END detect_labels]
end
