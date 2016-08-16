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
    # A short sample demonstrating browsing a BigQuery table
    # This uses Application Default Credentials to authenticate.
    # @see https://cloud.google.com/bigquery/bigquery-api-quickstart
    class BrowseTable
      def browse project_id, dataset_id, table_id, max=10
        # [START browse_table]
        require "gcloud"

        gcloud = Gcloud.new project_id
        bigquery = gcloud.bigquery

        dataset = bigquery.dataset dataset_id
        table = dataset.table table_id
        token = nil
        row_num = 0
        loop do
          data = table.data :token => token, :max => max
          data.each do |row|
            puts "--- Row #{row_num+=1} ---"
            for column, value in row
              puts "#{column}: #{value}"
            end
          end
          break if not data.token
          puts "[Press enter for next page, any key to exit]"
          break if $stdin.gets.chomp != ''
          token = data.token
        end
        # [END browse_table]
      end
    end

    if __FILE__ == $PROGRAM_NAME
      if not (3..4) === ARGV.length
        puts "usage: browse_table.rb [project_id] [dataset_id] [table_id] [max_results=10]"
      else
        project_id = ARGV.shift
        dataset_id = ARGV.shift
        table_id = ARGV.shift
        BrowseTable.new.browse project_id, dataset_id, table_id, ARGV.length ? ARGV.shift : nil
      end
    end
  end
end
