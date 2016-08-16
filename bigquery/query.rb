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
    # A short sample demonstrating making a BigQuery request
    # This uses Application Default Credentials to authenticate.
    # @see https://cloud.google.com/bigquery/bigquery-api-quickstart
    class Query
      def run_query project_id, sql
        # [START build_service]
        require "gcloud"

        gcloud = Gcloud.new project_id
        bigquery = gcloud.bigquery
        # [END build_service]

        # [START run_query]
        results = bigquery.query sql
        # [END run_query]

        # [START print_results]
        results.each_with_index do |row, index|
          puts "--- Row #{index+1} ---"
          for column, value in row
            puts "#{column}: #{value}"
          end
        end
        # [END print_results]
      end
    end

    if __FILE__ == $PROGRAM_NAME
      if ARGV.length != 2
        puts "usage: tables.rb [project_id] [sql]"
      else
        project_id = ARGV.shift
        sql = ARGV.shift
        Query.new.run_query project_id, sql
      end
    end
    # [END all]
  end
end
