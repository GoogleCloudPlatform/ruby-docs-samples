# frozen_string_literal: true

# Copyright 2019 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# [START bigtable_filters_limit_row_sample]
# [START bigtable_filters_limit_row_regex]
# [START bigtable_filters_limit_cells_per_col]
# [START bigtable_filters_limit_cells_per_row]
# [START bigtable_filters_limit_cells_per_row_offset]
# [START bigtable_filters_limit_col_family_regex]
# [START bigtable_filters_limit_col_qualifier_regex]
# [START bigtable_filters_limit_col_range]
# [START bigtable_filters_limit_value_range]
# [START bigtable_filters_limit_value_regex]
# [START bigtable_filters_limit_timestamp_range]
# [START bigtable_filters_limit_block_all]
# [START bigtable_filters_limit_pass_all]
# [START bigtable_filters_modify_strip_value]
# [START bigtable_filters_modify_apply_label]
# [START bigtable_filters_composing_chain]
# [START bigtable_filters_composing_interleave]
# [START bigtable_filters_composing_condition]

# Import google bigtable client lib
require "google/cloud/bigtable"

# [END bigtable_filters_limit_row_sample]
# [END bigtable_filters_limit_row_regex]
# [END bigtable_filters_limit_cells_per_col]
# [END bigtable_filters_limit_cells_per_row]
# [END bigtable_filters_limit_cells_per_row_offset]
# [END bigtable_filters_limit_col_family_regex]
# [END bigtable_filters_limit_col_qualifier_regex]
# [END bigtable_filters_limit_col_range]
# [END bigtable_filters_limit_value_range]
# [END bigtable_filters_limit_value_regex]
# [END bigtable_filters_limit_timestamp_range]
# [END bigtable_filters_limit_block_all]
# [END bigtable_filters_limit_pass_all]
# [END bigtable_filters_modify_strip_value]
# [END bigtable_filters_modify_apply_label]
# [END bigtable_filters_composing_chain]
# [END bigtable_filters_composing_interleave]
# [END bigtable_filters_composing_condition]

def filter_limit_row_sample project_id, instance_id, table_id
  # [START bigtable_filters_limit_row_sample]
  filter = Google::Cloud::Bigtable::RowFilter.sample 0.75
  read_with_filter project_id, instance_id, table_id, filter
  # [END bigtable_filters_limit_row_sample]
end

def filter_limit_row_regex project_id, instance_id, table_id
  # [START bigtable_filters_limit_row_regex]
  filter = Google::Cloud::Bigtable::RowFilter.key ".*#20190501$"
  read_with_filter project_id, instance_id, table_id, filter
  # [END bigtable_filters_limit_row_regex]
end

def filter_limit_cells_per_col project_id, instance_id, table_id
  # [START bigtable_filters_limit_cells_per_col]
  filter = Google::Cloud::Bigtable::RowFilter.cells_per_column 2
  read_with_filter project_id, instance_id, table_id, filter
  # [END bigtable_filters_limit_cells_per_col]
end

def filter_limit_cells_per_row project_id, instance_id, table_id
  # [START bigtable_filters_limit_cells_per_row]
  filter = Google::Cloud::Bigtable::RowFilter.cells_per_row 2
  read_with_filter project_id, instance_id, table_id, filter
  # [END bigtable_filters_limit_cells_per_row]
end

def filter_limit_cells_per_row_offset project_id, instance_id, table_id
  # [START bigtable_filters_limit_cells_per_row_offset]
  filter = Google::Cloud::Bigtable::RowFilter.cells_per_row_offset 2
  read_with_filter project_id, instance_id, table_id, filter
  # [END bigtable_filters_limit_cells_per_row_offset]
end

def filter_limit_col_family_regex project_id, instance_id, table_id
  # [START bigtable_filters_limit_col_family_regex]
  filter = Google::Cloud::Bigtable::RowFilter.family "stats_.*$"
  read_with_filter project_id, instance_id, table_id, filter
  # [END bigtable_filters_limit_col_family_regex]
end

def filter_limit_col_qualifier_regex project_id, instance_id, table_id
  # [START bigtable_filters_limit_col_qualifier_regex]
  filter = Google::Cloud::Bigtable::RowFilter.qualifier "connected_.*$"
  read_with_filter project_id, instance_id, table_id, filter
  # [END bigtable_filters_limit_col_qualifier_regex]
end

def filter_limit_col_range project_id, instance_id, table_id
  # [START bigtable_filters_limit_col_range]
  range = Google::Cloud::Bigtable::ColumnRange.new("cell_plan").from("data_plan_01gb").to("data_plan_10gb")
  filter = Google::Cloud::Bigtable::RowFilter.column_range range
  read_with_filter project_id, instance_id, table_id, filter
  # [END bigtable_filters_limit_col_range]
end

def filter_limit_value_range project_id, instance_id, table_id
  # [START bigtable_filters_limit_value_range]
  range = Google::Cloud::Bigtable::ValueRange.new.from("PQ2A.190405").to("PQ2A.190406")
  filter = Google::Cloud::Bigtable::RowFilter.value_range range
  read_with_filter project_id, instance_id, table_id, filter
  # [END bigtable_filters_limit_value_range]
end

def filter_limit_value_regex project_id, instance_id, table_id
  # [START bigtable_filters_limit_value_regex]
  filter = Google::Cloud::Bigtable::RowFilter.value "PQ2A.*$"
  read_with_filter project_id, instance_id, table_id, filter
  # [END bigtable_filters_limit_value_regex]
