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

# [START spanner_postgresql_partitioned_dml]
require "google/cloud/spanner"

def spanner_postgresql_partitioned_dml project_id:, instance_id:, database_id:
  # project_id  = "Your Google Cloud project ID"
  # instance_id = "Your Spanner instance ID"
  # database_id = "Your Spanner database ID"

  spanner = Google::Cloud::Spanner.new project: project_id
  client  = spanner.client instance_id, database_id

  # Spanner PostgreSQL has the same transaction limits as normal Spanner. This includes a
  # maximum of 20,000 mutations in a single read/write transaction. Large update operations can
  # be executed using Partitioned DML. This is also supported on Spanner PostgreSQL.
  # See https://cloud.google.com/spanner/docs/dml-partitioned for more information.

  sql_query = "DELETE FROM Singers WHERE SingerId > 3"

  # The returned count is the lower bound of the number of records that was deleted.
  row_count = client.execute_partition_update sql_query

  puts "#{row_count} row(s) deleted."
end
# [END spanner_postgresql_partitioned_dml]

if $PROGRAM_NAME == __FILE__
  spanner_postgresql_partitioned_dml project_id: ARGV.shift, instance_id: ARGV.shift, database_id: ARGV.shift
end
