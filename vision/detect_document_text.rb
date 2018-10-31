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
  image_content = File.binread image_path
  image = { content: image_content }

  type = :DOCUMENT_TEXT_DETECTION
  feature = { type: type }

  request = { image: image, features: [feature] }
  # request == {
  #   image: {
  #     content: (File.binread image_path)
  #   },
  #   features: [
  #     {
  #       type: :LABEL_DETECTION
  #     }
  #   ]
  # }

  requests = [request]
  response = vision.batch_annotate_images(requests)
  text = ""
  response.responses.each do |res|
    res.text_annotations.each do |annotation|
      text << annotation.description
    end
  end

  puts text
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
  source = { gcs_image_uri: image_path }
  image = { source: source }

  type = :DOCUMENT_TEXT_DETECTION
  feature = { type: type }

  request = { image: image, features: [feature] }
  # request == {
  #   image: {
  #     source: {
  #       gcs_image_uri: "gs://gapic-toolkit/President_Barack_Obama.jpg"
  #     }
  #   },
  #   features: [
  #     {
  #       type: :LABEL_DETECTION
  #     }
  #   ]
  # }

  requests = [request]
  response = vision.batch_annotate_images(requests)
  text = ""
  response.responses.each do |res|
    res.text_annotations.each do |annotation|
      text << annotation.description
    end
  end

  puts text
  # [END vision_fulltext_detection_gcs]
end

def detect_document_text_async image_path:, output_path:
  # [START vision_fulltext_detection_asynchronous]
  # image_path = "Google Cloud Storage URI, eg. 'gs://my-bucket/document.pdf'"
  # output_path = "Google Cloud Storage URI, eg. 'gs://my-bucket/prefix'"

  require "google/cloud/vision"

  vision = Google::Cloud::Vision.new
  gcs_source = { uri: image_path }
  input_config = { gcs_source: gcs_source, mime_type: "application/pdf" }
  type = :DOCUMENT_TEXT_DETECTION
  max_results = 15 # optional, defaults to 10
  feature = { type: type, max_results: max_results }
  destination = { uri: output_path }

  # number of pages per output file
  batch_size = 1 # optional, defaults to 20
  output_config = { gcs_destination: destination, batch_size: batch_size }
  request = {
    input_config: input_config,
    features: [feature],
    output_config: output_config
  }
  # request == {
  #   input_config: {
  #     gcs_source: {
  #       uri: image_path
  #     },
  #     mime_type: "application/pdf"
  #   },
  #   output_config: {
  #     gcs_destination: {
  #       uri: output_path
  #     },
  #     batch_size: 1
  #   },
  #   features: [
  #     {
  #       type: :DOCUMENT_TEXT_DETECTION,
  #       max_results: 15
  #     }
  #   ]
  # }

  requests = [request]
  response = vision.async_batch_annotate_files(requests)
  response.wait_until_done!
  # results will be stored in Google Cloud Storage formatted like
  # "#{output_path}output-#{start_page}-to-#{end_page}.json"
  # [END vision_fulltext_detection_asynchronous]
end

def uri? string
  string
end

if __FILE__ == $PROGRAM_NAME
  require "uri"

  args = {
    image_path: ARGV.shift,
    output_path: ARGV.shift
  }

  if args[:image_path].nil?
    return puts <<-USAGE
    Usage: ruby detect_document_text.rb [image file path]

    Example:
      ruby detect_document_text.rb image.png
      ruby detect_document_text.rb https://public-url/image.png
      ruby detect_document_text.rb gs://my-bucket/image.png
    USAGE
  end
  unless args[:image_path] =~ URI::DEFAULT_PARSER.new.make_regexp
    return detect_document_text args
  end

  detect_document_text_gcs args
  detect_document_text_async args if args[:output_path]
end
