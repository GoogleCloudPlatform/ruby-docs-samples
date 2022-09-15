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

# [START spanner_list_database_roles]
require "google/cloud/spanner"

def spanner_list_database_roles project_id:, instance_id:, database_id:
  # project_id  = "Your Google Cloud project ID"
  # instance_id = "Your Spanner instance ID"
  # database_id = "Your Spanner database ID"

  admin_client = Google::Cloud::Spanner::Admin::Database::V1::DatabaseAdmin::Client.new

  db_path = admin_client.database_path project: project_id, instance: instance_id, database: database_id

  result = admin_client.list_database_roles parent: db_path

  puts "List of Database roles:"
  result.each do |role|
    puts role.name
  end
end
# [END spanner_list_database_roles]

if $PROGRAM_NAME == __FILE__
  spanner_list_database_roles project_id: ARGV.shift, instance_id: ARGV.shift, database_id: ARGV.shift
end
