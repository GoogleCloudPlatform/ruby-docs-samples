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

require "spec_helper"

describe "Add product to product set" do
  example "Add product to product set" do
    temp_product = create_temp_product
    temp_product_set = create_temp_product_set
    snippet_filepath = get_snippet_filepath __FILE__

    output = `ruby #{snippet_filepath} #{@project_id} #{@location} #{get_id temp_product} #{get_id temp_product_set}`

    products_in_product_set = Array(@client.list_products_in_product_set(temp_product_set.name))
    expect(products_in_product_set.length).to eq 1
    expect(products_in_product_set.first.name).to eq temp_product.name
  end
end
