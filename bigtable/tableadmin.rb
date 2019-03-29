# frozen_string_literal: true

# Copyright 2018 Google LLC
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

def run_table_operations project_id, instance_id, table_id
  bigtable = Google::Cloud::Bigtable.new project_id: project_id
  puts "Checking if table exists"
  table = bigtable.table instance_id, table_id, perform_lookup: true

  if table
    puts "Table exists"
  else
    puts "Table does not exist. Creating table #{table_id}"
    # [START bigtable_create_table]
    table = bigtable.create_table instance_id, table_id
    puts "Table created #{table.name}"
    # [END bigtable_create_table]
  end

  puts "Listing tables in instance"
  # [START bigtable_list_tables]
  bigtable.tables(instance_id).all.each do |t|
    puts "Table: #{t.name}"
  end
  # [END bigtable_list_tables]

  puts "Get table and print details:"
  # [START bigtable_get_table_metadata]
  table = bigtable.table(
    instance_id,
    table_id,
    view:           :FULL,
    perform_lookup: true
  )
  puts "Cluster states:"
  table.cluster_states.each do |stats|
    p stats
  end
  # [END bigtable_get_table_metadata]

  puts "Timestamp granularity: #{table.granularity}"
  puts "1. Creating column family cf1 with max age GC rule"
  # [START bigtable_create_family_gc_max_age]
  # Create a column family with GC policy : maximum age
  # where age = current time minus cell timestamp
  # NOTE: Age value must be atleast 1 millisecond
  gc_rule = Google::Cloud::Bigtable::GcRule.max_age 60 * 60 * 24 * 5
  family = table.column_family("cf1", gc_rule).create
  # [END bigtable_create_family_gc_max_age]
  puts "Created column family with max age GC rule: #{family.name}"

  puts "2. Creating column family cf2 with max versions GC rule"
  # [START bigtable_create_family_gc_max_versions]
  # Create a column family with GC policy : most recent N versions
  # where 1 = most recent version
  gc_rule = Google::Cloud::Bigtable::GcRule.max_versions 3
  family = table.column_family("cf2", gc_rule).create
  # [END bigtable_create_family_gc_max_versions]
  puts "Created column family with max versions GC rule: #{family.name}"

  puts "3. Creating column family cf3 with union GC rule"
  # [START bigtable_create_family_gc_union]
  # Create a column family with GC policy to drop data that matches at least
  # one condition
  gc_rule = Google::Cloud::Bigtable::GcRule.max_age 60 * 60 * 24 * 5
  union_gc_rule = Google::Cloud::Bigtable::GcRule.union gc_rule
  family = table.column_family("cf3", union_gc_rule).create
  # [END bigtable_create_family_gc_union]
  puts "Created column family with union GC rule: #{family.name}"

  puts "4. Creating column family cf4 with intersect GC rule"
  # [START bigtable_create_family_gc_intersection]
  # Create a column family with GC policy to drop data that matches at least
  # one condition
  gc_rule = Google::Cloud::Bigtable::GcRule.max_age 60 * 60 * 24 * 5
  intersection_gc_rule = Google::Cloud::Bigtable::GcRule.intersection gc_rule
  family = table.column_family("cf4", intersection_gc_rule).create
  # [END bigtable_create_family_gc_intersection]
  puts "Created column family with intersect GC rule: #{family.name}"

  puts "5. Creating column family cf5 with a nested GC rule"
  # [START bigtable_create_family_gc_nested]
  # Create a nested GC rule:
  # Drop cells that are either older than the 10 recent versions
  # OR
  # Drop cells that are older than a month AND older than the 2 recent versions
  gc_rule1 = Google::Cloud::Bigtable::GcRule.max_age 60 * 60 * 24 * 30
  gc_rule2 = Google::Cloud::Bigtable::GcRule.max_versions 2
  nested_gc_rule = Google::Cloud::Bigtable::GcRule.union gc_rule1, gc_rule2
  # [END bigtable_create_family_gc_nested]
  family = table.column_family("cf5", nested_gc_rule).create
  puts "Created column family with a nested GC rule: #{family.name}"

  puts "Printing name and GC Rule for all column families"
  # [START bigtable_list_column_families]
  table = bigtable.table(
    instance_id,
    table_id,
    view:           :FULL,
    perform_lookup: true
  )
  table.column_families.each do |f|
    puts "Column family name: #{f.name}"
    puts "GC Rule:"
    p f.gc_rule
  end
  # [END bigtable_list_column_families]

  puts "Updating column family cf1 GC rule"
  # [START bigtable_update_gc_rule]
  family = table.column_families.find { |cf| cf.name == "cf1" }
  family.gc_rule = Google::Cloud::Bigtable::GcRule.max_versions 1
  updated_family = family.save
  p updated_family
  # [END bigtable_update_gc_rule]
  puts "Updated max version GC rule of column_family: cf1"

  puts "Print updated column family cf1 GC rule"
  # [START bigtable_family_get_gc_rule]
  family = table.column_families.find { |cf| cf.name == "cf1" }
  # [END bigtable_family_get_gc_rule]
  p family

  puts "Delete a column family cf2"
  # [START bigtable_delete_family]
  family = table.column_families.find { |cf| cf.name == "cf2" }
  family.delete
  # [END bigtable_delete_family]
  puts "Deleted column family: #{family.name}"
end

def delete_table project_id, instance_id, table_id
  bigtable = Google::Cloud::Bigtable.new project_id: project_id

  puts "Delete the table."
  #  [START bigtable_delete_table]
  table = bigtable.table instance_id, table_id
  table.delete
  #  [END bigtable_delete_table]

  puts "Table deleted: #{table.name}"
end

if $PROGRAM_NAME == __FILE__
  project_id = ENV["GOOGLE_CLOUD_BIGTABLE_PROJECT"] ||
               ENV["GOOGLE_CLOUD_PROJECT"]

  case ARGV.shift
  when "run"
    run_table_operations project_id, ARGV.shift, ARGV.shift
  when "delete"
    delete_table project_id, ARGV.shift, ARGV.shift
  else
    puts <<~USAGE
      Perform Bigtable Table admin operations
      Usage: bundle exec ruby tableadmin.rb [command] [arguments]

      Commands:
        run          <instance_id> <table_id>     Create a table (if does not exist) and run basic table operations
        delete       <instance_id> <table_id>     Delete table

      Environment variables:
        GOOGLE_CLOUD_BIGTABLE_PROJECT or GOOGLE_CLOUD_PROJECT must be set to your Google Cloud project ID
    USAGE
  end
end
