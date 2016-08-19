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

module Samples
  # BigQuery Samples module
  module BigQuery
    # [START all]
    # A short sample demonstrating importing data into BigQuery
    # This uses Application Default Credentials to authenticate.
    # @see https://cloud.google.com/bigquery/bigquery-api-quickstart
    class ImportStream
      def import project_id, dataset_id, table_id
        require "gcloud"

        gcloud = Gcloud.new project_id
        bigquery = gcloud.bigquery

        # [START import_stream]
        dataset = bigquery.dataset dataset_id
        table = dataset.table table_id

        row = Hash[table.schema["fields"].map { |f|
          puts "Provide a value for #{f["name"]}"
          [f["name"], $stdin.gets.chomp]
        }]
        puts row
        # job = table.insert [rows]
        # [END import_stream]
      end
    end

    if __FILE__ == $PROGRAM_NAME
      if ARGV.length != 3
        puts "usage: import_stream.rb [project_id] [dataset_id] [table_id]"
      else
        project_id = ARGV.shift
        dataset_id = ARGV.shift
        table_id = ARGV.shift
        ImportStream.new.import project_id, dataset_id, table_id
      end
    end
    # [END all]
  end
end
