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

def detect_landmark path_to_image_file
# [START detect_landmark]
  # [START importing_libraries]
  require "gcloud"
  # [END importing_libraries]

  # [START create_vision_client]
  gcloud = Gcloud.new
  vision = gcloud.vision
  # [END create_vision_client]

  # [START annotate_image]
  image      = vision.image path_to_image_file
  annotation = vision.annotate image, landmarks: true
  landmark   = annotation.landmark
  # [END annotate_image]

  # [START print_landmark]
  puts "Found landmark: #{landmark.description}" unless landmark.nil?
  # [END print_landmarks]
# [END detect_landmarks]
end

def detect_faces path_to_image_file, path_to_output_file
# [START detect_faces]
  # [START importing_libraries]
  require "gcloud"
  # [END importing_libraries]

  # [START create_vision_client]
  gcloud = Gcloud.new
  vision = gcloud.vision
  # [END create_vision_client]

  # [START annotate_image]
  image      = vision.image path_to_image_file
  annotation = vision.annotate image, faces: true
  faces      = annotation.faces
  # [END annotate_image]

  # [START draw_rectangle]
  require "rmagick"

  image = Magick::Image.read(path_to_image_file)[0]

  faces.each do |face|
    face.bounds.face.each do |vector|
      puts "#{vector.x}, #{vector.y}"
    end

    draw        = Magick::Draw.new
    draw.stroke = "green"
    draw.stroke_width 5
    draw.fill_opacity 0

    x1 = face.bounds.face[0].x.to_i
    y1 = face.bounds.face[0].y.to_i
    x2 = face.bounds.face[2].x.to_i
    y2 = face.bounds.face[2].y.to_i

    draw.rectangle x1, y1, x2, y2
    draw.draw image
  end

  image.write path_to_output_file

  puts "Output file: #{path_to_output_file}"
  # [END draw_rectangle]
# [END detect_faces]
end
