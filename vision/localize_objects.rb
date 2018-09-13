# Copyright 2018 Google, Inc
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

def localize_objects image_path:
  # [START vision_localize_objects]
  # image_path = "Path to local image file, eg. './image.png'"

  require "google/cloud/vision"

  vision = Google::Cloud::Vision::V1.new

  image_content = IO.read image_path, mode: 'rb'
  image = Google::Cloud::Vision::V1::Image.new content: image_content

  feature = Google::Cloud::Vision::V1::Feature.new type: :OBJECT_LOCALIZATION

  request = Google::Cloud::Vision::V1::AnnotateImageRequest.new image: image, features: [feature]

  response = (vision.batch_annotate_images [request]).responses.first

  objects = response.localized_object_annotations

  objects.each do |object|
    puts "#{object.name} (confidence: #{object.score})"
    puts "Normalized bounding polygon vertices:"
    object.bounding_poly.normalized_vertices.each do |vertex|
      puts " - (#{vertex.x}, #{vertex.y})"
    end
  end
  # [END vision_localize_objects]
end

def localize_objects_uri image_path:
  # [START vision_localize_objects_gcs]
  # image_path = "Google Cloud Storage URI, eg. 'gs://my-bucket/image.png'"

  require "google/cloud/vision"

  vision = Google::Cloud::Vision::V1.new

  image_source = Google::Cloud::Vision::V1::ImageSource.new image_uri: image_path
  image = Google::Cloud::Vision::V1::Image.new source: image_source

  feature = Google::Cloud::Vision::V1::Feature.new type: :OBJECT_LOCALIZATION

  request = Google::Cloud::Vision::V1::AnnotateImageRequest.new image: image, features: [feature]

  response = (vision.batch_annotate_images [request]).responses.first

  objects = response.localized_object_annotations

  objects.each do |object|
    puts "#{object.name} (confidence: #{object.score})"
    puts "Normalized bounding polygon vertices:"
    object.bounding_poly.normalized_vertices.each do |vertex|
      puts " - (#{vertex.x}, #{vertex.y})"
    end
  end
  # [END vision_localize_objects_gcs]
end

if __FILE__ == $PROGRAM_NAME
  location = ARGV.shift
  image_path = ARGV.shift

  if location == 'file'
    localize_objects image_path: image_path
  elsif location == 'uri'
    localize_objects_gcs image_path: image_path
  else
    puts <<-usage
Usage: ruby localize_objects.rb {file,uri} [image file path]

Example:
  ruby localize_objects.rb file image.png
  ruby localize_objects.rb uri https://public-url/image.png
  ruby localize_objects.rb uri gs://my-bucket/image.png
    usage
  end
end
