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

require_relative "../load_table_gcs_orc"
require_relative "../load_table_gcs_orc_truncate"
require "spec_helper"


describe "Load table from Orc file on GCS and replace existing table data" do
  before do
    @dataset = create_temp_dataset
  end

  example "Load table from Orc file on GCS and replace existing table data" do
    load_table_gcs_orc @dataset.dataset_id
    table = @dataset.tables.first
    expect(table.rows_count).to eq(50)

    output = capture do
      load_table_gcs_orc_truncate @dataset.dataset_id, table.table_id
    end

    table.reload!
    expect(output).to include(table.table_id)
    expect(output).to include("50 rows")
  end
end
