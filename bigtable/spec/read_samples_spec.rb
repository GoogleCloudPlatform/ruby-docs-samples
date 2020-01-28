require_relative "spec_helper"
require "securerandom"
require "google/cloud/bigtable"
require "google/cloud/bigtable/admin"
require_relative "../read_samples"

describe "Google Cloud Bigtable Read Samples", focus: true do
  before(:all) do
    @table_id = "mobile-time-series-#{SecureRandom.hex 8}"
    bigtable = Google::Cloud::Bigtable.new project_id: @project_id

    puts "Creating table."
    column_families = Google::Cloud::Bigtable::ColumnFamilyMap.new
    column_families.add "stats_summary", gc_rule: nil

    @table = bigtable.create_table @instance_id, @table_id, column_families: column_families

    @timestamp = (Time.now.to_f * 1_000_000).round(-3)

    entries = []
    entries <<
        @table.new_mutation_entry("phone#4c410523#20190501").set_cell("stats_summary", "connected_cell", 1, timestamp: @timestamp)
            .set_cell("stats_summary", "connected_wifi", 1, timestamp: @timestamp)
            .set_cell("stats_summary", "os_build", "PQ2A.190405.003", timestamp: @timestamp) <<
        @table.new_mutation_entry("phone#4c410523#20190502").set_cell("stats_summary", "connected_cell", 1, timestamp: @timestamp)
            .set_cell("stats_summary", "connected_wifi", 1, timestamp: @timestamp)
            .set_cell("stats_summary", "os_build", "PQ2A.190405.004", timestamp: @timestamp) <<
        @table.new_mutation_entry("phone#4c410523#20190505").set_cell("stats_summary", "connected_cell", 0, timestamp: @timestamp)
            .set_cell("stats_summary", "connected_wifi", 1, timestamp: @timestamp)
            .set_cell("stats_summary", "os_build", "PQ2A.190406.000", timestamp: @timestamp) <<
        @table.new_mutation_entry("phone#5c10102#20190501").set_cell("stats_summary", "connected_cell", 1, timestamp: @timestamp)
            .set_cell("stats_summary", "connected_wifi", 1, timestamp: @timestamp)
            .set_cell("stats_summary", "os_build", "PQ2A.190401.002", timestamp: @timestamp) <<
        @table.new_mutation_entry("phone#5c10102#20190502").set_cell("stats_summary", "connected_cell", 1, timestamp: @timestamp)
            .set_cell("stats_summary", "connected_wifi", 0, timestamp: @timestamp)
            .set_cell("stats_summary", "os_build", "PQ2A.190406.000", timestamp: @timestamp)

    @table.mutate_rows entries
  end

  it "reads_row" do
    output = capture do
      reads_row @project_id, @instance_id, @table_id
    end
    expect(output).to match "Reading data for phone#4c410523#20190501:
Column Family stats_summary
	connected_cell: 1 @#{@timestamp}
	connected_wifi: 1 @#{@timestamp}
	os_build: PQ2A.190405.003 @#{@timestamp}"
  end

  it "reads_row_partial" do
    output = capture do
      reads_row_partial @project_id, @instance_id, @table_id
    end
    expect(output).to match "
Reading data for phone#4c410523#20190501:
Column Family stats_summary
\tconnected_cell: 1 @#{@timestamp}
\tconnected_wifi: 1 @#{@timestamp}
\tos_build: PQ2A.190405.003 @#{@timestamp}


"
  end

  it "reads_rows" do
    output = capture do
      reads_rows @project_id, @instance_id, @table_id
    end
    expect(output).to match "
Reading data for phone#4c410523#20190501:
Column Family stats_summary
\tos_build: PQ2A.190405.003 @#{@timestamp}


"
  end

  it "reads_row_range" do
    output = capture do
      reads_row_range @project_id, @instance_id, @table_id
    end
    expect(output).to match "
Reading data for phone#4c410523#20190501:
Column Family stats_summary
\tconnected_cell: 1 @#{@timestamp}
\tconnected_wifi: 1 @#{@timestamp}
\tos_build: PQ2A.190405.003 @#{@timestamp}

