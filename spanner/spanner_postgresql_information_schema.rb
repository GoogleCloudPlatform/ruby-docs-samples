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

# [START spanner_postgresql_information_schema]
require "google/cloud/spanner"

def spanner_postgresql_information_schema project_id:, instance_id:, database_id:
  # project_id  = "Your Google Cloud project ID"
  # instance_id = "Your Spanner instance ID"
  # database_id = "Your Spanner database ID"

  spanner = Google::Cloud::Spanner.new project: project_id
  client  = spanner.client instance_id, database_id

  # The user_defined_type_* columns below are only available for PostgreSQL databases.
  sql_query = <<~QUERY
    SELECT table_schema,
           table_name,
           user_defined_type_schema,
           user_defined_type_name
    FROM INFORMATION_SCHEMA.tables
    WHERE table_schema='public'
  QUERY

  results = client.execute sql_query

  results.rows.each do |row|
    puts "Schema: #{row[:table_schema]}"
    puts "Name: #{row[:table_name]}"
    puts "User Defined Type: Schema #{row[:user_defined_type_schema]}"
    puts "User Defined Type: Name #{row[:user_defined_type_name]}"
  end
end
# [END spanner_postgresql_information_schema]

if $PROGRAM_NAME == __FILE__
  spanner_postgresql_information_schema project_id: ARGV.shift, instance_id: ARGV.shift, database_id: ARGV.shift
end
