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

require "uri"

def detect_logos image_path:
  # [START vision_logo_detection]
  # image_path = "Path to local image file, eg. './image.png'"

  require "google/cloud/vision"

  image_annotator = Google::Cloud::Vision::ImageAnnotator.new

  # [START vision_logo_detection_migration]
  response = image_annotator.logo_detection image: image_path

  response.responses.each do |res|
    res.logo_annotations.each do |logo|
      puts logo.description
    end
  end
  # [END vision_logo_detection_migration]
  # [END vision_logo_detection]
end

# This method is a duplicate of the above method, but with a different
# description of the 'image_path' variable, demonstrating the gs://bucket/file
# GCS storage URI format.
def detect_logos_gcs image_path:
  # [START vision_logo_detection_gcs]
  # image_path = "Google Cloud Storage URI, eg. 'gs://my-bucket/image.png'"

  require "google/cloud/vision"

  image_annotator = Google::Cloud::Vision::ImageAnnotator.new

  response = image_annotator.logo_detection image: image_path

  response.responses.each do |res|
    res.logo_annotations.each do |logo|
      puts logo.description
    end
  end
  # [END vision_logo_detection_gcs]
end

if $PROGRAM_NAME == __FILE__
  image_path = ARGV.shift

  if !image_path
    puts <<~USAGE
      Usage: ruby detect_logos.rb [image file path]
       Example:
        ruby detect_logos.rb image.png
        ruby detect_logos.rb https://public-url/image.png
        ruby detect_logos.rb gs://my-bucket/image.png
    USAGE
  elsif image_path =~ URI::DEFAULT_PARSER.make_regexp
    detect_logos_gs image_path: image_path
  else
    detect_logos image_path: image_path
  end
end
