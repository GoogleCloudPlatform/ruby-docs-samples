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

def detect_document_text image_path:
  # [START vision_fulltext_detection]
  # image_path = "Path to local image file, eg. './image.png'"

  require "google/cloud/vision"

  vision = Google::Cloud::Vision.new

  image = File.binread image_path

  request  = [image:    { content: image },
              features: [{ type: :DOCUMENT_TEXT_DETECTION }]]

  response = vision.batch_annotate_images request

  document = response.responses.first.full_text_annotation

  puts document.text
  # [END vision_fulltext_detection]
end

# This method is a duplicate of the above method, but with a different
# description of the 'image_path' variable, demonstrating the gs://bucket/file
# GCS storage URI format.
def detect_document_text_gcs image_path:
  # [START vision_fulltext_detection_gcs]
  # image_path = "Google Cloud Storage URI, eg. 'gs://my-bucket/image.png'"

  require "google/cloud/vision"

  vision = Google::Cloud::Vision.new

  request  = [image:    { source: { gcs_image_uri: image_path }},
              features: [{ type: :DOCUMENT_TEXT_DETECTION }]]

  response = vision.batch_annotate_images request

  document = response.responses.first.full_text_annotation

  puts document.text
  # [END vision_fulltext_detection_gcs]
end

if __FILE__ == $PROGRAM_NAME
  image_path = ARGV.shift

  if image_path
    detect_document_text image_path: image_path
  else
    puts <<-usage
Usage: ruby detect_document_text.rb [image file path]

Example:
  ruby detect_document_text.rb image.png
  ruby detect_document_text.rb https://public-url/image.png
  ruby detect_document_text.rb gs://my-bucket/image.png
    usage
  end
end
