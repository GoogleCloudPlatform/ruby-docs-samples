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
# [END all]

if __FILE__ == $PROGRAM_NAME
  if ARGV.length != 2
    puts "usage: list_tables.rb [project_id] [dataset_id]"
  else
    list_tables *ARGV
  end
end
