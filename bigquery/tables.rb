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

def create_table_with_schema project_id:, dataset_id:, table_id:
  # [START bigquery_create_table]
  # project_id = "Your Google Cloud project ID"
  # dataset_id = "ID of the dataset to create table in"
  # table_id   = "ID of the table to create"

  require "google/cloud/bigquery"

  bigquery = Google::Cloud::Bigquery.new project: project_id
  dataset  = bigquery.dataset dataset_id

  table    = dataset.create_table table_id do |updater|
    updater.string  "full_name", mode: :required
    updater.integer "age",       mode: :required
  end

  puts "Created table: #{table_id}"
  # [END bigquery_create_table]
end

def create_table_without_schema project_id:, dataset_id:, table_id:
  # [START bigquery_create_table_without_schema]
  # project_id = "Your Google Cloud project ID"
  # dataset_id = "ID of the dataset to create table in"
  # table_id   = "ID of the table to create"

  require "google/cloud/bigquery"

  bigquery = Google::Cloud::Bigquery.new project: project_id
  dataset  = bigquery.dataset dataset_id

  dataset.create_table table_id

  puts "Created table: #{table_id}"
  # [END bigquery_create_table_without_schema]
end

def list_tables project_id:, dataset_id:
  # [START bigquery_list_tables]
  # project_id = "Your Google Cloud project ID"
  # dataset_id = "ID of the dataset to create table in"

  require "google/cloud/bigquery"

  bigquery = Google::Cloud::Bigquery.new project: project_id
  dataset  = bigquery.dataset dataset_id

  dataset.tables.each do |table|
    puts table.table_id
  end
  # [END bigquery_list_tables]
end

def delete_table project_id:, dataset_id:, table_id:
  # [START bigquery_delete_table]
  # project_id = "Your Google Cloud project ID"
  # dataset_id = "ID of the dataset delete table from"
  # table_id   = "ID of the table to delete"

  require "google/cloud/bigquery"

  bigquery = Google::Cloud::Bigquery.new project: project_id
  dataset  = bigquery.dataset dataset_id
  table    = dataset.table table_id

  table.delete

  puts "Deleted table: #{table_id}"
  # [END bigquery_delete_table]
end

def list_table_data project_id:, dataset_id:, table_id:
  # [START bigquery_browse_table]
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
  # [END bigquery_browse_table]
end

def import_table_data project_id:, dataset_id:, table_id:, row_data:
  # [START bigquery_table_insert_rows]
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
  # [END bigquery_table_insert_rows]
end

def import_table_data_from_file project_id:, dataset_id:, table_id:,
                                local_file_path:
  # [START bigquery_load_from_file]
  # project_id      = "Your Google Cloud project ID"
  # dataset_id      = "ID of the dataset containing table"
  # table_id        = "ID of the table to import file data into"
  # local_file_path = "Path to local file to import into BigQuery table"

  require "google/cloud/bigquery"

  bigquery = Google::Cloud::Bigquery.new project: project_id
  dataset  = bigquery.dataset dataset_id
  table    = dataset.table table_id

  puts "Importing data from file: #{local_file_path}"
  load_job = table.load_job local_file_path

  puts "Waiting for load job to complete: #{load_job.job_id}"
  load_job.wait_until_done!

  puts "Data imported"
  # [END bigquery_load_from_file]
end

def import_table_data_from_cloud_storage project_id:, dataset_id:, table_id:,
                                         storage_path:
  # [START bigquery_load_table_gcs_csv]
  # project_id   = "Your Google Cloud project ID"
  # dataset_id   = "ID of the dataset containing table"
  # table_id     = "ID of the table to import data into"
  # storage_path = "Storage path to file to import, eg. gs://bucket/file.csv"

  require "google/cloud/bigquery"

  bigquery = Google::Cloud::Bigquery.new project: project_id
  dataset  = bigquery.dataset dataset_id
  table    = dataset.table table_id

  puts "Importing data from Cloud Storage file: #{storage_path}"
  load_job = table.load_job storage_path

  puts "Waiting for load job to complete: #{load_job.job_id}"
  load_job.wait_until_done!

  puts "Data imported"
  # [END bigquery_load_table_gcs_csv]
end

def export_table_data_to_cloud_storage project_id:, dataset_id:, table_id:,
                                       storage_path:
  # [START bigquery_extract_table]
  # project_id   = "Your Google Cloud project ID"
  # dataset_id   = "ID of the dataset containing table"
  # table_id     = "ID of the table to export file data from"
  # storage_path = "Storage path to export to, eg. gs://bucket/file.csv"

  require "google/cloud/bigquery"

  bigquery = Google::Cloud::Bigquery.new project: project_id
  dataset  = bigquery.dataset dataset_id
  table    = dataset.table table_id

  puts "Exporting data to Cloud Storage file: #{storage_path}"
  extract_job = table.extract_job storage_path

  puts "Waiting for extract job to complete: #{extract_job.job_id}"
  extract_job.wait_until_done!

  puts "Data exported"
  # [END bigquery_extract_table]
end

def import_table_from_gcs_json project_id:, dataset_id:
  # [START bigquery_load_table_gcs_json]
  # project_id = "Your Google Cloud project ID"
  # dataset_id = "ID of the dataset to create table in"

  require "google/cloud/bigquery"

  bigquery     = Google::Cloud::Bigquery.new project: project_id
  dataset      = bigquery.dataset dataset_id
  table_id     = "us_states"
  storage_path = "gs://cloud-samples-data/bigquery/us-states/us-states.json"

  puts "Importing data from Cloud Storage file: #{storage_path}"
  load_job = dataset.load_job table_id, storage_path, format: "json" do |schema|
    schema.string "name"
    schema.string "post_abbr"
  end

  puts "Waiting for load job to complete: #{load_job.job_id}"
  load_job.wait_until_done!

  puts "Data imported"
  # [END bigquery_load_table_gcs_json]
