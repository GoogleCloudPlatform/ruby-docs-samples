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

# [START spanner_postgresql_create_database]
require "google/cloud/spanner"
require "google/cloud/spanner/admin/database"

def postgresql_create_database project_id:, instance_id:, database_id:
  # project_id  = "Your Google Cloud project ID"
  # instance_id = "Your Spanner instance ID"
  # database_id = "Your Spanner database ID"

  database_admin_client = Google::Cloud::Spanner::Admin::Database.database_admin project: project_id

  instance_path = database_admin_client.instance_path project: project_id, instance: instance_id

  job = database_admin_client.create_database parent: instance_path,
                                              create_statement: "CREATE DATABASE \"#{database_id}\"",
                                              database_dialect: :POSTGRESQL

  puts "Waiting for create database operation to complete"

  job.wait_until_done!

  puts "Created database #{database_id} on instance #{instance_id}"
end
# [END spanner_postgresql_create_database]

if $PROGRAM_NAME == __FILE__
  postgresql_create_database project_id: ARGV.shift, instance_id: ARGV.shift, database_id: ARGV.shift
end
