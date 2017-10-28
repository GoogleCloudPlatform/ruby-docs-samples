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

# [START all]
# [START import_client_library]
require "google/cloud/vision"
# [END import_client_library]
# [START import_rmagick]
require "rmagick"
# [END import_rmagick]

# [START detect_faces]
def draw_box_around_faces path_to_image_file:, path_to_output_file:
  # [START get_vision_service]
  vision = Google::Cloud::Vision.new
  # [END get_vision_service]

  # [START detect_face]
  image = File.binread path_to_image_file

  # Construct the request for label detection
  request  = [image:    { content: image },
              features: [{ type: :FACE_DETECTION }]]

  # Perform label detection on the image file
  response = vision.batch_annotate_images request

  image = response.responses.first
  faces = image.face_annotations
  # [END detect_face]

  # [START highlight_faces]
  image = Magick::Image.read(path_to_image_file).first

  faces.each do |face|
    bounds = face.bounding_poly

    puts "Face bounds:"
    bounds.vertices.each do |vertex|
      puts "(#{vertex.x}, #{vertex.y})"
    end

    draw = Magick::Draw.new
    draw.stroke = "green"
    draw.stroke_width 5
    draw.fill_opacity 0

    x1 = bounds.vertices[0].x.to_i
    y1 = bounds.vertices[0].y.to_i
    x2 = bounds.vertices[2].x.to_i
    y2 = bounds.vertices[2].y.to_i

    draw.rectangle x1, y1, x2, y2
    draw.draw image
  end

  image.write path_to_output_file

  puts "Output file: #{path_to_output_file}"
  # [END highlight_faces]
end

# [START main]
if __FILE__ == $PROGRAM_NAME
  project_id = ENV["GOOGLE_CLOUD_PROJECT"]

  if ARGV.size == 2
    draw_box_around_faces path_to_image_file:  ARGV.shift,
                          path_to_output_file: ARGV.shift,
                          project_id:          project_id
  else
    puts <<-usage
Usage: ruby draw_box_around_faces.rb [input-file] [output-file]

Example:
  ruby draw_box_around_faces.rb images/face.png output-image.png
    usage
  end
end
# [END main]
# [END detect_faces]
# [END all]
