# Copyright 2019 Google LLC
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

def set_endpoint service_address: nil, image_path: nil
  # [START vision_set_endpoint]
  # service_address = "Service address, eg. 'eu-vision.googleapis.com'"
  # image_path = "Google Cloud Storage URI, eg. 'gs://my-bucket/image.png'"
  require "google/cloud/vision"

  # Specify the service address at client construction.
  image_annotator = Google::Cloud::Vision::ImageAnnotator.new service_address: service_address
  # [END vision_set_endpoint]

  response = image_annotator.text_detection(
    image:       image_path,
    max_results: 1
  )

  response.responses.each do |res|
    res.text_annotations.each do |text|
      puts text.description
    end
  end
end

if $PROGRAM_NAME == __FILE__
  set_endpoint service_address: ARGV.first, image_path: ARGV[1]
end
