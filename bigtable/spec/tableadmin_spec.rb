require_relative "spec_helper"
require "securerandom"
require "google/cloud/bigtable"
require_relative "../tableadmin"

describe "Google Cloud Bigtable instance Samples" do
  before do
    @project_id  = ENV["GOOGLE_CLOUD_BIGTABLE_PROJECT"]
    @instance_id = ENV["GOOGLE_CLOUD_BIGTABLE_TEST_INSTANCE"]

    if @project_id.nil? || @instance_id.nil?
      skip "GOOGLE_CLOUD_BIGTABLE_TEST_INSTANCE and/or " \
        "GOOGLE_CLOUD_BIGTABLE_PROJECT not defined"
    end

    @bigtable = Google::Cloud::Bigtable.new project_id: @project_id
  end

  it "create table, run table admin operations and delete table" do
    table_id = "test-table-#{SecureRandom.hex(8)}"

    output = capture do
      run_table_operations @project_id, @instance_id, table_id
    end

    expect(output).to include "Table created #{table_id}"
    expect(output).to include "Created column family with max age GC rule: cf1"
    expect(output).to include "Created column family with max versions GC rule: cf2"
    expect(output).to include "Created column family with union GC rule: cf3"
    expect(output).to include "Created column family with intersect GC rule: cf4"
    expect(output).to include "Created column family with a nested GC rule: cf5"
    expect(output).to include "Updated max version GC rule of column_family: cf1"
    expect(output).to include "Deleted column family: cf2"

    output = capture do
      delete_table @project_id, @instance_id, table_id
    end

    expect(output).to include "Table deleted: #{table_id}"
  end
end
