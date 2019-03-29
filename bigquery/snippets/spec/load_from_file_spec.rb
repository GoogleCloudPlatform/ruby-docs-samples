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

require_relative "../load_from_file"
require "spec_helper"


describe "Load table" do
  before do
    @dataset = create_temp_dataset
  end

  example "Load a new table from a local CSV file" do
    file_path = File.expand_path "../resources/people.csv", __dir__

    output = capture { load_from_file @dataset.dataset_id, file_path }

    table = @dataset.tables.first
    expect(output).to include(table.table_id)
    expect(output).to include("2 rows")
  end
end