end

def filter_limit_timestamp_range project_id, instance_id, table_id
  # [START bigtable_filters_limit_timestamp_range]
  timestamp_minus_hr = (Time.now.to_f * 1_000_000).round(-3) - 60 * 60 * 1000 * 1000
  puts timestamp_minus_hr
  filter = Google::Cloud::Bigtable::RowFilter.timestamp_range from: 0, to: timestamp_minus_hr

  read_with_filter project_id, instance_id, table_id, filter
  # [END bigtable_filters_limit_timestamp_range]
end

def filter_limit_block_all project_id, instance_id, table_id
  # [START bigtable_filters_limit_block_all]
  filter = Google::Cloud::Bigtable::RowFilter.block
  read_with_filter project_id, instance_id, table_id, filter
  # [END bigtable_filters_limit_block_all]
end

def filter_limit_pass_all project_id, instance_id, table_id
  # [START bigtable_filters_limit_pass_all]
  filter = Google::Cloud::Bigtable::RowFilter.pass
  read_with_filter project_id, instance_id, table_id, filter
  # [END bigtable_filters_limit_pass_all]
end

def filter_modify_strip_value project_id, instance_id, table_id
  # [START bigtable_filters_modify_strip_value]
  filter = Google::Cloud::Bigtable::RowFilter.strip_value
  read_with_filter project_id, instance_id, table_id, filter
  # [END bigtable_filters_modify_strip_value]
end

def filter_modify_apply_label project_id, instance_id, table_id
  # [START bigtable_filters_modify_apply_label]
  filter = Google::Cloud::Bigtable::RowFilter.label "labelled"
  read_with_filter project_id, instance_id, table_id, filter
  # [END bigtable_filters_modify_apply_label]
end

def filter_composing_chain project_id, instance_id, table_id
  # [START bigtable_filters_composing_chain]
  filter = Google::Cloud::Bigtable::RowFilter.chain.cells_per_column(1).family("cell_plan")
  read_with_filter project_id, instance_id, table_id, filter
  # [END bigtable_filters_composing_chain]
end

def filter_composing_interleave project_id, instance_id, table_id
  filter = Google::Cloud::Bigtable::RowFilter.interleave.value("true").qualifier("os_build")
  read_with_filter project_id, instance_id, table_id, filter
  # [END bigtable_filters_composing_interleave]
end

def filter_composing_condition project_id, instance_id, table_id
  # [START bigtable_filters_composing_condition]
  filter = Google::Cloud::Bigtable::RowFilter.condition(
    Google::Cloud::Bigtable::RowFilter.chain.qualifier("data_plan_10gb").value("true")
  )
                                             .on_match(Google::Cloud::Bigtable::RowFilter.label("passed-filter"))
                                             .otherwise(Google::Cloud::Bigtable::RowFilter.label("filtered-out"))
  read_with_filter project_id, instance_id, table_id, filter
  # [END bigtable_filters_composing_condition]
end


# [START bigtable_filters_limit_row_sample]
# [START bigtable_filters_limit_row_regex]
# [START bigtable_filters_limit_cells_per_col]
# [START bigtable_filters_limit_cells_per_row]
# [START bigtable_filters_limit_cells_per_row_offset]
# [START bigtable_filters_limit_col_family_regex]
# [START bigtable_filters_limit_col_qualifier_regex]
# [START bigtable_filters_limit_col_range]
# [START bigtable_filters_limit_value_range]
# [START bigtable_filters_limit_value_regex]
# [START bigtable_filters_limit_timestamp_range]
# [START bigtable_filters_limit_block_all]
# [START bigtable_filters_limit_pass_all]
# [START bigtable_filters_modify_strip_value]
# [START bigtable_filters_modify_apply_label]
# [START bigtable_filters_composing_chain]
# [START bigtable_filters_composing_interleave]
# [START bigtable_filters_composing_condition]


def read_with_filter project_id, instance_id, table_id, filter
  bigtable = Google::Cloud::Bigtable.new project_id: project_id
  table = bigtable.table instance_id, table_id

  table.read_rows(filter: filter).each do |row|
    print_row row
  end
end

def print_row row
  puts "Reading data for #{row.key}:"

  row.cells.each do |column_family, data|
    puts "Column Family #{column_family}"
    data.each do |cell|
      labels = !cell.labels.empty? ? " [#{cell.labels.join ','}]" : ""
      puts "\t#{cell.qualifier}: #{cell.value} @#{cell.timestamp}#{labels}"
    end
  end
  puts "\n"
end

# [END bigtable_filters_limit_row_sample]
# [END bigtable_filters_limit_row_regex]
# [END bigtable_filters_limit_cells_per_col]
# [END bigtable_filters_limit_cells_per_row]
# [END bigtable_filters_limit_cells_per_row_offset]
# [END bigtable_filters_limit_col_family_regex]
# [END bigtable_filters_limit_col_qualifier_regex]
# [END bigtable_filters_limit_col_range]
# [END bigtable_filters_limit_value_range]
# [END bigtable_filters_limit_value_regex]
# [END bigtable_filters_limit_timestamp_range]
# [END bigtable_filters_limit_block_all]
# [END bigtable_filters_limit_pass_all]
# [END bigtable_filters_modify_strip_value]
# [END bigtable_filters_modify_apply_label]
# [END bigtable_filters_composing_chain]
# [END bigtable_filters_composing_interleave]
# [END bigtable_filters_composing_condition]
