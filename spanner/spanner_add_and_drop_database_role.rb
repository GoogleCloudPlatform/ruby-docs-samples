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

# [START spanner_add_and_drop_database_role]
require "google/cloud/spanner"

def spanner_add_and_drop_database_role project_id:, instance_id:, database_id:
  # project_id  = "Your Google Cloud project ID"
  # instance_id = "Your Spanner instance ID"
  # database_id = "Your Spanner database ID"

  admin_client = Google::Cloud::Spanner::Admin::Database::V1::DatabaseAdmin::Client.new
  role_parent = "new_parent"
  role_child = "new_child"

  db_path = admin_client.database_path project: project_id, instance: instance_id, database: database_id

  job = admin_client.update_database_ddl database: db_path, statements: [
    "CREATE ROLE #{role_parent}",
    "GRANT SELECT ON TABLE Singers TO ROLE #{role_parent}",
    "CREATE ROLE #{role_child}",
    "GRANT ROLE #{role_parent} TO ROLE #{role_child}"
  ]

  job.wait_until_done!
  puts "Created roles #{role_parent} and #{role_child} and granted privileges"


  job = admin_client.update_database_ddl database: db_path, statements: [
    "REVOKE ROLE #{role_parent} FROM ROLE #{role_child}",
    "DROP ROLE #{role_child}"
  ]

  job.wait_until_done!
  puts "Revoked privileges and dropped role #{role_child}"
end
# [END spanner_add_and_drop_database_role]

if $PROGRAM_NAME == __FILE__
  spanner_add_and_drop_database_role project_id: ARGV.shift, instance_id: ARGV.shift, database_id: ARGV.shift
end
