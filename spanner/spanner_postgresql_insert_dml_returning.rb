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
  spanner = Google::Cloud::Spanner.new project: project_id
  client = spanner.client instance_id, database_id

  client.transaction do |transaction|
    # Insert records into SINGERS table and returns the generated column
    # FullName of the inserted records using ‘RETURNING FullName’.
    # It is also possible to return all columns of all the inserted
    # records by using ‘RETURNING *’.
    results = transaction.execute_query "INSERT INTO Singers (SingerId, FirstName, LastName)
                                         VALUES (12, 'Melissa', 'Garcia'), (13, 'Russell', 'Morales'), (14, 'Jacqueline', 'Long'), (15, 'Dylan', 'Shaw')
                                         RETURNING FullName"
    results.rows.each do |row|
      puts "Inserted singers with FullName: #{row[:fullname]}"
    end
    puts "Inserted row(s) count: #{results.row_count}"
  end
end

# [END spanner_postgresql_insert_dml_returning]
