#!/usr/bin/env ruby

# Copyright 2016 Google, Inc.
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

require "gcloud"

# A short sample demonstrating browsing a BigQuery table
# This uses Application Default Credentials to authenticate.
# @see https://cloud.google.com/bigquery/bigquery-api-quickstart
def browse_table project_id, dataset_id, table_id, max=10
  # [START browse_table]
  gcloud = Gcloud.new project_id
  bigquery = gcloud.bigquery

  dataset = bigquery.dataset dataset_id
  table = dataset.table table_id
  row_num = 0
  page_token = nil
  loop do
    data = table.data :token => page_token, :max => max
    data.each do |row|
      puts "--- Row #{row_num+=1} ---"
      for column, value in row
        puts "#{column}: #{value}"
      end
    end
    break if not data.token
    puts "[Press enter for next page, any key to exit]"
    break if $stdin.gets.chomp != ''
    page_token = data.token
  end
  # [END browse_table]
end

# A short sample demonstrating deleting a BigQuery table
# This uses Application Default Credentials to authenticate.
# @see https://cloud.google.com/bigquery/bigquery-api-quickstart
def delete_table project_id, dataset_id, table_id
  # [START delete_table]
  gcloud = Gcloud.new project_id
  bigquery = gcloud.bigquery

  dataset = bigquery.dataset dataset_id
  table = dataset.table table_id
  table.delete
  # [END delete_table]
  puts "Deleted table #{table_id}"
end

# A short sample demonstrating importing data into BigQuery
# This uses Application Default Credentials to authenticate.
# @see https://cloud.google.com/bigquery/bigquery-api-quickstart
def import project_id, dataset_id, table_id, source
  gcloud = Gcloud.new project_id
  bigquery = gcloud.bigquery

  accepted_formats = [".csv", ".json", ".backup_info"]
  source_format = File.extname(source)
  if not accepted_formats.include? source_format
    raise "source format not accepted, must be csv or json"
  end

  case source_format
  when ".csv"
    format = "CSV"
  when ".json"
    format = "NEWLINE_DELIMITED_JSON"
  when ".backup_info"
    format = "DATASTORE_BACKUP"
  end

  # [START import]
  dataset = bigquery.dataset dataset_id
  table = dataset.table table_id

  job = table.load source, format: format
  job.wait_until_done!

  if job.failed?
    puts job.error
  else
    puts "Data imported successfully"
  end
  # [END import]
end

# A short sample demonstrating importing data into BigQuery
# This uses Application Default Credentials to authenticate.
# @see https://cloud.google.com/bigquery/bigquery-api-quickstart
def import_stream project_id, dataset_id, table_id
  gcloud = Gcloud.new project_id
  bigquery = gcloud.bigquery

  # [START import_stream]
  dataset = bigquery.dataset dataset_id
  table = dataset.table table_id

  row = Hash[table.schema["fields"].map { |f|
    puts "Provide a value for #{f["name"]}"
    [f["name"], $stdin.gets.chomp]
  }]

  job = table.insert [row]
  puts "Row streamed into table successfully"
  # [END import_stream]
end

# A short sample demonstrating listing BigQuery datasets
# This uses Application Default Credentials to authenticate.
# @see https://cloud.google.com/bigquery/bigquery-api-quickstart
def list_datasets project_id
  # [START list_datasets]
  gcloud = Gcloud.new project_id
  bigquery = gcloud.bigquery

  bigquery.datasets.each do |dataset|
    puts "#{dataset.dataset_id}"
  end
  # [END list_datasets]
end

# A short sample demonstrating listing BigQuery tables
# This uses Application Default Credentials to authenticate.
# @see https://cloud.google.com/bigquery/bigquery-api-quickstart
def list_tables project_id, dataset_id
  # [START list_tables]
  gcloud = Gcloud.new project_id
  bigquery = gcloud.bigquery
  dataset = bigquery.dataset dataset_id

  dataset.tables.each do |table|
    puts "#{table.table_id}"
  end
  # [END list_tables]
end

# A short sample demonstrating making a BigQuery request
# This uses Application Default Credentials to authenticate.
# @see https://cloud.google.com/bigquery/bigquery-api-quickstart
def query project_id, sql
  # [START build_service]
  gcloud = Gcloud.new project_id
  bigquery = gcloud.bigquery
  # [END build_service]

  # [START run_query]
  results = bigquery.query sql
  # [END run_query]

  # [START print_results]
  results.each do |row|
    puts "---"
    row.each do |column, value|
      puts "#{column}: #{value}"
    end
  end
  # [END print_results]
end

# A short sample demonstrating making a BigQuery request as a job
# This uses Application Default Credentials to authenticate.
# @see https://cloud.google.com/bigquery/bigquery-api-quickstart
def query_as_job project_id, sql
  gcloud = Gcloud.new project_id
  bigquery = gcloud.bigquery

  # [START run_query]
  job = bigquery.query_job sql

  if job.failed?
    puts job.error
  else
    job.query_results.each do |row|
      puts "---"
      row.each do |column, value|
        puts "#{column}: #{value}"
      end
    end
  end
# [END run_query]
end
