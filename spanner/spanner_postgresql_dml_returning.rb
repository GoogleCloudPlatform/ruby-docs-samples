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

# [START spanner_postgresql_delete_dml_returning]
require "google/cloud/spanner"

##
# This is a snippet for showcasing how to use DML return feature with delete
# operation in PostgreSql.
#
# @param project_id  [String] The ID of the Google Cloud project.
# @param instance_id [String] The ID of the spanner instance.
# @param database_id [String] The ID of the database.
#
def spanner_postgresql_delete_dml_returning project_id:, instance_id:, database_id:

  spanner = Google::Cloud::Spanner.new project: project_id, endpoint: 'staging-wrenchworks.sandbox.googleapis.com'
  client = spanner.client instance_id, database_id

  client.transaction do |transaction|
    results = transaction.execute_query "DELETE FROM singers WHERE firstname = 'Alice' RETURNING singerid, firstname"
    results.rows.each do |row|
      puts "Deleted singer with id: #{row[:singerid]}, FirstName: #{row[:firstname]}"
    end
    puts "Deleted row(s) count: #{results.row_count}"
  end
end

# [END spanner_postgresql_delete_dml_returning]

# [START spanner_postgresql_update_dml_returning]
require "google/cloud/spanner"

##
# This is a snippet for showcasing how to use DML return feature with update
# operation in PostgreSql.
#
# @param project_id  [String] The ID of the Google Cloud project.
# @param instance_id [String] The ID of the spanner instance.
# @param database_id [String] The ID of the database.
#
def spanner_postgresql_update_dml_returning project_id:, instance_id:, database_id:

  spanner = Google::Cloud::Spanner.new project: project_id, endpoint: 'staging-wrenchworks.sandbox.googleapis.com'
  client = spanner.client instance_id, database_id

  client.transaction do |transaction|
    results = transaction.execute_query "UPDATE Singers SET LastName = LastName || '_update' WHERE SingerId = 1 RETURNING *"
    results.rows.each do |row|
      puts "Updated Singer with SingerId: #{row[:singerid]}, FirstName: #{row[:firstname]}, LastName: #{row[:lastname]}"
    end
    puts "Updated row(s) count: #{results.row_count}"
  end
end

# [END spanner_postgresql_update_dml_returning]

# [START spanner_postgresql_insert_dml_returning]
require "google/cloud/spanner"

##
# This is a snippet for showcasing how to use DML return feature with insert
# operation in PostgreSql.
#
# @param project_id  [String] The ID of the Google Cloud project.
# @param instance_id [String] The ID of the spanner instance.
# @param database_id [String] The ID of the database.
#
def spanner_postgresql_insert_dml_returning project_id:, instance_id:, database_id:

  spanner = Google::Cloud::Spanner.new project: project_id, endpoint: 'staging-wrenchworks.sandbox.googleapis.com'
  client = spanner.client instance_id, database_id

  client.transaction do |transaction|
    results = transaction.execute_query "INSERT INTO Singers (SingerId, FirstName, LastName) VALUES (12, 'Melissa', 'Garcia'), (13, 'Russell', 'Morales'), (14, 'Jacqueline', 'Long'), (15, 'Dylan', 'Shaw') RETURNING *"
    results.rows.each do |row|
      puts "Insert singers with id: #{row[:singerid]}, FirstName: #{row[:firstname]}, LastName: #{row[:lastname]}"
    end
    puts "Inserted row(s) count: #{results.row_count}"
  end
end

# [END spanner_postgresql_insert_dml_returning]

require_relative 'spanner_postgresql_create_database'
if $PROGRAM_NAME == __FILE__
  project_id = 'appdev-soda-spanner-staging'
  database_id = "test_#{SecureRandom.hex 8}"
  instance_id = 'diptanshu-test-instance'
  postgresql_create_database project_id: project_id, instance_id: instance_id, database_id: database_id
  db_admin_client = Google::Cloud::Spanner::Admin::Database.database_admin project: @project_id, endpoint: 'staging-wrenchworks.sandbox.googleapis.com'
  db_path = db_admin_client.database_path project:  project_id,
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
  spanner = Google::Cloud::Spanner.new project: project_id, endpoint: 'staging-wrenchworks.sandbox.googleapis.com'
  client  = spanner.client instance_id, database_id
  client.commit do |c|
    c.insert "Singers", [
      { SingerId: 1, FirstName: "Ann", LastName: "Louis", Rating: BigDecimal("3.6") },
      { SingerId: 2, FirstName: "Olivia", LastName: "Garcia", Rating: BigDecimal("2.1") },
      { SingerId: 3, FirstName: "Alice", LastName: "Henderson", Rating: BigDecimal("4.8") },
      { SingerId: 4, FirstName: "Bruce", LastName: "Allison", Rating: BigDecimal("2.7") }
    ]
  end
  spanner_postgresql_update_dml_returning project_id: project_id, instance_id: instance_id, database_id: database_id
end
