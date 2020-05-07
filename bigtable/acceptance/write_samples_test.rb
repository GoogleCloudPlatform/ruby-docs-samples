# Copyright 2020 Google LLC
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

require_relative "helper"
require_relative "../write_samples"

describe Google::Cloud::Bigtable, "Write Samples", :bigtable do
  before(:all) do
    @table_id = "mobile-time-series-#{SecureRandom.hex 8}"

    bigtable = Google::Cloud::Bigtable.new project_id: @project_id

    puts "Creating table."
    column_families = Google::Cloud::Bigtable::ColumnFamilyMap.new
    column_families.add "stats_summary", gc_rule: nil

    @table = bigtable.create_table @instance_id, @table_id, column_families: column_families
  end

  it "writes one row" do
    output = capture do
      write_simple @project_id, @instance_id, @table_id
    end

    expect(output).to include "Successfully wrote row"
  end

  it "writes multiple rows" do
    output = capture do
      write_batch @project_id, @instance_id, @table_id
    end

    expect(output).to include "Successfully wrote 2 rows"
  end

  it "increments a row" do
    output = capture do
      write_increment @project_id, @instance_id, @table_id
    end

    expect(output).to include "Successfully updated row"
  end

  it "conditionally writes a row" do
    output = capture do
      write_conditional @project_id, @instance_id, @table_id
    end

    expect(output).to include "Successfully updated row's os_name: true"
  end

  after(:all) do
    puts "Deleting table."
    @table.delete
  end

end
