require_relative "spec_helper"
require "securerandom"

describe "Google Cloud Bigtable Hello World" do
  it "create table, write rows and read rows" do
    table_id = "test_table_#{SecureRandom.hex 8}"
    table = @bigtable.table @instance_id, table_id

    unless table.exists?
      table = @bigtable.create_table @instance_id, table_id do |cf|
        cf.add "cf", Google::Cloud::Bigtable::GcRule.max_versions(1)
      end
    end

    expect(Google::Cloud::Bigtable).to receive(:new)
      .with(project_id: "YOUR_PROJECT_ID")
      .and_return(@bigtable)

    expect(@bigtable).to receive(:table)
      .with("my-instance", "Hello-Bigtable")
      .and_return(table)

    expect(table).to receive(:exists?).and_return(false)

    expect(@bigtable).to receive(:create_table)
      .with("my-instance", "Hello-Bigtable")
      .and_return(table)

    output = capture do
      load File.expand_path("../hello_world.rb", __dir__)
    end

    expect(output).to include "Table Hello-Bigtable created"
    expect(output).to include "Writing,  Row key: greeting0, Value: Hello World!"
    expect(output).to include "Row key: greeting0, Value: Hello World!"
    expect(output).to include "Deleting the table Hello-Bigtable"
  end
end
