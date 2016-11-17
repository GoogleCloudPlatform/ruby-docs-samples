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

def create_table project_id:, dataset_id:, table_id:
  # [START create_table]
  # project_id = "Your Google Cloud project ID"
  # dataset_id = "ID of the dataset to create table in"
  # table_id   = "ID of the table to create"

  require "google/cloud/bigquery"

  bigquery = Google::Cloud::Bigquery.new project: project_id
  dataset  = bigquery.dataset dataset_id

  dataset.create_table table_id

  puts "Created table: #{table_id}"
  # [END create_table]
end

def list_tables project_id:, dataset_id:
  # [START list_tables]
  # project_id = "Your Google Cloud project ID"
  # dataset_id = "ID of the dataset to create table in"

  require "google/cloud/bigquery"

  bigquery = Google::Cloud::Bigquery.new project: project_id
  dataset  = bigquery.dataset dataset_id

  dataset.tables.each do |table|
    puts table.table_id
  end
  # [END list_tables]
end

def delete_table project_id:, dataset_id:, table_id:
  # [START delete_table]
  # project_id = "Your Google Cloud project ID"
  # dataset_id = "ID of the dataset delete table from"
  # table_id   = "ID of the table to delete"

  require "google/cloud/bigquery"

  bigquery = Google::Cloud::Bigquery.new project: project_id
  dataset  = bigquery.dataset dataset_id
  table    = dataset.table table_id

  table.delete

  puts "Deleted table: #{table_id}"
  # [END delete_table]
end

def list_table_data project_id:, dataset_id:, table_id:
  # [START list_table_data]
  # project_id = "Your Google Cloud project ID"
  # dataset_id = "ID of the dataset containing table"
  # table_id   = "ID of the table to display data for"

  require "google/cloud/bigquery"

  bigquery = Google::Cloud::Bigquery.new project: project_id
  dataset  = bigquery.dataset dataset_id
  table    = dataset.table table_id

  table.data.each do |row|
    row.each      do |column_name, value|
      puts "#{column_name} = #{value}"
    end
  end
  # [END list_table_data]
end

def import_table_data project_id:, dataset_id:, table_id:, row_data:
  # [START import_table_data]
  # project_id = "Your Google Cloud project ID"
  # dataset_id = "ID of the dataset containing table"
  # table_id   = "ID of the table to import data into"
  # row_data   = [{ column1: value, column2: value }, ...]

  require "google/cloud/bigquery"

  bigquery = Google::Cloud::Bigquery.new project: project_id
  dataset  = bigquery.dataset dataset_id
  table    = dataset.table table_id

  response = table.insert row_data

  if response.success?
    puts "Inserted rows successfully"
  else
    puts "Failed to insert #{response.error_rows.count} rows"
  end
  # [END import_table_data]
end

def import_table_data_from_file project_id:, dataset_id:, table_id:,
                                local_file_path:
  # [START import_table_data_from_file]
  # project_id      = "Your Google Cloud project ID"
  # dataset_id      = "ID of the dataset containing table"
  # table_id        = "ID of the table to import file data into"
  # local_file_path = "Path to local file to import into BigQuery table"

  require "google/cloud/bigquery"

  bigquery = Google::Cloud::Bigquery.new project: project_id
  dataset  = bigquery.dataset dataset_id
  table    = dataset.table table_id

  puts "Importing data from file: #{local_file_path}"
  load_job = table.load local_file_path

  puts "Waiting for load job to complete: #{load_job.job_id}"
  load_job.wait_until_done!

  puts "Data imported"
  # [END import_table_data_from_file]
end

def import_table_data_from_cloud_storage project_id:, dataset_id:, table_id:,
                                         storage_path:
  # [START import_table_data_from_cloud_storage]
  # project_id   = "Your Google Cloud project ID"
  # dataset_id   = "ID of the dataset containing table"
  # table_id     = "ID of the table to import data into"
  # storage_path = "Storage path to file to import, eg. gs://bucket/file.csv"

  require "google/cloud/bigquery"

  bigquery = Google::Cloud::Bigquery.new project: project_id
  dataset  = bigquery.dataset dataset_id
  table    = dataset.table table_id

  puts "Importing data from Cloud Storage file: #{storage_path}"
  load_job = table.load storage_path

  puts "Waiting for load job to complete: #{load_job.job_id}"
  load_job.wait_until_done!

  puts "Data imported"
  # [END import_table_data_from_cloud_storage]
