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

require "gcloud"
require_relative "spec_helper"
require_relative "../import"

RSpec.describe "Import table data" do
  before do
    # Create a temporary dataset.
    gcloud = Gcloud.new PROJECT_ID
    @bigquery = gcloud.bigquery
    @dataset = @bigquery.create_dataset "test_dataset_#{Time.now.to_i}"
  end

  after do
    # Delete the temporary dataset.
    @dataset.delete force: true
  end

  it "Imports JSON" do
    table_id = "test_import_json"
    source = File.expand_path("spec/data/test_data.json")

    # Create a temporary table.
    @dataset.create_table table_id do |schema|
      schema.string "name", mode: :required
      schema.string "title", mode: :required
    end

    # Run the import function.
    expect { import PROJECT_ID, @dataset.dataset_id, table_id, source }.to(
      output(/Data imported successfully/).to_stdout)

    # Query to ensure our results were imported as expected
    result = @bigquery.query "SELECT * FROM #{@dataset.dataset_id}.#{table_id}"
    expect(result.size).to eq(2)
    expect(result[0]).to include("name" => "Alice")
    expect(result[1]).to include("name" => "Caterpillar")
  end

  it "Imports CSV" do
    table_id = "test_import_csv"
    source = File.expand_path("spec/data/test_data.csv")

    # create temporary table.
    @dataset.create_table table_id do |schema|
      schema.string "name", mode: :required
      schema.string "title", mode: :required
    end

    # Run the import function.
    expect { import PROJECT_ID, @dataset.dataset_id, table_id, source }.to(
      output(/Data imported successfully/).to_stdout)

    # Query to ensure our results were imported as expected.
    result = @bigquery.query "SELECT * FROM #{@dataset.dataset_id}.#{table_id}"
    expect(result.size).to eq(2)
    expect(result[0]).to include("name" => "Alice")
    expect(result[1]).to include("name" => "Caterpillar")
  end

  it "Imports JSON from Cloud Storage" do
    if not BUCKET_NAME
      skip "Set GOOGLE_BUCKET_NAME to run this test"
    end
    table_id = "test_import_json"
    source = "gs://#{BUCKET_NAME}/test_data.json"

    # Create temporary table.
    @dataset.create_table table_id do |schema|
      schema.string "name", mode: :required
      schema.string "title", mode: :required
    end

    # Run the import function.
    expect { import PROJECT_ID, @dataset.dataset_id, table_id, source }.to(
      output(/Data imported successfully/).to_stdout)

    # Query to ensure our results were imported as expected.
    result = @bigquery.query "SELECT * FROM #{@dataset.dataset_id}.#{table_id}"
    expect(result.size).to eq(2)
    expect(result[0]).to include("name" => "Alice")
    expect(result[1]).to include("name" => "Caterpillar")
  end

  it "Imports CSV from Cloud Storage" do
    if not BUCKET_NAME
      skip "Set GOOGLE_BUCKET_NAME to run this test"
    end
    table_id = "test_import_csv"
    source = "gs://#{BUCKET_NAME}/test_data.csv"

    # create temporary table.
    @dataset.create_table table_id do |schema|
      schema.string "name", mode: :required
      schema.string "title", mode: :required
    end

    # Run the import function.
    expect { import PROJECT_ID, @dataset.dataset_id, table_id, source }.to(
      output(/Data imported successfully/).to_stdout)

    # Query to ensure our results were imported as expected.
    result = @bigquery.query "SELECT * FROM #{@dataset.dataset_id}.#{table_id}"
    expect(result.size).to eq(2)
    expect(result[0]).to include("name" => "Alice")
    expect(result[1]).to include("name" => "Caterpillar")
  end
end
