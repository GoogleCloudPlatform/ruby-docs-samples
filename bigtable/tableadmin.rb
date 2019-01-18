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
require "google-cloud-bigtable"

def run_table_operations instance_id, table_id
  bigtable = Google::Cloud.new.bigtable
  p "==> Checking if table exists"
  table = bigtable.table(instance_id, table_id, perform_lookup: true)

  if table
    p "==> Table exists"
  else
    p "==> Table does not exist. Creating table `#{table_id}`"
    # [START bigtable_create_table]
    table = bigtable.create_table(instance_id, table_id)
    p "==> Table created #{table.name}"
    # [END bigtable_create_table]
  end

  p "==> Listing tables in instance"
  # [START bigtable_list_tables]
  bigtable.tables(instance_id).all.each do |t|
    p t.name
  end
  # [END bigtable_list_tables]

  p "==> Get table and print details:"
  # [START bigtable_get_table_metadata]
  table = bigtable.table(
    instance_id,
    table_id,
    view: :FULL,
    perform_lookup: true
  )
  p "Cluster states:"
  table.cluster_states.each { |s| p s }
  # [END bigtable_get_table_metadata]

  p "Timestamp granularity: #{table.granularity}"
  p "==> 1. Creating column family `cf1` with max age GC rule"
  # [START bigtable_create_family_gc_max_age]
  # Create a column family with GC policy : maximum age
  # where age = current time minus cell timestamp
  # NOTE: Age value must be atleast 1 millisecond
  gc_rule = Google::Cloud::Bigtable::GcRule.max_age(60 * 60 * 24 * 5)
  family = table.column_family("cf1", gc_rule).create
  # [END bigtable_create_family_gc_max_age]

  p "==> Created column family: `#{family.name}`"
  p "==> 2. Creating column family cf2 with max versions GC rule"
  # [START bigtable_create_family_gc_max_versions]
  # Create a column family with GC policy : most recent N versions
  # where 1 = most recent version
  gc_rule = Google::Cloud::Bigtable::GcRule.max_versions(3)
  family = table.column_family("cf2", gc_rule).create
  # [END bigtable_create_family_gc_max_versions]

  p "==> Created column family: `#{family.name}`"
  p "==> 3. Creating column family cf3 with union GC rule"
  # [START bigtable_create_family_gc_union]
  # Create a column family with GC policy to drop data that matches at least
  # one condition
  gc_rule = Google::Cloud::Bigtable::GcRule.max_age(60 * 60 * 24 * 5)
  union_gc_rule = Google::Cloud::Bigtable::GcRule.union(gc_rule)
  family = table.column_family("cf3", union_gc_rule).create
  # [END bigtable_create_family_gc_union]
  p "==> Created column family: `#{family.name}`"


  p "==> 4. Creating column family cf4 with intersect GC rule"
  # [START bigtable_create_family_gc_intersection]
  # Create a column family with GC policy to drop data that matches at least
  # one condition
  gc_rule = Google::Cloud::Bigtable::GcRule.max_age(60 * 60 * 24 * 5)
  intersection_gc_rule = Google::Cloud::Bigtable::GcRule.intersection(gc_rule)
  family = table.column_family("cf4", intersection_gc_rule).create
  # [END bigtable_create_family_gc_intersection]
  p "==> Created column family: `#{family.name}`"


  p "==> 5. Creating column family cf5 with a nested GC rule"
  # [START bigtable_create_family_gc_nested]
  # Create a nested GC rule:
  # Drop cells that are either older than the 10 recent versions
  # OR
  # Drop cells that are older than a month AND older than the 2 recent versions
  gc_rule1 = Google::Cloud::Bigtable::GcRule.max_age(60 * 60 * 24 * 30)
  gc_rule2 = Google::Cloud::Bigtable::GcRule.max_versions(2)
  nested_gc_rule = Google::Cloud::Bigtable::GcRule.union(gc_rule1, gc_rule2)
  # [END bigtable_create_family_gc_nested]
  family = table.column_family("cf5", nested_gc_rule).create
  p "==> Created column family: `#{family.name}`"
  p "==> Printing name and GC Rule for all column families"

  # [START bigtable_list_column_families]
  table = bigtable.table(
    instance_id,
    table_id,
    view: :FULL,
    perform_lookup: true
  )
  table.column_families.each do |f|
    p "Column family name: #{f.name}"
    p "GC Rule:"
    p f.gc_rule
  end
  # [END bigtable_list_column_families]

  p "==> Updating column family cf1 GC rule"
  # [START bigtable_update_gc_rule]
  family = table.column_families.find { |cf| cf.name == "cf1" }
  family.gc_rule = Google::Cloud::Bigtable::GcRule.max_versions(1)
  updated_family = family.save
  p updated_family
  # [END bigtable_update_gc_rule]
  p "==> Updated GC rule."

  p "==> Print updated column family cf1 GC rule"
  # [START bigtable_family_get_gc_rule]
  family = table.column_families.find { |cf| cf.name == "cf1" }
  # [END bigtable_family_get_gc_rule]
  p family

  p "==> Delete a column family cf2"
  # [START bigtable_delete_family]
  family = table.column_families.find { |cf| cf.name == "cf2" }
  family.delete
  # [END bigtable_delete_family]
  p "==> #{family.name} deleted successfully"
  p "===> Run `bundle exec tableadmin.rb delete instance_id table_id` \
to delete the table"
end

def delete_table instance_id, table_id
  bigtable = Google::Cloud.new.bigtable

  p "==> Delete the table."
  #  [START bigtable_delete_table]
  table = bigtable.table(instance_id, table_id)
  table.delete
  #  [END bigtable_delete_table]

  p "==> Table deleted: #{table.name}"
end

if __FILE__ == $PROGRAM_NAME
  case ARGV.shift
  when "run"
    run_table_operations ARGV.shift, ARGV.shift
  when "delete"
    delete_table ARGV.shift, ARGV.shift
  else
    puts <<~USAGE
      Perform Bigtable Table admin operations
      Usage: bundle exec ruby tableadmin.rb [command] [arguments]

      Commands:
        run          <instance_id> <table_id>     Create a table (if does not exist) and run basic table operations
        delete       <instance_id> <table_id>     Delete table
     USAGE
   end
end
