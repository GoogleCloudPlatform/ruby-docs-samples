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
require_relative "../import_stream"

RSpec.describe "Stream Import into table" do
  before do
    # Create a temporary dataset.
    gcloud = Gcloud.new PROJECT_ID
    @bigquery = gcloud.bigquery
    @dataset = @bigquery.create_dataset "test_dataset_#{Time.now.to_i}"
  end

  after do
    # Delete the temporary dataset.
    # @dataset.delete force: true
  end

  it "returns the expected data" do
    # Create a temporary table.
    table_id = "test_table_stream"
    @dataset.create_table table_id do |schema|
      schema.string "name", mode: :required
      schema.string "title", mode: :required
    end

    # Have stdin populate "name" and "title" fields.
    allow($stdin).to receive(:gets).and_return("Captain", "Dog")
    # require "pp"

    expect { import_stream PROJECT_ID, "test_dataset", "test_table" }.to(
      output(/Row streamed into table successfully/).to_stdout)

    # Query to ensure our row exists.
    result = @bigquery.query "SELECT * FROM #{@dataset.dataset_id}.#{table_id}"

    expect(result.size).to eq(1)
    expect(result[0]).to include("name" => "Captain")
    expect(result[0]).to include("title" => "Dog")
  end
end
