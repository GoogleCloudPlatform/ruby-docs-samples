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
require_relative "../delete_table"

RSpec.describe "Delete table sample" do
  it "Deletes a table" do
    gcloud = Gcloud.new PROJECT_ID
    bigquery = gcloud.bigquery

    table_id = "test_dataset_#{Time.now.to_i}"
    dataset = bigquery.dataset "test_dataset"
    table = dataset.create_table table_id do |schema|
      schema.string "name", mode: :required
      schema.string "title", mode: :required
    end

    expect { delete_table PROJECT_ID, "test_dataset", table_id }.to(
      output(/Deleted table #{table_id}/).to_stdout)

    expect { table.reload! }.to raise_error(
      Gcloud::Bigquery::ApiError, "Not found: Table #{table.id}")
  end
end
