# Copyright 2023 Google, Inc
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

# [START spanner_update_database]
require "google/cloud/spanner/admin/database"

##
# This is a snippet for showcasing how to update database.
#
# @param project_id  [String] The ID of the Google Cloud project.
# @param instance_id [String] The ID of the spanner instance.
# @param database_id [String] The ID of the database.
#
def spanner_update_database project_id:, instance_id:, database_id:
  client = Google::Cloud::Spanner::Admin::Database.database_admin project_id: project_id
  db_path = client.database_path project: project_id, instance: instance_id, database: database_id
  database = client.get_database name: db_path

  puts "Updating database #{database.name}"
  database.enable_drop_protection = true
  job = client.update_database database: database, update_mask: { paths: ["enable_drop_protection"] }
  puts "Waiting for update operation for #{database.name} to complete..."
  job.wait_until_done!
  puts "Updated database #{database.name}"
end

# [END spanner_update_database]
