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

# [START vision_product_search_update_product_labels]
require "google/cloud/vision"

def product_search_update_product_labels(
  project_id = "your-project-id",
  location   = "us-west1",
  product_id = "your-product-id"
)
  client = Google::Cloud::Vision::ProductSearch.new

  product_path = client.product_path project_id, location, product_id
  product      = {
    name:           product_path,
    product_labels: [{ key: "color", value: "green" }]
  }

  client.update_product product, update_mask: { "paths": ["product_labels"] }
end
# [END vision_product_search_update_product_labels]

product_search_update_product_labels *ARGV if $PROGRAM_NAME == __FILE__
