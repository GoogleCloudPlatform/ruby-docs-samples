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

# [START spanner_delete_dml_returning]
require "google/cloud/spanner"

##
# This is a snippet for showcasing how to use DML return feature with delete
# operation.
#
# @param project_id  [String] The ID of the Google Cloud project.
# @param instance_id [String] The ID of the spanner instance.
# @param database_id [String] The ID of the database.
#
def spanner_delete_dml_returning project_id:, instance_id:, database_id:
  spanner = Google::Cloud::Spanner.new project: project_id
  client = spanner.client instance_id, database_id

  client.transaction do |transaction|
    # Delete records from SINGERS table satisfying a particular condition and
    # returns the SingerId and FullName column of the deleted records using
    # ‘THEN RETURN SingerId, FullName’.
    # It is also possible to return all columns of all the deleted records
    # by using ‘THEN RETURN *’.
    results = transaction.execute_query "DELETE FROM Singers WHERE FirstName = 'Alice' THEN RETURN SingerId, FullName"
    results.rows.each do |row|
      puts "Deleted singer with SingerId: #{row[:SingerId]}, FullName: #{row[:FullName]}"
    end
    puts "Deleted row(s) count: #{results.row_count}"
  end
end

# [END spanner_delete_dml_returning]
