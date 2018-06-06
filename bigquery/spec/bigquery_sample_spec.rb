# Copyright 2016 Google, Inc
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require_relative "../datasets"
require_relative "../tables"
require "rspec"
require "rspec/retry"
require "google/cloud/bigquery"
require "google/cloud/storage"
require "csv"

RSpec.configure do |config|
  # show retry status in spec process
  config.verbose_retry = true
  # show exception that triggers a retry if verbose_retry is set to true
  config.display_try_failure_messages = true

  # set retry count and retry sleep interval to 10 seconds
  config.default_retry_count = 5
  config.default_sleep_interval = 10
end

describe "Google Cloud BigQuery samples" do

  before do
    @bigquery   = Google::Cloud::Bigquery.new
    @project_id = @bigquery.project
    @storage    = Google::Cloud::Storage.new
    @bucket     = @storage.bucket ENV["GOOGLE_CLOUD_STORAGE_BUCKET"]
    @tempfiles  = []

    current_time  = Time.now.to_i
    @file_name    = "bigquery-test_#{current_time}"
    @dataset_name = "test_dataset_#{current_time}"
    @table_name   = "test_table_#{current_time}"

    @dataset = @bigquery.create_dataset @dataset_name
    @table   = @dataset.create_table    @table_name do |schema|
      schema.string  "name"
      schema.integer "value"
    end
  end

  after do
    # Cleanup any tempfiles that were used by the example spec
    @tempfiles.each &:flush
    @tempfiles.each &:close

    # delete csv file and dataset
    delete_test_dataset!

    if @bucket.file "#{@file_name}.csv"
      @bucket.file("#{@file_name}.csv").delete
    end
  end

  def delete_test_dataset!
    dataset = @bigquery.dataset @dataset_name
    dataset.tables.each &:delete if dataset
    dataset.delete               if dataset
  end

  # Helper to create Tempfile that will be cleaned up after test run
  def create_tempfile extension = "txt"
    file = Tempfile.new [ @file_name, ".#{extension}" ]
    @tempfiles << file
    file
  end

  # Helper to create and return CSV file.
  # The block will be passed a CSV object.
  #
  # @example
  #   file = create_csv do |csv|
  #     csv << [ "Alice", 123 ]
  #     csv << [ "Bob",   456 ]
  #   end
  #
  #   puts file.path
  def create_csv &block
    file = create_tempfile "csv"
    CSV.open file.path, "w", &block
    file
  end

  # Capture and return STDOUT output by block
  def capture &block
    real_stdout = $stdout
    $stdout = StringIO.new
    block.call
    @captured_output = $stdout.string
  ensure
    $stdout = real_stdout
  end
  attr_reader :captured_output

  # Simple wait method. Test for condition 5 times, delaying 1 second each time
  def wait_until times: 5, delay: 1, &condition
    times.times do
      return if condition.call
      sleep delay
    end
    raise "Condition not met.  Waited #{times} times with #{delay} sec delay"
  end

  example "create BigQuery client" do
    client = create_bigquery_client project_id: @project_id

    expect(client).to be_a Google::Cloud::Bigquery::Project
  end

  describe "Managing Datasets" do
    example "create dataset" do
      delete_test_dataset!
      expect(@bigquery.dataset @dataset_name).to be nil

      expect {
        create_dataset project_id: @project_id,
                       dataset_id: @dataset_name
      }.to output(
        "Created dataset: #{@dataset_name}\n"
      ).to_stdout

      expect(@bigquery.dataset @dataset_name).not_to be nil
    end

    example "list datasets" do
      expect {
        list_datasets project_id: @project_id
      }.to output(
        /#{@dataset_name}/
      ).to_stdout
    end

    example "delete dataset" do
      @dataset.tables.each &:delete
      expect(@bigquery.dataset @dataset_name).not_to be nil

      expect {
        delete_dataset project_id: @project_id,
                       dataset_id: @dataset_name
      }.to output(
        "Deleted dataset: #{@dataset_name}\n"
      ).to_stdout

      expect(@bigquery.dataset @dataset_name).to be nil
    end
  end

  describe "Managing Tables" do

    example "create table with schema" do
      new_table_id = "create_table_with_schema"
      expect(@dataset.table new_table_id).to be nil

      expect {
        create_table_with_schema project_id: @project_id,
                                 dataset_id: @dataset_name,
                                 table_id:   new_table_id
      }.to output(
        "Created table: #{new_table_id}\n"
      ).to_stdout

      table = @dataset.table new_table_id
      expect(table).not_to be nil

      expect(table.schema.fields[0].name).to eq "full_name"
      expect(table.schema.fields[0].type).to eq "STRING"
      expect(table.schema.fields[0].mode).to eq "REQUIRED"

      expect(table.schema.fields[1].name).to eq "age"
      expect(table.schema.fields[1].type).to eq "INTEGER"
      expect(table.schema.fields[1].mode).to eq "REQUIRED"
    end

    example "create table without schema" do
      new_table_id = "create_table_without_schema"
      expect(@dataset.table new_table_id).to be nil

      expect {
        create_table_with_schema project_id: @project_id,
                                 dataset_id: @dataset_name,
                                 table_id:   new_table_id
      }.to output(
        "Created table: #{new_table_id}\n"
      ).to_stdout

      expect(@dataset.table new_table_id).not_to be nil
    end

    example "list tables" do
      expect {
        list_tables project_id: @project_id,
                    dataset_id: @dataset_name
      }.to output(
        /#{@table_name}/
      ).to_stdout
    end

    example "delete table" do
      expect(@dataset.table @table_name).not_to be nil

      expect {
        delete_table project_id: @project_id,
                     dataset_id: @dataset_name,
                     table_id:   @table_name
      }.to output(
        "Deleted table: #{@table_name}\n"
      ).to_stdout

      expect(@dataset.table @table_name).to be nil
    end

    example "list table data" do
      csv_file = create_csv do |csv|
        csv << [ "Alice", 5 ]
        csv << [ "Bob",   10 ]
      end

      @table.load csv_file.path

      capture {
        list_table_data project_id: @project_id,
                        dataset_id: @dataset_name,
                        table_id:   @table_name
      }

      expect(captured_output).to include "name = Bob\nvalue = 10"
      expect(captured_output).to include "name = Alice\nvalue = 5"
    end

    example "list table data with pagination"
  end

  describe "Importing data" do

    example "import data from file" do
      csv_file = create_csv do |csv|
        csv << [ "Alice", 5 ]
        csv << [ "Bob",   10 ]
      end

      expect(@table.data).to be_empty

      capture do
        import_table_data_from_file project_id:      @project_id,
                                    dataset_id:      @dataset_name,
                                    table_id:        @table_name,
                                    local_file_path: csv_file.path
      end

      expect(captured_output).to include(
        "Importing data from file: #{csv_file.path}\n"
      )
      expect(captured_output).to include "Waiting for load job to complete: job"
      expect(captured_output).to include "Data imported"

      loaded_data = @table.data

      expect(loaded_data).not_to be_empty
      expect(loaded_data.count).to eq 2
      expect(loaded_data).to include({ name: "Alice", value: 5  })
      expect(loaded_data).to include({ name: "Bob",   value: 10 })
    end

    example "import data from Cloud Storage" do
      csv_file = create_csv do |csv|
        csv << [ "Alice", 5 ]
        csv << [ "Bob",   10 ]
      end

      file = @bucket.create_file csv_file.path, "#{@file_name}.csv"

      expect(@table.data).to be_empty

      capture do
        import_table_data_from_cloud_storage(
          project_id:   @project_id,
          dataset_id:   @dataset.dataset_id,
          table_id:     @table.table_id,
          storage_path: "gs://#{@bucket.name}/#{@file_name}.csv"
        )
      end

      expect(captured_output).to include(
        "Importing data from Cloud Storage file: " +
        "gs://#{@bucket.name}/#{@file_name}.csv"
      )
      expect(captured_output).to include "Waiting for load job to complete: job"
      expect(captured_output).to include "Data imported"

      loaded_data = @table.data

      expect(loaded_data).not_to be_empty
      expect(loaded_data.count).to eq 2
      expect(loaded_data).to include({ name: "Alice", value: 5  })
      expect(loaded_data).to include({ name: "Bob",   value: 10 })
    end

    example "import json data from GCS as new table" do
      expect(@dataset.table "us_states").to be nil

      capture do
        import_table_from_gcs_json(
          project_id: @project_id,
          dataset_id: @dataset.dataset_id
        )
      end

      expect(captured_output).to include(
        "Importing data from Cloud Storage file: " +
        "gs://cloud-samples-data/bigquery/us-states/us-states.json"
      )
      expect(captured_output).to include "Waiting for load job to complete: job"
      expect(captured_output).to include "Data imported"

      loaded_data = @dataset.table("us_states").data

      expect(loaded_data).not_to be_empty
      expect(loaded_data.count).to eq 50
    end

    example "import json data from GCS as new table with autodetect" do
      expect(@dataset.table "us_states").to be nil

      capture do
        import_table_from_gcs_json_autodetect(
          project_id: @project_id,
          dataset_id: @dataset.dataset_id
        )
      end

      expect(captured_output).to include(
        "Importing data from Cloud Storage file: " +
        "gs://cloud-samples-data/bigquery/us-states/us-states.json"
      )
      expect(captured_output).to include "Waiting for load job to complete: job"
      expect(captured_output).to include "Data imported"

      loaded_data = @dataset.table("us_states").data

      expect(loaded_data).not_to be_empty
      expect(loaded_data.count).to eq 50
    end

    example "append json data from GCS" do
      expect(@table.data).to be_empty

      @table.schema do |schema|
        schema.string "name"
        schema.string "post_abbr"
      end

      @table.insert [{"name": "New Statington", "post_abbr": "NS"}]
      expect(@table.data.count).to eq 1

      capture do
        append_json_data_from_gcs(
          project_id: @project_id,
          dataset_id: @dataset.dataset_id,
          table_id:   @table.table_id
        )
      end

      expect(captured_output).to include(
        "Importing data from Cloud Storage file: " +
        "gs://cloud-samples-data/bigquery/us-states/us-states.json"
      )
      expect(captured_output).to include "Waiting for load job to complete: job"
      expect(captured_output).to include "Data imported"

      loaded_data = @table.data

      expect(loaded_data).not_to be_empty
      expect(loaded_data.count).to eq 51
    end

    example "write truncate json data from GCS" do
      expect(@table.data).to be_empty

      @table.schema do |schema|
        schema.string "name"
        schema.string "post_abbr"
      end

      @table.insert [{"name": "New Statington", "post_abbr": "NS"}]
      expect(@table.data.count).to eq 1

      capture do
        write_truncate_json_data_from_gcs(
          project_id: @project_id,
          dataset_id: @dataset.dataset_id,
          table_id:   @table.table_id
        )
      end

      expect(captured_output).to include(
        "Importing data from Cloud Storage file: " +
        "gs://cloud-samples-data/bigquery/us-states/us-states.json"
      )
      expect(captured_output).to include "Waiting for load job to complete: job"
      expect(captured_output).to include "Data imported"

      loaded_data = @table.data

      expect(loaded_data).not_to be_empty
      expect(loaded_data.count).to eq 50
    end

    example "stream data import" do
      expect(@table.data).to be_empty

      row_data_to_insert = [
        { name: "Alice", value: 5  },
        { name: "Bob",   value: 10 }
      ]

      expect {
        import_table_data project_id: @project_id,
                          dataset_id: @dataset.dataset_id,
                          table_id:   @table.table_id,
                          row_data:   row_data_to_insert
      }.to output(
        "Inserted rows successfully\n"
      ).to_stdout

      loaded_data = nil

      wait_until do
        loaded_data = @table.data
        loaded_data.any?
      end

      expect(loaded_data).not_to be_empty
      expect(loaded_data.count).to eq 2
      expect(loaded_data).to include({ name: "Alice", value: 5  })
      expect(loaded_data).to include({ name: "Bob",   value: 10 })
    end
  end

  describe "Exporting data" do
    example "export data to Cloud Storage" do
      csv_file = create_csv do |csv|
        csv << [ "Alice", 5 ]
        csv << [ "Bob",   10 ]
      end

      @table.load csv_file.path

      expect(@bucket.file "#{@file_name}.csv").to be nil

      capture do
        export_table_data_to_cloud_storage(
          project_id:   @project_id,
          dataset_id:   @dataset.dataset_id,
          table_id:     @table.table_id,
          storage_path: "gs://#{@bucket.name}/#{@file_name}.csv"
        )
      end

      expect(captured_output).to include(
        "Exporting data to Cloud Storage file: " +
        "gs://#{@bucket.name}/#{@file_name}.csv"
      )
      expect(captured_output).to include "Waiting for extract job to complete: job"
      expect(captured_output).to include "Data exported"

      expect(@bucket.file "#{@file_name}.csv").not_to be nil

      local_file = create_tempfile "csv"
      @bucket.file("#{@file_name}.csv").download local_file.path

      csv = CSV.read local_file.path

      expect(csv).to include %w[ name value ]
      expect(csv).to include %w[ Alice 5    ]
      expect(csv).to include %w[ Bob   10   ]
    end
  end

  describe "Querying" do
    example "run query" do
      capture do
        run_query(
          project_id:   @project_id,
          query_string: "SELECT APPROX_TOP_COUNT(word, 50) as word, COUNT(*) as count " +
                        "FROM `publicdata.samples.shakespeare`"
        )
      end

      expect(captured_output).to include '{:value=>"you", :count=>42}'
    end

    example "run query as job" do
      capture do
        run_query_as_job(
          project_id:   @project_id,
          query_string: "SELECT APPROX_TOP_COUNT(word, 50) as word, COUNT(*) as count " +
                        "FROM `publicdata.samples.shakespeare`"
        )
      end

      expect(captured_output).to include "Running query"
      expect(captured_output).to include "Waiting for query to complete"
      expect(captured_output).to include "Query results:"
      expect(captured_output).to include '{:value=>"you", :count=>42}'
    end
  end
end
