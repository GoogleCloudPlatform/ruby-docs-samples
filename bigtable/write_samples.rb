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


# Import google bigtable client lib
require "google/cloud/bigtable"

def write_simple project_id, instance_id, table_id
  bigtable = Google::Cloud::Bigtable.new project_id: project_id

  #  [START bigtable_writes_simple]
  table = bigtable.table instance_id, table_id
  $COLUMN_FAMILY = "stats_summary"
  timestamp = Time.now.to_i * 1000

  rowkey = "phone#4c410523#20190501"
  entry = table.new_mutation_entry(rowkey)
              .set_cell($COLUMN_FAMILY, "connected_cell", 1, timestamp: timestamp)
              .set_cell($COLUMN_FAMILY, "connected_wifi", 1, timestamp: timestamp)
              .set_cell($COLUMN_FAMILY, "os_build", "PQ2A.190405.003", timestamp: timestamp)

  table.mutate_row(entry)
  puts "Successfully wrote row #{rowkey}"
  #  [END bigtable_writes_simple]
end

def write_batch project_id, instance_id, table_id
  bigtable = Google::Cloud::Bigtable.new project_id: project_id

  #  [START bigtable_writes_batch]
  table = bigtable.table instance_id, table_id
  $COLUMN_FAMILY = "stats_summary"
  timestamp = Time.now.to_i * 1000

  entries = []
  entries << table.new_mutation_entry("tablet#a0b81f74#20190501")
                 .set_cell($COLUMN_FAMILY, "connected_cell", 1, timestamp: timestamp)
                 .set_cell($COLUMN_FAMILY, "os_build", "12155.0.0-rc1", timestamp: timestamp)
  entries << table.new_mutation_entry("tablet#a0b81f74#20190502")
                 .set_cell($COLUMN_FAMILY, "connected_cell", 1, timestamp: timestamp)
                 .set_cell($COLUMN_FAMILY, "os_build", "12155.0.0-rc6", timestamp: timestamp)

  results = table.mutate_rows(entries)
  puts "Successfully wrote #{results.length} rows"
  #  [END bigtable_writes_batch]
end

def write_increment project_id, instance_id, table_id
  bigtable = Google::Cloud::Bigtable.new project_id: project_id

  #  [START bigtable_writes_increment]
  table = bigtable.table instance_id, table_id
  $COLUMN_FAMILY = "stats_summary"

  rowkey = "phone#4c410523#20190501"
  decrementRule = table.new_read_modify_write_rule($COLUMN_FAMILY, "connected_wifi")
                      .increment(-1)

  row = table.read_modify_write_row(rowkey, decrementRule)
  puts "Successfully updated row #{row.key}"
  #  [END bigtable_writes_increment]
end

def write_conditional project_id, instance_id, table_id
  bigtable = Google::Cloud::Bigtable.new project_id: project_id

  #  [START bigtable_writes_conditional]
  table = bigtable.table instance_id, table_id
  $COLUMN_FAMILY = "stats_summary"
  timestamp = Time.now.to_i * 1000

  rowkey = "phone#4c410523#20190501"
  predicate_filter = Google::Cloud::Bigtable::RowFilter.chain
                         .family($COLUMN_FAMILY)
                         .qualifier("os_build")
                         .value("PQ2A\\..*")

  on_match_mutations = Google::Cloud::Bigtable::MutationEntry.new
  on_match_mutations.set_cell(
      $COLUMN_FAMILY,
      "os_name",
      "android",
      timestamp: timestamp
  )

  response = table.check_and_mutate_row(
      rowkey,
      predicate_filter,
      on_match: on_match_mutations,
  )

  puts "Successfully updated row's os_name: #{response}"
  #  [END bigtable_writes_conditional]
end

if $PROGRAM_NAME == __FILE__
  project_id = ENV["GOOGLE_CLOUD_BIGTABLE_PROJECT"] ||
      ENV["GOOGLE_CLOUD_PROJECT"]
  # instance_id = ENV["BIGTABLE_INSTANCE"]

  case ARGV.shift
  when "simple"
    write_simple project_id, ARGV.shift, ARGV.shift
  when "batch"
    write_batch project_id, ARGV.shift, ARGV.shift
  when "increment"
    write_increment project_id, ARGV.shift, ARGV.shift
  when "conditional"
    write_conditional project_id, ARGV.shift, ARGV.shift
  else
    puts <<~USAGE
      Perform Bigtable Table admin operations
      Usage: bundle exec ruby write_samples.rb [command] [arguments]

      Commands:
        simple       <instance_id> <table_id>     Performs a write on one row.
        batch        <instance_id> <table_id>     Performs a write on multiple rows.
        increment    <instance_id> <table_id>     Increments a cell value.
        conditional  <instance_id> <table_id>     Conditionally performs a write.

      Environment variables:
        GOOGLE_CLOUD_BIGTABLE_PROJECT or GOOGLE_CLOUD_PROJECT must be set to your Google Cloud project ID
        BIGTABLE_INSTANCE must be set to your Google Cloud Bigtable instance id
    USAGE
  end
end
