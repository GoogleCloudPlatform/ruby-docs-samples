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

def create_dataset project_id:, dataset_id:
  # [START create_dataset]
  # project_id = "Your Google Cloud project ID"
  # dataset_id = "ID of the dataset to create"

  require "google/cloud"

  gcloud   = Google::Cloud.new project_id
  bigquery = gcloud.bigquery

  bigquery.create_dataset dataset_id

  puts "Created dataset: #{dataset_id}"
  # [END create_dataset]
end

def list_datasets project_id:
  # [START list_datasets]
  # project_id = "Your Google Cloud project ID"

  require "google/cloud"

  gcloud   = Google::Cloud.new project_id
  bigquery = gcloud.bigquery

  bigquery.datasets.each do |dataset|
    puts dataset.dataset_id
  end
  # [END list_datasets]
end

def delete_dataset project_id:, dataset_id:
  # [START delete_dataset]
  # project_id = "Your Google Cloud project ID"
  # dataset_id = "ID of the dataset to delete"

  require "google/cloud"

  gcloud   = Google::Cloud.new project_id
  bigquery = gcloud.bigquery
  dataset  = bigquery.dataset dataset_id

  dataset.delete

  puts "Deleted dataset: #{dataset_id}"
  # [END delete_dataset]
end

def create_table project_id:, dataset_id:, table_id:
  # [START create_table]
  # project_id = "Your Google Cloud project ID"
  # dataset_id = "ID of the dataset to create table in"
  # table_id   = "ID of the table to create"

  require "google/cloud"

  gcloud   = Google::Cloud.new project_id
  bigquery = gcloud.bigquery
  dataset  = bigquery.dataset dataset_id

  dataset.create_table table_id

  puts "Created table: #{table_id}"
  # [END create_table]
end

def list_tables project_id:, dataset_id:
  # [START list_datasets]
  # project_id = "Your Google Cloud project ID"
  # dataset_id = "ID of the dataset to create table in"

  require "google/cloud"

  gcloud   = Google::Cloud.new project_id
  bigquery = gcloud.bigquery
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

  require "google/cloud"

  gcloud   = Google::Cloud.new project_id
  bigquery = gcloud.bigquery
  dataset  = bigquery.dataset dataset_id
  table    = dataset.table table_id

  table.delete

  puts "Deleted table: #{table_id}"
  # [END delete_table]
end

def list_table_data project_id:, dataset_id:, table_id:
  # [START list_table_data]
  # project_id = "Your Google Cloud project ID"
  # dataset_id = "ID of the dataset delete table from"
  # table_id   = "ID of the table to display data for"

  require "google/cloud"

  gcloud   = Google::Cloud.new project_id
  bigquery = gcloud.bigquery
  dataset  = bigquery.dataset dataset_id
  table    = dataset.table table_id

  table.data.each do |row|
    row.each      do |column_name, value|
      puts "#{column_name} = #{value}"
    end
  end
  # [END list_table_data]
end

def import_table_data_from_file project_id:, dataset_id:, table_id:,
                                local_file_path:
  # [START import_table_data_from_file]
  # project_id = "Your Google Cloud project ID"
  # dataset_id = "ID of the dataset delete table from"
  # table_id   = "ID of the table to import file data into"

  require "google/cloud"

  gcloud   = Google::Cloud.new project_id
  bigquery = gcloud.bigquery
  dataset  = bigquery.dataset dataset_id
  table    = dataset.table table_id

  puts "Importing data from file: #{local_file_path}"
  load_job = table.load local_file_path

  puts "Waiting for load job to complete: #{load_job.job_id}"
  load_job.wait_until_done!

  puts "Data imported"
  # [END import_table_data_from_file]
end

# TODO: separate sample into separate executable files
#
if __FILE__ == $PROGRAM_NAME
  project_id = ENV["GOOGLE_CLOUD_PROJECT"]
  command    = ARGV.shift

  case command
  when "< command here >"
  else
    puts "Usage: "
  end
end
