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

def detect_faces image_path:
  # [START vision_face_detection]
  # image_path = "Path to local image file, eg. './image.png'"

  require "google/cloud/vision"

  vision = Google::Cloud::Vision.new

  face_annotations = vision.face_detection(image_path).face_annotations

  face_annotations.each do |face|
    puts "Joy:      #{face.joy_likelihood}"
    puts "Anger:    #{face.anger_likelihood}"
    puts "Sorrow:   #{face.sorrow_likelihood}"
    puts "Surprise: #{face.surprise_likelihood}"
  end
  # [END vision_face_detection]
end

# This method is a duplicate of the above method, but with a different
# description of the 'image_path' variable, demonstrating the gs://bucket/file
# GCS storage URI format.
def detect_faces_gcs image_path:
  # [START vision_face_detection_gcs]
  # image_path = "Google Cloud Storage URI, eg. 'gs://my-bucket/image.png'"

  require "google/cloud/vision"

  vision = Google::Cloud::Vision.new

  face_annotations = vision.face_detection(image_path).face_annotations

  face_annotations.each do |face|
    puts "Joy:      #{face.joy_likelihood}"
    puts "Anger:    #{face.anger_likelihood}"
    puts "Sorrow:   #{face.sorrow_likelihood}"
    puts "Surprise: #{face.surprise_likelihood}"
  end
  # [END vision_face_detection_gcs]
end

if __FILE__ == $PROGRAM_NAME
  image_path = ARGV.shift

  if image_path
    detect_faces image_path: image_path
  else
    puts <<-usage
Usage: ruby detect_faces.rb [image file path]

Example:
  ruby detect_faces.rb image.png
  ruby detect_faces.rb https://public-url/image.png
  ruby detect_faces.rb gs://my-bucket/image.png
    usage
  end
end

__END__
# XXX sample below extracted to `draw_box_around_faces.rb`
#     remove below once documentation is updated.

# [START all]
# [START import_client_library]
require "google/cloud/vision"
# [END import_client_library]
# [START import_rmagick]
require "rmagick"
# [END import_rmagick]

# [START detect_faces]
def detect_faces path_to_image_file:, path_to_output_file:
  # [START get_vision_service]
  vision = Google::Cloud::Vision.new project: project_id
  # [END get_vision_service]

  # [START detect_face]
  image = vision.image path_to_image_file
  faces = image.faces
  # [END detect_face]

  # [START highlight_faces]
  image = Magick::Image.read(path_to_image_file)[0]

  faces.each do |face|
    puts "Face bounds:"
    face.bounds.face.each do |vector|
      puts "(#{vector.x}, #{vector.y})"
    end

    draw = Magick::Draw.new
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
  # [END highlight_faces]
end

# [START main]
if __FILE__ == $PROGRAM_NAME
  if ARGV.size == 2
    detect_faces path_to_image_file:  ARGV.shift,
                 path_to_output_file: ARGV.shift
  else
    puts <<-usage
Usage: ruby detect_faces.rb image_file image_result

Example:
  ruby detect_faces.rb images/face.png output-image.png
    usage
  end
end
# [END main]
# [END detect_faces]
# [END all]
