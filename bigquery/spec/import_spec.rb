# Copyright 2015 Google, Inc
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

require_relative "spec_helper"
require_relative "../import"

RSpec.describe "Import table data" do
  before do
    @sample = Samples::BigQuery::Import.new

    # create a temporary dataset / table
    require "gcloud"
    gcloud = Gcloud.new PROJECT_ID
    @bigquery = gcloud.bigquery
    @dataset = @bigquery.create_dataset "test_dataset_#{Time.now.to_i}"
  end

  after do
    # delete the temporary dataset
    @dataset.delete force: true
  end

  [
    [File.expand_path("spec/data/test_data.json"), "JSON"],
    [File.expand_path("spec/data/test_data.csv"), "CSV"],
    ["gs://#{BUCKET_NAME}/test_data.json", "Cloud Storage JSON"],
    ["gs://#{BUCKET_NAME}/test_data.csv", "Cloud Storage CSV"]
  ].each do |source, type|
    it "Import #{type}" do
      if type.start_with?("Cloud Storage") and not BUCKET_NAME
        skip "Set GOOGLE_BUCKET_NAME to run this test"
      end
      table_name = "test_import_#{type.downcase.gsub(" ", "_")}"

      # create temporary table
      @dataset.create_table table_name do |schema|
        schema.string "name", mode: :required
        schema.string "title", mode: :required
      end

      # Run the sample with a test dataset
      expect { @sample.import PROJECT_ID, @dataset.dataset_id, table_name, source }.to(
        output(/Data imported successfully/).to_stdout)

      # Query to ensure our results were imported as expected
      result = @bigquery.query "SELECT * FROM #{@dataset.dataset_id}.#{table_name}"
      expect(result.size).to eq(3)
      expect(result[0]).to include("name" => "Brent Shaffer")
      expect(result[1]).to include("name" => "Remi Taylor")
      expect(result[2]).to include("name" => "Jeff Mendoza")
    end
  end
end
