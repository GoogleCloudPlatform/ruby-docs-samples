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

describe "Create reference image" do
  example "Create reference image" do
    snippet_filepath = get_snippet_filepath __FILE__
    product = create_temp_product
    product_id = get_id product
    reference_images_before = Array(@client.list_reference_images(product.name))
    expect(reference_images_before.length).to eq 0

    output = `ruby #{snippet_filepath} #{@project_id} #{@location} #{product_id}`

    reference_images_after = Array(@client.list_reference_images(product.name))
    expect(reference_images_after.length).to eq 1
  end
end
