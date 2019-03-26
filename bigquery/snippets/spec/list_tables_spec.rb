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

require_relative "../list_tables"
require "spec_helper"


describe "List tables" do
  before do
    @dataset = create_temp_dataset
  end

  example "list tables in a dataset" do
    table1 = @dataset.create_table "test_table1_#{Time.now.to_i}"
    table2 = @dataset.create_table "test_table2_#{Time.now.to_i}"

    output = capture { list_tables @dataset.dataset_id }
    expect(output).to include(table1.table_id)
    expect(output).to include(table2.table_id)
  end
end
