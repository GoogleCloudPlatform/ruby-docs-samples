require_relative "spec_helper"
require "securerandom"

describe "Google Cloud Bigtable Quickstart" do
  it "read one row and print" do
    table_id = "test_table_#{SecureRandom.hex 8}"
    table = @bigtable.table @instance_id, table_id

    unless table.exists?
      table = @bigtable.create_table @instance_id, table_id do |cf|
        cf.add "cf", Google::Cloud::Bigtable::GcRule.max_versions(1)
      end
    end

    # Write row
    entry = table.new_mutation_entry "user0000001"
    entry.set_cell "cf", "field1", "XYZ"
    table.mutate_row entry

    expect(Google::Cloud::Bigtable).to receive(:new)
      .with(project_id: "YOUR_PROJECT_ID")
      .and_return(@bigtable)

    expect(@bigtable).to receive(:table)
      .with("my-bigtable-instance", "my-table")
      .and_return(table)

    expect {
      load File.expand_path("../quickstart.rb", __dir__)
    }.to output(/user0000001/).to_stdout

    table.delete
  end
end
