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
    # A short sample demonstrating deleting a BigQuery table
    # This uses Application Default Credentials to authenticate.
    # @see https://cloud.google.com/bigquery/bigquery-api-quickstart
    class DeleteTable
      def delete project_id, dataset_id, table_id
        # [START delete_table]
        require "gcloud"

        gcloud = Gcloud.new project_id
        bigquery = gcloud.bigquery

        dataset = bigquery.dataset dataset_id
        table = dataset.table table_id
        table.delete
        # [END delete_table]
        puts "Deleted table #{table_id}"
      end
    end

    if __FILE__ == $PROGRAM_NAME
      if ARGV.length != 3
        puts "usage: delete_table.rb [project_id] [dataset_id] [table_id]"
      else
        project_id = ARGV.shift
        dataset_id = ARGV.shift
        table_id = ARGV.shift
        DeleteTable.new.delete project_id, dataset_id, table_id
      end
    end
  end
end
