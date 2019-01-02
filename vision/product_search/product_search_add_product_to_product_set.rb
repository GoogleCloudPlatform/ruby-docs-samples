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

# [START vision_product_search_add_product_to_product_set]
require "google/cloud/vision"

def product_search_add_product_to_product_set(
    project_id     = "your-project-id",
    location       = "us-west1",
    product_id     = "your-product-id",
    product_set_id = "your-product-set-id"
  )
  client = Google::Cloud::Vision::ProductSearch.new

  # Get the full path of the product set.
  product_set_path = client.product_set_path(project_id,
                                             location,
                                             product_set_id)

  # Get the full path of the product.
  product_path = client.product_path project_id, location, product_id

  # Add the product to the product set.
  client.add_product_to_product_set product_set_path, product_path

  puts "Product #{product_id} added to product set #{product_set_id}."
end
# [END vision_product_search_add_product_to_product_set]

product_search_add_product_to_product_set *ARGV if $PROGRAM_NAME == __FILE__
