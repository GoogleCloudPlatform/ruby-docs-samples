# frozen_string_literal: true

# [START dependencies]
require "google-cloud-bigtable"
# [END dependencies]

# [START connecting_to_bigtable]
table_id = "Hello-Bigtable"
instance_id = "my-instance"
column_family = "cf"
column_qualifier = "greeting"

gcloud = Google::Cloud.new
bigtable = gcloud.bigtable
# [END connecting_to_bigtable]

# [START creating_a_table]
if bigtable.table(instance_id, table_id).exists?
  puts " '#{table_id}' is already exists."
  exit 0
else
  table = bigtable.create_table(instance_id, table_id) do |column_families|
    column_families.add(
      column_family,
      Google::Cloud::Bigtable::GcRule.max_versions 1
    )
  end

  puts "Table '#{table_id}' created."
end
# [END creating_a_table]

# [START writing_rows]
puts "Write some greetings to the table '#{table_id}'"
greetings = ["Hello World!", "Hello Bigtable!", "Hello Ruby!"]

# Insert rows one by one
# Note: To perform multiple mutation on multiple rows use `mutate_rows`.
greetings.each_with_index do |value, i|
  puts "  Writing,  Row key: greeting#{i}, Value: #{value}"

  entry = table.new_mutation_entry "greeting#{i}"
  entry.set_cell(
    column_family,
    column_qualifier,
    value,
    timestamp: Time.now.to_i * 1000
  )

  table.mutate_row entry
end
# [END writing_rows]

# [START creating_a_filter]
# Only retrieve the most recent version of the cell.
filter = Google::Cloud::Bigtable::RowFilter.cells_per_column 1
# [END creating_a_filter]

# [START getting_a_row]
puts "Reading a single row by row key"
row = table.read_row "greeting0", filter: filter
puts "Row key: #{row.key}, Value: #{row.cells[column_family].first.value}"
# [START getting_a_row]

# [START scanning_all_rows]
puts "Reading the entire table"
table.read_rows.each do |row|
  p "Row key: #{row.key}, Value: #{row.cells[column_family].first.value}"
end
# [END scanning_all_rows]

# [START deleting_a_table]
puts "Deleting the table '#{table_id}'"
bigtable.delete_table instance_id, table_id
# [END deleting_a_table]
