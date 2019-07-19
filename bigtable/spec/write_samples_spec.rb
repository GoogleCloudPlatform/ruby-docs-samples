require_relative "spec_helper"
require "securerandom"
require "google/cloud/bigtable"
require_relative "../write_samples"

describe "Google Cloud Bigtable write Samples", focus: true do
  before(:all) do
    @table_id = "mobile-time-series-#{SecureRandom.hex 8}"

    bigtable = Google::Cloud::Bigtable.new project_id: @project_id

    puts "Creating table."
    @table = bigtable.create_table @instance_id, @table_id
    @table.column_family("stats_summary", Google::Cloud::Bigtable::GcRule.max_versions(5)).create()
  end

  it "writes one row" do
    output = capture do
      write_simple @project_id, @instance_id, @table_id
    end

    expect(output).to include "Successfully wrote row"
  end

  it "writes multiple rows" do
    output = capture do
      write_batch @project_id, @instance_id, @table_id
    end

    expect(output).to include "Successfully wrote 2 rows"
  end

  it "increments a row" do
    output = capture do
      write_increment @project_id, @instance_id, @table_id
    end

    expect(output).to include "Successfully updated row"
  end

  it "conditionally writes a row" do
    output = capture do
      write_conditional @project_id, @instance_id, @table_id
    end

    expect(output).to include "Successfully updated row's os_name: true"
  end

  after(:all) do
    puts "Deleting table."
    @table.delete
  end

end
