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

describe "Get similar products" do
  before do
    @snippet_filepath = get_snippet_filepath __FILE__
    @product_category = "apparel"
    @image_file_path = File.expand_path(
      File.join(@current_directory, "..", "resources", "shoes_1.jpg")
    )
    # This filter has extra quotes to ensure the command is passed with quotes
    @filter = "'style = womens'"
  end

  example "Product sets are not immediately indexed" do
    temp_product_set_id = get_id create_temp_product_set
    sample_params = [
      @snippet_filepath,
      @project_id,
      @location,
      temp_product_set_id,
      @product_category,
      @image_file_path,
      @filter
    ]

    output = `ruby #{sample_params.join " "}`

    expect(output).to include "Product set has not been indexed."
  end

  example "Finds similar products in an indexed product set" do
    # Indexing product sets does not happen immediately, cannot be triggered by
    # the user, and can take up to 30 minutes. See note here:
    # https://cloud.google.com/vision/product-search/docs/tutorial-search-merged
    # This test imports a product set and does not delete it.
    # It will not pass on the first run in a project, but will pass on
    # subsequent runs after the product set has been indexed.

    # Import indexed product sets without setting them to be deleted
    input_config = {
      gcs_source: {
        csv_file_uri: "gs://cloud-samples-data/vision/product_search/indexed_product_sets.csv"
      }
    }
    operation = @client.import_product_sets @location_path, input_config
    operation.wait_until_done! # Waits for the operation to complete
    import_snippet_file_path = File.join(
      @current_directory, "..", "product_search_import_product_images.rb"
    )
    `ruby #{import_snippet_file_path} #{@project_id} #{@location}`

    indexed_product_set_id = "indexed_product_set_id_for_testing"
    sample_params = [
      @snippet_filepath,
      @project_id,
      @location,
      indexed_product_set_id,
      @product_category,
      @image_file_path,
      @filter
    ]

    output = `ruby #{sample_params.join " "}`

    expect(output).to include "shoes_1"
  end
end
