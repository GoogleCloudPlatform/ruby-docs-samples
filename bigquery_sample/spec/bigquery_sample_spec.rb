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

require_relative "../bigquery_samples"
require "rspec"
require "google/cloud"
require "csv"

RSpec.describe "Google Cloud BigQuery samples" do

  before do
    @project_id = ENV["GOOGLE_PROJECT_ID"]
    @gcloud     = Google::Cloud.new @project_id
    @bigquery   = @gcloud.bigquery

    # Examples assume that test_dataset does not exist
    test_dataset = @bigquery.dataset "test_dataset"

    if test_dataset
      test_dataset.tables.each &:delete
      test_dataset.delete
    end
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

  describe "Managing projects" do
    example "list projects"
  end

  describe "Managing Datasets" do
    example "create dataset" do
      expect(@bigquery.dataset "test_dataset").to be nil

      expect {
        create_dataset project_id: @project_id, dataset_id: "test_dataset"
      }.to output(
        "Created dataset: test_dataset\n"
      ).to_stdout

      expect(@bigquery.dataset "test_dataset").not_to be nil
    end

    example "list datasets" do
      @bigquery.create_dataset "test_dataset"

      expect {
        list_datasets project_id: @project_id
      }.to output(
        /test_dataset/
      ).to_stdout
    end

    example "delete dataset" do
      @bigquery.create_dataset "test_dataset"
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
      dataset = @bigquery.create_dataset "test_dataset"
      expect(dataset.table "test_table").to be nil

      expect {
        create_table project_id: @project_id,
                     dataset_id: "test_dataset",
                     table_id:   "test_table"
      }.to output(
        "Created table: test_table\n"
      ).to_stdout

      expect(dataset.table "test_table").not_to be nil
    end

    example "list tables" do
      dataset = @bigquery.create_dataset "test_dataset"
      dataset.create_table "test_table"

      expect {
        list_tables project_id: @project_id, dataset_id: "test_dataset"
      }.to output(
        /test_table/
      ).to_stdout
    end

    example "delete table" do
      dataset = @bigquery.create_dataset "test_dataset"
      dataset.create_table "test_table"
      expect(dataset.table "test_table").not_to be nil

      expect {
        delete_table project_id: @project_id,
                     dataset_id: "test_dataset",
                     table_id:   "test_table"
      }.to output(
        "Deleted table: test_table\n"
      ).to_stdout

      expect(dataset.table "test_table").to be nil
    end

    example "list table data" do
      begin
        dataset = @bigquery.create_dataset "test_dataset"

        table = dataset.create_table "test_table" do |schema|
          schema.string "name"
          schema.string "value"
        end

        csv_file = Tempfile.new "bigquery-test-csv"

        CSV.open csv_file.path, "w" do |csv|
          csv << [ "Alice", 5 ]
          csv << [ "Bob",   10 ]
        end

        load_job = table.load csv_file.path, format: "csv"

        load_job.wait_until_done!

        expect {
          list_table_data project_id: @project_id,
                          dataset_id: "test_dataset",
                          table_id:   "test_table"
        }.to output(
          "name = Alive\nvalue=5\nname=Bob\nvalue=10\n"
        ).to_stdout
      ensure
        csv_file.flush
        csv_file.close
      end
    end

    # .data.all
    example "list table data with pagination"
  end

  describe "Importing data" do
    example "import data from Cloud Storage"
    example "import data from file"
    example "stream data import"
  end

  describe "Exporting data" do
    example "export data to Cloud Storage"
  end

  describe "Querying" do
    example "run query"
    example "run query as job"
  end
end
