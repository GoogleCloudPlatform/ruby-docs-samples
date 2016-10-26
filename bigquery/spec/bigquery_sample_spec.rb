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
require "google/cloud"
require "csv"

describe "Google Cloud BigQuery samples" do

  before do
    @project_id = ENV["GOOGLE_CLOUD_PROJECT"]
    @gcloud     = Google::Cloud.new @project_id
    @bigquery   = @gcloud.bigquery
    @storage    = @gcloud.storage
    @bucket     = @storage.bucket ENV["GOOGLE_CLOUD_STORAGE_BUCKET"]
    @tempfiles  = []

    # Examples assume that newly created test_dataset and test_table exist
    delete_test_dataset!

    @dataset = @bigquery.create_dataset "test_dataset"
    @table   = @dataset.create_table    "test_table" do |schema|
      schema.string  "name"
      schema.integer "value"
    end

    if @bucket.file "bigquery-test.csv"
      @bucket.file("bigquery-test.csv").delete
    end
  end

  after do
    # Cleanup any tempfiles that were used by the example spec
    @tempfiles.each &:flush
    @tempfiles.each &:close
  end

  def delete_test_dataset!
    dataset = @bigquery.dataset "test_dataset"
    dataset.tables.each &:delete if dataset
    dataset.delete               if dataset
  end

  # Helper to create Tempfile that will be cleaned up after test run
  def create_tempfile extension = "txt"
    file = Tempfile.new [ "bigquery-test", ".#{extension}" ]
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
      expect(@bigquery.dataset "test_dataset").to be nil

      expect {
        create_dataset project_id: @project_id, dataset_id: "test_dataset"
      }.to output(
        "Created dataset: test_dataset\n"
      ).to_stdout

      expect(@bigquery.dataset "test_dataset").not_to be nil
    end

    example "list datasets" do
      expect {
        list_datasets project_id: @project_id
      }.to output(
        /test_dataset/
      ).to_stdout
    end

    example "delete dataset" do
      @dataset.tables.each &:delete
      expect(@bigquery.dataset "test_dataset").not_to be nil

      expect {
        delete_dataset project_id: @project_id, dataset_id: "test_dataset"
      }.to output(
        "Deleted dataset: test_dataset\n"
      ).to_stdout

      expect(@bigquery.dataset "test_dataset").to be nil
    end
  end

  describe "Managing Tables" do

    example "create table" do
      @table.delete
      expect(@dataset.table "test_table").to be nil

      expect {
        create_table project_id: @project_id,
                     dataset_id: "test_dataset",
                     table_id:   "test_table"
      }.to output(
        "Created table: test_table\n"
      ).to_stdout

      expect(@dataset.table "test_table").not_to be nil
    end

    example "list tables" do
      expect {
        list_tables project_id: @project_id, dataset_id: "test_dataset"
      }.to output(
        /test_table/
      ).to_stdout
    end

    example "delete table" do
      expect(@dataset.table "test_table").not_to be nil

      expect {
        delete_table project_id: @project_id,
                     dataset_id: "test_dataset",
                     table_id:   "test_table"
      }.to output(
        "Deleted table: test_table\n"
      ).to_stdout

      expect(@dataset.table "test_table").to be nil
    end

    example "list table data" do
      csv_file = create_csv do |csv|
        csv << [ "Alice", 5 ]
        csv << [ "Bob",   10 ]
      end

      @table.load(csv_file.path).wait_until_done!

      expect {
        list_table_data project_id: @project_id,
                        dataset_id: "test_dataset",
                        table_id:   "test_table"
      }.to output(
        "name = Alice\nvalue = 5\nname = Bob\nvalue = 10\n"
      ).to_stdout
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
        import_table_data_from_file project_id:     @project_id,
                                    dataset_id:     "test_dataset",
                                    table_id:       "test_table",
                                    local_file_path: csv_file.path
      end

      expect(captured_output).to include(
        "Importing data from file: #{csv_file.path}\n"
      )
      expect(captured_output).to match(
        /Waiting for load job to complete: job/
      )
      expect(captured_output).to include "Data imported"

      loaded_data = @table.data

      expect(loaded_data).not_to be_empty
      expect(loaded_data.count).to eq 2
      expect(loaded_data).to include({ "name" => "Alice", "value" => 5  })
      expect(loaded_data).to include({ "name" => "Bob",   "value" => 10 })
    end

    example "import data from Cloud Storage" do
      csv_file = create_csv do |csv|
        csv << [ "Alice", 5 ]
        csv << [ "Bob",   10 ]
      end

      file = @bucket.create_file csv_file.path, "bigquery-test.csv"

      expect(@table.data).to be_empty

      capture do
        import_table_data_from_cloud_storage(
          project_id:   @project_id,
          dataset_id:   @dataset.dataset_id,
          table_id:     @table.table_id,
          storage_path: "gs://#{@bucket.name}/bigquery-test.csv"
        )
      end

      expect(captured_output).to include(
        "Importing data from Cloud Storage file: " +
        "gs://#{@bucket.name}/bigquery-test.csv"
      )
      expect(captured_output).to match(
        /Waiting for load job to complete: job/
      )
      expect(captured_output).to include "Data imported"

      loaded_data = @table.data

      expect(loaded_data).not_to be_empty
      expect(loaded_data.count).to eq 2
      expect(loaded_data).to include({ "name" => "Alice", "value" => 5  })
      expect(loaded_data).to include({ "name" => "Bob",   "value" => 10 })
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
      expect(loaded_data).to include({ "name" => "Alice", "value" => 5  })
      expect(loaded_data).to include({ "name" => "Bob",   "value" => 10 })
    end
  end

  describe "Exporting data" do
    example "export data to Cloud Storage" do
      csv_file = create_csv do |csv|
        csv << [ "Alice", 5 ]
        csv << [ "Bob",   10 ]
      end

      @table.load(csv_file.path).wait_until_done!

      expect(@bucket.file "bigquery-test.csv").to be nil

      capture do
        export_table_data_to_cloud_storage(
          project_id:   @project_id,
          dataset_id:   @dataset.dataset_id,
          table_id:     @table.table_id,
          storage_path: "gs://#{@bucket.name}/bigquery-test.csv"
        )
      end

      expect(captured_output).to include(
        "Exporting data to Cloud Storage file: " +
        "gs://#{@bucket.name}/bigquery-test.csv"
      )
      expect(captured_output).to match(
        /Waiting for extract job to complete: job/
      )
      expect(captured_output).to include "Data exported"

      expect(@bucket.file "bigquery-test.csv").not_to be nil

      local_file = create_tempfile "csv"
      @bucket.file("bigquery-test.csv").download local_file.path

      csv = CSV.read local_file.path

      expect(csv[0]).to eq %w[ name value ]
      expect(csv[1]).to eq %w[ Alice 5    ]
      expect(csv[2]).to eq %w[ Bob   10   ]
    end
  end

  describe "Querying" do
    example "run query" do
      capture do
        run_query(
          project_id:   @project_id,
          query_string: "SELECT TOP(word, 50) as word, COUNT(*) as count " +
                        "FROM publicdata:samples.shakespeare"
        )
      end

      expect(captured_output).to include '{"word"=>"you", "count"=>42}'
    end

    example "run query as job" do
      capture do
        run_query_as_job(
          project_id:   @project_id,
          query_string: "SELECT TOP(word, 50) as word, COUNT(*) as count " +
                        "FROM publicdata:samples.shakespeare"
        )
      end

      expect(captured_output).to include "Running query"
      expect(captured_output).to include "Waiting for query to complete"
      expect(captured_output).to include "Query results:"
      expect(captured_output).to include '{"word"=>"you", "count"=>42}'
    end
  end
end
