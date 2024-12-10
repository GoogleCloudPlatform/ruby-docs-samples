# Copyright 2024 Google LLC
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

# [START spanner_list_backup_schedules_config]
require "google/cloud/spanner/admin/database"
require "google/cloud/spanner/admin/database/v1"

##
# This is a snippet for showcasing how to get list of schedules for creating backups of a database.
#
# @param project_id  [String] The ID of the Google Cloud project.
# @param instance_id [String] The ID of the spanner instance.
# @param database_id [String] The ID of the database.
#
def spanner_list_backup_schedules(project_id:, instance_id:, database_id:) client = Google::Cloud::Spanner::Admin::Database.database_admin project_id: project_id
  database_name = "projects/#{project_id}/instances/#{instance_id}/databases/#{database_id}"
  request = Google::Cloud::Spanner::Admin::Database::V1::ListBackupSchedulesRequest.new(
  parent: database_name,
)
  backup_schedules_list = client.list_backup_schedules request
  puts "Backup schedules list for #{database_name}"
  backup_schedules_list.each { |backup_schedule| puts backup_schedule.name } end

# [END spanner_list_backup_schedules_config]
