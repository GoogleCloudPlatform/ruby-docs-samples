#!/usr/bin/env ruby

# Copyright 2015 Google, Inc.
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

# [START all]
require "gcloud"
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
# [END all]

if __FILE__ == $PROGRAM_NAME
  if ARGV.length != 4
    puts "usage: import.rb [project_id] [dataset_id] [table_id] [source]"
  else
    project_id = ARGV.shift
    dataset_id = ARGV.shift
    table_id = ARGV.shift
    source = ARGV.shift
    import project_id, dataset_id, table_id, source
  end
end