end

def export_table_data_to_cloud_storage project_id:, dataset_id:, table_id:,
                                       storage_path:
  # [START export_table_data_to_cloud_storage]
  # project_id   = "Your Google Cloud project ID"
  # dataset_id   = "ID of the dataset containing table"
  # table_id     = "ID of the table to export file data from"
  # storage_path = "Storage path to export to, eg. gs://bucket/file.csv"

  require "google/cloud/bigquery"

  bigquery = Google::Cloud::Bigquery.new project: project_id
  dataset  = bigquery.dataset dataset_id
  table    = dataset.table table_id

  puts "Exporting data to Cloud Storage file: #{storage_path}"
  extract_job = table.extract storage_path

  puts "Waiting for extract job to complete: #{extract_job.job_id}"
  extract_job.wait_until_done!

  puts "Data exported"
  # [END export_table_data_to_cloud_storage]
end

def run_query project_id:, query_string:
# [START run_query]
  # [START get_query_results]
  # project_id   = "your google cloud project id"
  # query_string = "query string to execute (using bigquery query syntax)"

  require "google/cloud/bigquery"

  bigquery = Google::Cloud::Bigquery.new project: project_id

  query_results = bigquery.query query_string
  # [END get_query_results]

  # [START display_query_results]
  query_results.each do |row|
    puts row.inspect
  end
  # [END display_query_results]
# [END run_query]
end

def run_query_as_job project_id:, query_string:
  # [START run_query_as_job]
  # project_id   = "your google cloud project id"
  # query_string = "query string to execute (using bigquery query syntax)"

  require "google/cloud/bigquery"

  bigquery = Google::Cloud::Bigquery.new project: project_id

  puts "Running query"
  query_job = bigquery.query_job query_string

  puts "Waiting for query to complete"
  query_job.wait_until_done!

  puts "Query results:"
  query_job.query_results.each do |row|
    puts row.inspect
  end
  # [END run_query_as_job]
end

if __FILE__ == $PROGRAM_NAME
  require "json"

  project_id = ENV["GOOGLE_CLOUD_PROJECT"]
  command    = ARGV.shift

  case command
  when "create"
    create_table project_id: project_id,
                 dataset_id: ARGV.shift,
                 table_id:   ARGV.shift
  when "list"
    list_tables project_id: project_id, dataset_id: ARGV.shift
  when "delete"
    delete_table project_id: project_id,
                 dataset_id: ARGV.shift,
                 table_id:   ARGV.shift
  when "list_data"
    list_table_data project_id: project_id,
                    dataset_id: ARGV.shift,
                    table_id:   ARGV.shift

  when "import_file"
    import_table_data_from_file project_id:      project_id,
                                dataset_id:      ARGV.shift,
                                table_id:        ARGV.shift,
                                local_file_path: ARGV.shift
  when "import_gcs"
    import_table_data_from_cloud_storage project_id:   project_id,
                                         dataset_id:   ARGV.shift,
                                         table_id:     ARGV.shift,
                                         storage_path: ARGV.shift
  when "import_data"
    import_table_data project_id: project_id,
                      dataset_id: ARGV.shift,
                      table_id:   ARGV.shift,
                      row_data:   JSON.parse(ARGV.shift)
  when "export"
    export_table_data_to_cloud_storage project_id:   project_id,
                                       dataset_id:   ARGV.shift,
                                       table_id:     ARGV.shift,
                                       storage_path: ARGV.shift
  when "query"
    run_query project_id: project_id, query_string: ARGV.shift
  when "query_job"
    run_query_as_job project_id: project_id, query_string: ARGV.shift
  else
    puts <<-usage
Usage: ruby tables.rb <command> [arguments]

Commands:
  create      <dataset_id> <table_id>  Create a new table with the specified ID
  list        <dataset_id>             List all tables in the specified dataset
  delete      <dataset_id> <table_id>  Delete table with the specified ID
  list_data   <dataset_id> <table_id>  List data in table with the specified ID
  import_file <dataset_id> <table_id> <file_path>
  import_gcs  <dataset_id> <table_id> <cloud_storage_path>
  import_data <dataset_id> <table_id> "[{ <json row data> }]"
  export      <dataset_id> <table_id> <cloud_storage_path>
  query       <query>
  query_job   <query>
    usage
  end
end
