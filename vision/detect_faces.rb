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

def detect_faces image_path:
  # [START vision_face_detection]
  # image_path = "Path to local image file, eg. './image.png'"

  require "google/cloud/vision"

  image_annotator = Google::Cloud::Vision::ImageAnnotator.new

  # [START vision_face_detection_migration]
  response = image_annotator.face_detection image: image_path

  response.responses.each do |res|
    res.face_annotations.each do |face|
      puts "Joy:      #{face.joy_likelihood}"
      puts "Anger:    #{face.anger_likelihood}"
      puts "Sorrow:   #{face.sorrow_likelihood}"
      puts "Surprise: #{face.surprise_likelihood}"
    end
  end
  # [END vision_face_detection_migration]
  # [END vision_face_detection]
end

# This method is a duplicate of the above method, but with a different
# description of the 'image_path' variable, demonstrating the gs://bucket/file
# GCS storage URI format.
def detect_faces_gcs image_path:
  # [START vision_face_detection_gcs]
  # image_path = "Google Cloud Storage URI, eg. 'gs://my-bucket/image.png'"

  require "google/cloud/vision"

  image_annotator = Google::Cloud::Vision::ImageAnnotator.new

  response = image_annotator.face_detection image: image_path

  response.responses.each do |res|
    res.face_annotations.each do |face|
      puts "Joy:      #{face.joy_likelihood}"
      puts "Anger:    #{face.anger_likelihood}"
      puts "Sorrow:   #{face.sorrow_likelihood}"
      puts "Surprise: #{face.surprise_likelihood}"
    end
  end
  # [END vision_face_detection_gcs]
end

if $PROGRAM_NAME == __FILE__
  image_path = ARGV.shift

  if !image_path
    puts <<~USAGE
      Usage: ruby detect_faces.rb [image file path]
       Example:
        ruby detect_faces.rb image.png
        ruby detect_faces.rb https://public-url/image.png
        ruby detect_faces.rb gs://my-bucket/image.png
    USAGE
  elsif image_path =~ URI::DEFAULT_PARSER.make_regexp
    detect_faces_gs image_path: image_path
  else
    detect_faces image_path: image_path
  end
end