Reading data for phone#4c410523#20190502:
Column Family stats_summary
\tconnected_cell: 1 @#{@timestamp}
\tconnected_wifi: 1 @#{@timestamp}
\tos_build: PQ2A.190405.004 @#{@timestamp}


"
  end

  it "reads_row_ranges" do
    output = capture do
      reads_row_ranges @project_id, @instance_id, @table_id
    end
    expect(output).to match "
Reading data for phone#4c410523#20190501:
Column Family stats_summary
\tconnected_cell: 1 @#{@timestamp}
\tconnected_wifi: 1 @#{@timestamp}
\tos_build: PQ2A.190405.003 @#{@timestamp}

Reading data for phone#4c410523#20190502:
Column Family stats_summary
\tconnected_cell: 1 @#{@timestamp}
\tconnected_wifi: 1 @#{@timestamp}
\tos_build: PQ2A.190405.004 @#{@timestamp}

Reading data for phone#4c410523#20190505:
Column Family stats_summary
\tconnected_cell: 0 @#{@timestamp}
\tconnected_wifi: 1 @#{@timestamp}
\tos_build: PQ2A.190406.000 @#{@timestamp}


"
  end

  it "reads_prefix" do
    output = capture do
      reads_prefix @project_id, @instance_id, @table_id
    end
    expect(output).to match "
Reading data for phone#4c410523#20190501:
Column Family stats_summary
\tconnected_cell: 1 @#{@timestamp}
\tconnected_wifi: 1 @#{@timestamp}
\tos_build: PQ2A.190405.003 @#{@timestamp}

Reading data for phone#4c410523#20190502:
Column Family stats_summary
\tconnected_cell: 1 @#{@timestamp}
\tconnected_wifi: 1 @#{@timestamp}
\tos_build: PQ2A.190405.004 @#{@timestamp}

Reading data for phone#4c410523#20190505:
Column Family stats_summary
\tconnected_cell: 0 @#{@timestamp}
\tconnected_wifi: 1 @#{@timestamp}
\tos_build: PQ2A.190406.000 @#{@timestamp}

Reading data for phone#5c10102#20190501:
Column Family stats_summary
\tconnected_cell: 1 @#{@timestamp}
\tconnected_wifi: 1 @#{@timestamp}
\tos_build: PQ2A.190401.002 @#{@timestamp}

Reading data for phone#5c10102#20190502:
Column Family stats_summary
\tconnected_cell: 1 @#{@timestamp}
\tconnected_wifi: 0 @#{@timestamp}
\tos_build: PQ2A.190406.000 @#{@timestamp}


"
  end

  it "reads_filter" do
    output = capture do
      reads_filter @project_id, @instance_id, @table_id
    end
    expect(output).to match "
Reading data for phone#4c410523#20190501:
Column Family stats_summary
\tconnected_cell: 1 @#{@timestamp}
\tconnected_wifi: 1 @#{@timestamp}
\tos_build: PQ2A.190405.003 @#{@timestamp}

Reading data for phone#4c410523#20190502:
Column Family stats_summary
\tconnected_cell: 1 @#{@timestamp}
\tconnected_wifi: 1 @#{@timestamp}
\tos_build: PQ2A.190405.004 @#{@timestamp}

Reading data for phone#4c410523#20190505:
Column Family stats_summary
\tconnected_cell: 0 @#{@timestamp}
\tconnected_wifi: 1 @#{@timestamp}
\tos_build: PQ2A.190406.000 @#{@timestamp}

Reading data for phone#5c10102#20190501:
Column Family stats_summary
\tconnected_cell: 1 @#{@timestamp}
\tconnected_wifi: 1 @#{@timestamp}
\tos_build: PQ2A.190401.002 @#{@timestamp}

Reading data for phone#5c10102#20190502:
Column Family stats_summary
\tconnected_cell: 1 @#{@timestamp}
\tconnected_wifi: 0 @#{@timestamp}
\tos_build: PQ2A.190406.000 @#{@timestamp}


"
  end


  after(:all) do
    puts "Deleting table."
    @table.delete
  end

end
