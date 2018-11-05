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

  image_annotator = Google::Cloud::Vision::ImageAnnotator.new

  content = File.binread image_path
  image = { content: content }
  feature = { type: :OBJECT_LOCALIZATION }
  request = { image: image, features: [feature] }

  response = image_annotator.batch_annotate_images([request])
  response.responses.each do |res|
    res.localized_object_annotations.each do |object|
      puts "#{object.name} (confidence: #{object.score})"
      puts "Normalized bounding polygon vertices:"
      object.bounding_poly.normalized_vertices.each do |vertex|
        puts " - (#{vertex.x}, #{vertex.y})"
      end
    end
  end
  # [END vision_localize_objects]
end

# This method is a duplicate of the above method, but with a different
# description of the 'image_path' variable, demonstrating the gs://bucket/file
# GCS storage URI format.
def localize_objects_gs image_path:
  # [START vision_localize_objects_gcs]
  # image_path = "Google Cloud Storage URI, eg. 'gs://my-bucket/image.png'"

  require "google/cloud/vision"

  image_annotator = Google::Cloud::Vision::ImageAnnotator.new

  source = { gcs_image_uri: image_path }
  image = { source: source }
  feature = { type: :OBJECT_LOCALIZATION }
  request = { image: image, features: [feature] }

  response = image_annotator.batch_annotate_images([request])
  response.responses.each do |res|
    res.localized_object_annotations.each do |object|
      puts "#{object.name} (confidence: #{object.score})"
      puts "Normalized bounding polygon vertices:"
      object.bounding_poly.normalized_vertices.each do |vertex|
        puts " - (#{vertex.x}, #{vertex.y})"
      end
    end
  end
  # [END vision_localize_objects_gcs]
end

# This method is a duplicate of the above method, but with a different
# description of the 'image_path' variable, demonstrating the https://site.tld/image.png
# URI format.
def localize_objects_uri image_path:
  # [START vision_localize_objects_gcs]
  # image_path = "URI, eg. 'https://site.tld/image.png'"

  require "google/cloud/vision"

  image_annotator = Google::Cloud::Vision::ImageAnnotator.new

  source = { image_uri: image_path }
  image = { source: source }
  feature = { type: :OBJECT_LOCALIZATION }
  request = { image: image, features: [feature] }

  response = image_annotator.batch_annotate_images([request])
  response.responses.each do |res|
    res.localized_object_annotations.each do |object|
      puts "#{object.name} (confidence: #{object.score})"
      puts "Normalized bounding polygon vertices:"
      object.bounding_poly.normalized_vertices.each do |vertex|
        puts " - (#{vertex.x}, #{vertex.y})"
      end
    end
  end
  # [END vision_localize_objects_gcs]
end

if __FILE__ == $PROGRAM_NAME
  require "uri"

  image_path = ARGV.shift

  unless image_path
    return puts <<-USAGE
    Usage: ruby localize_objects.rb [image file path]

    Example:
      ruby localize_objects.rb image.png
      ruby localize_objects.rb https://public-url/image.png
      ruby localize_objects.rb gs://my-bucket/image.png
    USAGE
  end
  if image_path =~ URI::DEFAULT_PARSER.new.make_regexp
    image_uri = URI(image_path)
    return localize_objects_gs image_path: image_path if image_uri.scheme == "gs"

    return localize_object_uri image_path: image_path
  end

  localize_objects image_path: image_path
end
