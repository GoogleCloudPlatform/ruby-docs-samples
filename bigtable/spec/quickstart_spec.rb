require "rspec"
require "securerandom"
require "google/cloud/bigtable"

describe "Google Cloud Bigtable Quickstart" do
  it "read one row and print" do
    project_id  = ENV["GOOGLE_CLOUD_BIGTABLE_PROJECT"]
    instance_id = ENV["GOOGLE_CLOUD_BIGTABLE_TEST_INSTANCE"]

    if project_id.nil? || instance_id.nil?
      skip "GOOGLE_CLOUD_BIGTABLE_TEST_INSTANCE and/or " \
        "GOOGLE_CLOUD_BIGTABLE_PROJECT not defined"
    end

    bigtable = Google::Cloud::Bigtable.new project_id: project_id
    table_id = "test_table_#{SecureRandom.hex(8)}"
    table = bigtable.table instance_id, table_id

    unless table.exists?
      table = bigtable.create_table instance_id, table_id do |cf|
        cf.add("cf", Google::Cloud::Bigtable::GcRule.max_versions(1))
      end
    end

    # Write row
    entry = table.new_mutation_entry("user0000001")
    entry.set_cell("cf", "field1", "XYZ")
    table.mutate_row(entry)

    expect(Google::Cloud::Bigtable).to receive(:new)
      .with(project_id: "YOUR_PROJECT_ID")
      .and_return(bigtable)

    expect(bigtable).to receive(:table)
      .with("my-bigtable-instance", "my-table")
      .and_return(table)

    expect do
      load File.expand_path("../quickstart.rb", __dir__)
    end.to output(/user0000001/).to_stdout

    table.delete
  end
end
