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

# [START vision_product_search_list_products]
require "google/cloud/vision"

def product_search_list_products(
  project_id = "your-project-id",
  location   = "us-west1"
)
  client = Google::Cloud::Vision::ProductSearch.new

  location_path = client.location_path project_id, location

  puts "Products in location #{location}:"
  client.list_products(location_path).each do |product|
    puts "\t#{product.name}"
  end
end
# [END vision_product_search_list_products]

product_search_list_products *ARGV if $PROGRAM_NAME == __FILE__
