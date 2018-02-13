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

def detect_web image_path:
  # [START vision_web_detection]
  # image_path = "Path to local image file, eg. './image.png'"

  require "google/cloud/vision"

  vision = Google::Cloud::Vision.new

  annotation = vision.web_detection(image_path).web_detection

  annotation.best_guess_labels.each do |label|
    puts "Best guess label: #{label.label}"
  end

  annotation.pages_with_matching_images.each do |page|
    puts "Page with matching images found: #{page.url}"
    page.full_matching_images.each do |image|
      puts "Full matching image url: #{image.url}"
    end
    page.partial_matching_images.each do |image|
      puts "Partial matching image url: #{image.url}"
    end
  end

  annotation.web_entities.each do |web_entity|
    puts "Web entity description: #{web_entity.description}"
    puts "Web entity score:       #{web_entity.score}"
  end

  annotation.visually_similar_images.each do |image|
    puts "Visually similar image url: #{image.url}"
  end
  # [END vision_web_detection]
end

# This method is a duplicate of the above method, but with a different
# description of the 'image_path' variable, demonstrating the gs://bucket/file
# GCS storage URI format.
def detect_web_gcs image_path:
  # [START vision_web_detection_gcs]
  # image_path = "Google Cloud Storage URI, eg. 'gs://my-bucket/image.png'"

  require "google/cloud/vision"

  vision = Google::Cloud::Vision.new

  annotation = vision.web_detection(image_path).web_detection

  annotation.best_guess_labels.each do |label|
    puts "Best guess label: #{label.label}"
  end

  annotation.pages_with_matching_images.each do |page|
    puts "Page with matching images found: #{page.url}"
    page.full_matching_images.each do |image|
      puts "Full matching image url: #{image.url}"
    end
    page.partial_matching_images.each do |image|
      puts "Partial matching image url: #{image.url}"
    end
  end

  annotation.web_entities.each do |web_entity|
    puts "Web entity description: #{web_entity.description}"
    puts "Web entity score:       #{web_entity.score}"
  end

  annotation.visually_similar_images.each do |image|
    puts "Visually similar image url: #{image.url}"
  end
  # [END vision_web_detection_gcs]
end

if __FILE__ == $PROGRAM_NAME
  image_path = ARGV.shift

  if image_path
    detect_web image_path: image_path
  else
    puts <<-usage
Usage: ruby detect_web.rb [image file path]

Example:
  ruby detect_web.rb image.png
  ruby detect_web.rb https://public-url/image.png
  ruby detect_web.rb gs://my-bucket/image.png
    usage
  end
end
