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

describe "Delete product set" do

  example "Delete product set" do

    current_directory = File.expand_path(File.dirname(__FILE__))
    snippet_filepath = File.join current_directory, "..",
                                 "product_search_delete_product_set.rb"
    product_set = create_temp_product
    product_set_id = get_id product_set

    output = `ruby #{snippet_filepath} #{@project_id} #{@location} #{product_set_id}`

    expect {
      @client.get_product_set(product_set.name)
    }.to raise_error Google::Gax::RetryError
  end

end
