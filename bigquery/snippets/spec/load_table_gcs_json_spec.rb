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

require_relative "../load_table_gcs_json"
require "spec_helper"


describe "Load table from JSON file on GCS" do
  before do
    @dataset = create_temp_dataset
  end

  example "Load a new table from a JSON file on GCS" do
    output = capture { load_table_gcs_json @dataset.dataset_id }

    table = @dataset.tables.first
    expect(output).to include(table.table_id)
    expect(output).to include("50 rows")
  end
end
