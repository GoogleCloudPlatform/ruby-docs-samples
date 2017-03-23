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

def detect_landmarks project_id:, image_path:
  # [START vision_landmark_detection]
  # project_id = "Your Google Cloud project ID"
  # image_path = "Path to local image file, eg. './image.png'"
  
  require "google/cloud/vision"

  vision = Google::Cloud::Vision.new project: project_id
  image  = vision.image image_path

  image.landmarks.each do |landmark|
    puts landmark.description

    landmark.locations.each do |location|
      puts "#{location.latitude}, #{location.longitude}"
    end
  end
  # [END vision_landmark_detection]
end

# This method is a duplicate of the above method, but with a different
# description of the 'image_path' variable, demonstrating the gs://bucket/file
# GCS storage URI format.
def detect_landmarks_gcs project_id:, image_path:
  # [START vision_landmark_detection_gcs]
  # project_id = "Your Google Cloud project ID"
  # image_path = "Google Cloud Storage URI, eg. 'gs://my-bucket/image.png'"
  
  require "google/cloud/vision"

  vision = Google::Cloud::Vision.new project: project_id
  image  = vision.image image_path

  image.landmarks.each do |landmark|
    puts landmark.description

    landmark.locations.each do |location|
      puts "#{location.latitude}, #{location.longitude}"
    end
  end
  # [END vision_landmark_detection_gcs]
end

if __FILE__ == $PROGRAM_NAME
  image_path = ARGV.shift

  if image_path
    detect_landmarks image_path: image_path
  else
    puts <<-usage
Usage: ruby detect_landmarks.rb [image file path]

Example:
  ruby detect_landmarks.rb image.png
  ruby detect_landmarks.rb https://public-url/image.png
  ruby detect_landmarks.rb gs://my-bucket/image.png
    usage
  end
end
