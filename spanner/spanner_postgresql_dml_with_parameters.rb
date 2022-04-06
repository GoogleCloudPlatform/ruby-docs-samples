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

# [START spanner_postgresql_dml_with_parameters]
require "google/cloud/spanner"

def spanner_postgresql_dml_with_parameters project_id:, instance_id:, database_id:
  # project_id  = "Your Google Cloud project ID"
  # instance_id = "Your Spanner instance ID"
  # database_id = "Your Spanner database ID"

  spanner = Google::Cloud::Spanner.new project: project_id
  client  = spanner.client instance_id, database_id

  # Spanner implementation of PostgreSQL supports positional parameters. Named parameters are not supported.
  sql_query = "INSERT INTO Singers (SingerId, FirstName, LastName) VALUES ($1, $2, $3), ($4, $5, $6)"
  params = { p1: 103, p2: "Olivia", p3: "Garcia",
             p4: 105, p5: "George", p6: "Harrison" }

  row_count = nil
  client.transaction do |transaction|
    row_count = transaction.execute_update sql_query, params: params
  end

  puts "Inserted #{row_count} rows"
end
# [END spanner_postgresql_dml_with_parameters]

if $PROGRAM_NAME == __FILE__
  spanner_postgresql_dml_with_parameters project_id: ARGV.shift, instance_id: ARGV.shift, database_id: ARGV.shift
end
