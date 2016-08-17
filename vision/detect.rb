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

require_relative "label_detection"
require_relative "landmark_detection"
require_relative "face_detection"

detection_type      = ARGV.shift
path_to_image_file  = ARGV.shift
path_to_output_file = ARGV.shift

case detection_type
when "label"
  detect_labels path_to_image_file
when "landmark"
  detect_landmark path_to_image_file
when "faces"
  detect_faces path_to_image_file, path_to_output_file
else
  puts "Usage: detect.rb [type] [image path] [output path]"
  puts
  puts "       detect.rb label     /path/to/image.jpg"
  puts "       detect.rb landmark  /path/to/image.jpg"
  puts "       detect.rb faces     /path/to/image.jpg  /path/to/output.jpg"
end
