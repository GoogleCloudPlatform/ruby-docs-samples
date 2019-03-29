# frozen_string_literal: true

# [START bigtable_hw_imports]
require "google/cloud/bigtable"
# [END bigtable_hw_imports]

# [START bigtable_hw_connect]
project_id = "YOUR_PROJECT_ID"
table_id = "Hello-Bigtable"
instance_id = "my-instance"
column_family = "cf"
column_qualifier = "greeting"

bigtable = Google::Cloud::Bigtable.new project_id: project_id
# [END bigtable_hw_connect]

# [START bigtable_hw_create_table]
if bigtable.table(instance_id, table_id).exists?
  puts "#{table_id} is already exists."
  exit 0
else
  table = bigtable.create_table instance_id, table_id do |column_families|
    column_families.add(
      column_family,
      Google::Cloud::Bigtable::GcRule.max_versions(1)
    )
  end

  puts "Table #{table_id} created."
end
# [END bigtable_hw_create_table]

# [START bigtable_hw_write_rows]
puts "Write some greetings to the table #{table_id}"
greetings = ["Hello World!", "Hello Bigtable!", "Hello Ruby!"]

# Insert rows one by one
# Note: To perform multiple mutation on multiple rows use `mutate_rows`.
greetings.each_with_index do |value, i|
  puts " Writing,  Row key: greeting#{i}, Value: #{value}"

  entry = table.new_mutation_entry "greeting#{i}"
  entry.set_cell(
    column_family,
    column_qualifier,
    value,
    timestamp: Time.now.to_i * 1000
  )

  table.mutate_row entry
end
# [END bigtable_hw_write_rows]

# [START bigtable_hw_create_filter]
# Only retrieve the most recent version of the cell.
filter = Google::Cloud::Bigtable::RowFilter.cells_per_column 1
# [END bigtable_hw_create_filter]

# [START bigtable_hw_get_with_filter]
puts "Reading a single row by row key"
row = table.read_row "greeting0", filter: filter
puts "Row key: #{row.key}, Value: #{row.cells[column_family].first.value}"
# [START bigtable_hw_get_with_filter]

# [START bigtable_hw_scan_with_filter]
puts "Reading the entire table"
table.read_rows.each do |row|
  puts "Row key: #{row.key}, Value: #{row.cells[column_family].first.value}"
end
# [END bigtable_hw_scan_with_filter]

# [START bigtable_hw_delete_table]
puts "Deleting the table #{table_id}"
table.delete
# [END bigtable_hw_delete_table]
