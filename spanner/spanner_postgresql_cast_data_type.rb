# Copyright 2022 Google, Inc
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

# [START spanner_postgresql_cast_data_type]
require "google/cloud/spanner"

def spanner_postgresql_cast_data_type project_id:, instance_id:, database_id:
  # project_id  = "Your Google Cloud project ID"
  # instance_id = "Your Spanner instance ID"
  # database_id = "Your Spanner database ID"

  spanner = Google::Cloud::Spanner.new project: project_id
  client  = spanner.client instance_id, database_id

  # The `::` cast operator can be used to cast from one data type to another.
  sql_query = <<~QUERY
    SELECT 1::varchar as str,
           '2'::int as int,
           3::decimal as dec,
           '4'::bytea as bytes,
           5::float as float,
           'true'::bool as bool,
           '2021-11-03T09:35:01UTC'::timestamptz as timestamp
  QUERY

  results = client.execute sql_query

  results.rows.each do |row|
    puts "str: #{row[:str]}"
    puts "int: #{row[:int]}"
    puts "dec: #{row[:dec]}"
    puts "bytes: #{row[:bytes].string}"
    puts "float: #{row[:float]}"
    puts "bool: #{row[:bool]}"
    puts "timestamp: #{row[:timestamp]}"
  end
end
# [END spanner_postgresql_cast_data_type]

if $PROGRAM_NAME == __FILE__
  spanner_postgresql_cast_data_type project_id: ARGV.shift, instance_id: ARGV.shift, database_id: ARGV.shift
end