end

def import_table_from_gcs_json_autodetect project_id:, dataset_id:
  # [START bigquery_load_table_gcs_json_autodetect]
  # project_id = "Your Google Cloud project ID"
  # dataset_id = "ID of the dataset to create table in"

  require "google/cloud/bigquery"

  bigquery     = Google::Cloud::Bigquery.new project: project_id
  dataset      = bigquery.dataset dataset_id
  table_id     = "us_states"
  storage_path = "gs://cloud-samples-data/bigquery/us-states/us-states.json"

  puts "Importing data from Cloud Storage file: #{storage_path}"
  load_job = dataset.load_job table_id,
                              storage_path,
                              format: "json",
                              autodetect: true

  puts "Waiting for load job to complete: #{load_job.job_id}"
  load_job.wait_until_done!

  puts "Data imported"
  # [END bigquery_load_table_gcs_json_autodetect]
end

def append_json_data_from_gcs project_id:, dataset_id:, table_id:
  # [START bigquery_load_table_gcs_json_append]
  # project_id = "Your Google Cloud project ID"
  # dataset_id = "ID of the dataset containing table"
  # table_id   = "ID of the table to append data into"

  require "google/cloud/bigquery"

  bigquery = Google::Cloud::Bigquery.new project: project_id
  dataset  = bigquery.dataset dataset_id
  table    = dataset.table table_id

  storage_path = "gs://cloud-samples-data/bigquery/us-states/us-states.json"

  puts "Importing data from Cloud Storage file: #{storage_path}"
  load_job = table.load_job storage_path,
                            format: "json",
                            write: "WRITE_APPEND"

  puts "Waiting for load job to complete: #{load_job.job_id}"
  load_job.wait_until_done!

  puts "Data imported"
  # [END bigquery_load_table_gcs_json_append]
end

def write_truncate_json_data_from_gcs project_id:, dataset_id:, table_id:
  # [START bigquery_load_table_gcs_json_truncate]
  # project_id = "Your Google Cloud project ID"
  # dataset_id = "ID of the dataset containing table"
  # table_id   = "ID of the table to append data into"

  require "google/cloud/bigquery"

  bigquery = Google::Cloud::Bigquery.new project: project_id
  dataset  = bigquery.dataset dataset_id
  table    = dataset.table table_id

  storage_path = "gs://cloud-samples-data/bigquery/us-states/us-states.json"

  puts "Importing data from Cloud Storage file: #{storage_path}"
  load_job = table.load_job storage_path,
                            format: "json",
                            write: "WRITE_TRUNCATE"

  puts "Waiting for load job to complete: #{load_job.job_id}"
  load_job.wait_until_done!

  puts "Data imported"
  # [END bigquery_load_table_gcs_json_truncate]
end

def run_query project_id:, query_string:
  # project_id   = "your google cloud project id"
  # query_string = "query string to execute (using bigquery query syntax)"

  require "google/cloud/bigquery"

  bigquery = Google::Cloud::Bigquery.new project: project_id

  query_results = bigquery.query query_string

  query_results.each do |row|
    puts row.inspect
  end
end

def run_query_as_job project_id:, query_string:
  # [START bigquery_query]
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
  # [END bigquery_query]
end

if __FILE__ == $PROGRAM_NAME
  require "json"

  project_id = ENV["GOOGLE_CLOUD_PROJECT"]
  command    = ARGV.shift

  case command
  when "create"
    create_table_without_schema project_id: project_id,
                                dataset_id: ARGV.shift,
                                table_id:   ARGV.shift
  when "create_with_schema"
    create_table_with_schema project_id: project_id,
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
  when "import_gcs_json"
    import_table_from_gcs_json project_id: project_id,
                               dataset_id: ARGV.shift
  when "import_gcs_json_autodetect"
   import_table_from_gcs_json_autodetect project_id: project_id,
                                         dataset_id: ARGV.shift
  when "import_data"
    import_table_data project_id: project_id,
                      dataset_id: ARGV.shift,
                      table_id:   ARGV.shift,
                      row_data:   JSON.parse(ARGV.shift)
  when "append_rows"
    append_json_data_from_gcs project_id: project_id,
                              dataset_id: ARGV.shift,
                              table_id:   ARGV.shift
  when "overwrite_rows"
    write_truncate_json_data_from_gcs project_id: project_id,
                                      dataset_id: ARGV.shift,
                                      table_id:   ARGV.shift
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
  create                     <dataset_id> <table_id>  Create a new table with the specified ID
  create_with_schema         <dataset_id> <table_id>  Create a new table with a schema
  list                       <dataset_id>             List all tables in the specified dataset
  delete                     <dataset_id> <table_id>  Delete table with the specified ID
  list_data                  <dataset_id> <table_id>  List data in table with the specified ID
  import_file                <dataset_id> <table_id> <file_path>
  import_gcs                 <dataset_id> <table_id> <cloud_storage_path>
  import_gcs_json            <dataset_id>
  import_gcs_json_autodetect <dataset_id>
  import_data                <dataset_id> <table_id> "[{ <json row data> }]"
  append_rows                <dataset_id> <table_id>
  overwrite_rows             <dataset_id> <table_id>
  export                     <dataset_id> <table_id> <cloud_storage_path>
  query                      <query>
  query_job                  <query>
    usage
  end
end
