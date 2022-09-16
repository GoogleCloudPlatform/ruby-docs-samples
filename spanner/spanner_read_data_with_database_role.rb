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

# [START spanner_read_data_with_database_role]
require "google/cloud/spanner"

def spanner_read_data_with_database_role project_id:, instance_id:, database_id:
  # project_id  = "Your Google Cloud project ID"
  # instance_id = "Your Spanner instance ID"
  # database_id = "Your Spanner database ID"

  role = "new_parent"
  spanner = Google::Cloud::Spanner.new project: project_id
  client = spanner.client instance_id, database_id, database_role: role

  result = client.execute_sql "SELECT * FROM Singers"

  result.rows.each do |row|
    puts "SingerId: #{row[:SingerId]}"
    puts "FirstName: #{row[:FirstName]}"
    puts "LastName: #{row[:LastName]}"
  end
end
# [END spanner_read_data_with_database_role]

if $PROGRAM_NAME == __FILE__
  spanner_read_data_with_database_role project_id: ARGV.shift, instance_id: ARGV.shift, database_id: ARGV.shift
end
