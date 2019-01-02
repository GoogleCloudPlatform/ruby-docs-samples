# Copyright 2018 Google, LLC
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

# [START vision_product_search_create_reference_image]
require "google/cloud/vision"

def product_search_create_reference_image(
  project_id = "your-project-id",
  location   = "us-west1",
  product_id = "your-product-id"
)
  client = Google::Cloud::Vision::ProductSearch.new

  product_path    = client.product_path project_id, location, product_id
  reference_image = {
    uri: "gs://cloud-samples-data/vision/product_search/shoes_1.jpg"
  }

  reference_image = client.create_reference_image product_path, reference_image

  puts "Added reference image to #{product_id}."
  puts "Reference image name: #{reference_image.name}"
  puts "Reference image uri: #{reference_image.uri}"
end
# [END vision_product_search_create_reference_image]

product_search_create_reference_image *ARGV if $PROGRAM_NAME == __FILE__
