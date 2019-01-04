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

require "rspec"
require "google/cloud/vision"

RSpec.configure do |config|
  config.before(:all) do
    @current_directory = File.expand_path(File.dirname(__FILE__))
    @client = Google::Cloud::Vision::ProductSearch.new
    @project_id = ENV["E2E_GOOGLE_CLOUD_PROJECT"]
    @location = "us-west1"
    @location_path = @client.location_path @project_id, @location
    @image_uris = [
      "gs://cloud-samples-data/vision/product_search/shoes_1.jpg",
      "gs://cloud-samples-data/vision/product_search/shoes_2.jpg"
    ]
    @temp_products = []
    @temp_product_sets = []
  end

  config.after(:each) do
    @temp_products.each do |product|
      if product.is_a? String
        product_path = @client.product_path(
          @project_id, @location, product
        )
      else
        product_path = product.name
      end
      @client.delete_product product_path
    end
    @temp_product_sets.each do |product_set|
      if product_set.is_a? String
        product_set_path = @client.product_set_path(
          @project_id, @location, product_set
        )
      else
        product_set_path = product_set.name
      end
      @client.delete_product_set product_set_path
    end
  end

  def create_temp_product
    product = {
      display_name: "test_product_#{Time.now.to_i}",
      product_category: "apparel"
    }
    product = @client.create_product @location_path, product
    @temp_products << product
    return product
  end

  def create_temp_reference_image product, uri = nil
    image_uri = uri || @image_uris[0]
    @client.create_reference_image product.name, { uri: image_uri }
  end

  def create_temp_product_set products = []
    product_set = {
      display_name: "test_product_set_#{Time.now.to_i}"
    }
    product_set = @client.create_product_set @location_path, product_set
    @temp_product_sets << product_set
    products.each do |product|
      @client.add_product_to_product_set product_set.name, product.name
    end
    return product_set
  end

  def get_id resource
    resource.name.split("/").last
  end

  def get_snippet_filepath test_filepath
    File.join(
      @current_directory,
      "..",
      File.basename(test_filepath).sub("_spec", "")
    )
  end

end
