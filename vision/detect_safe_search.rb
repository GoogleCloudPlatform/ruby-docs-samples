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

def detect_safe_search image_path:
  # [START vision_safe_search_detection]
  # image_path = "Path to local image file, eg. './image.png'"

  require "google/cloud/vision"

  vision = Google::Cloud::Vision.new

  safe_search_annotation = vision.safe_search_detection(image_path).safe_search_annotation

  puts "Adult:    #{safe_search_annotation.adult}"
  puts "Spoof:    #{safe_search_annotation.spoof}"
  puts "Medical:  #{safe_search_annotation.medical}"
  puts "Violence: #{safe_search_annotation.violence}"
  puts "Racy:     #{safe_search_annotation.racy}"
  # [END vision_safe_search_detection]
end

# This method is a duplicate of the above method, but with a different
# description of the 'image_path' variable, demonstrating the gs://bucket/file
# GCS storage URI format.
def detect_safe_search_gcs image_path:
  # [START vision_safe_search_detection_gcs]
  # image_path = "Google Cloud Storage URI, eg. 'gs://my-bucket/image.png'"

  require "google/cloud/vision"

  vision = Google::Cloud::Vision.new

  safe_search_annotation = vision.safe_search_detection(image_path).safe_search_annotation

  puts "Adult:    #{safe_search_annotation.adult}"
  puts "Spoof:    #{safe_search_annotation.spoof}"
  puts "Medical:  #{safe_search_annotation.medical}"
  puts "Violence: #{safe_search_annotation.violence}"
  puts "Racy:     #{safe_search_annotation.racy}"
  # [END vision_safe_search_detection_gcs]
end

if __FILE__ == $PROGRAM_NAME
  image_path = ARGV.shift

  if image_path
    detect_safe_search image_path: image_path
  else
    puts <<-usage
Usage: ruby detect_safe_search.rb [image file path]

Example:
  ruby detect_safe_search.rb image.png
  ruby detect_safe_search.rb https://public-url/image.png
  ruby detect_safe_search.rb gs://my-bucket/image.png
    usage
  end
end
