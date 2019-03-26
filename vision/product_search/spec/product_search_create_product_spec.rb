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

describe "Create product" do
  example "Create a new product" do
    snippet_filepath = get_snippet_filepath __FILE__

    output = `ruby #{snippet_filepath} #{@project_id}`

    product_name = output.split.last
    expect(@client.get_product(product_name)).to be_truthy
  end
end
