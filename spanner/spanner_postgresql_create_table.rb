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

# [START spanner_postgresql_create_table]
require "google/cloud/spanner"
require "google/cloud/spanner/admin/database"

def spanner_postgresql_create_table project_id:, instance_id:, database_id:
  # project_id  = "Your Google Cloud project ID"
  # instance_id = "Your Spanner instance ID"
  # database_id = "Your Spanner database ID"

  db_admin_client = Google::Cloud::Spanner::Admin::Database.database_admin project: project_id

  db_path = db_admin_client.database_path project: project_id,
                                          instance: instance_id,
                                          database: database_id

  create_table_query = <<~QUERY
    CREATE TABLE Singers (
      SingerId bigint NOT NULL PRIMARY KEY,
      FirstName varchar(1024),
      LastName varchar(1024),
      Rating numeric,
      SingerInfo bytea
    );
  QUERY

  job = db_admin_client.update_database_ddl database: db_path,
                                            statements: [create_table_query]

  job.wait_until_done!

  if job.error?
    puts "Error while creating table. Code: #{job.error.code}. Message: #{job.error.message}"
    raise GRPC::BadStatus.new(job.error.code, job.error.message)
  end

  puts "Created a table using PostgreSQL dialect"
end
# [END spanner_postgresql_create_table]

if $PROGRAM_NAME == __FILE__
  spanner_postgresql_create_table project_id: ARGV.shift, instance_id: ARGV.shift, database_id: ARGV.shift
end
