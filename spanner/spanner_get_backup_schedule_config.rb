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

# [START spanner_get_backup_schedule_config]
require "google/cloud/spanner/admin/database"
require "google/cloud/spanner/admin/database/v1"

##
# This is a snippet for showcasing how to get a backup creation schedule.
#
# @param project_id  [String] The ID of the Google Cloud project.
# @param instance_id [String] The ID of the spanner instance.
# @param database_id [String] The ID of the database.
# @param backup_schedule_id [String] The ID of the backup schedule to be created.
#
def spanner_get_backup_schedule project_id:, instance_id:, database_id:, backup_schedule_id:
  client                = Google::Cloud::Spanner::Admin::Database.database_admin project_id: project_id
  backup_schedule_name  = "projects/#{project_id}/instances/#{instance_id}/databases/#{database_id}/backupSchedules/#{backup_schedule_id}"

  request = Google::Cloud::Spanner::Admin::Database::V1::GetBackupScheduleRequest.new name: backup_schedule_name

  backup_schedule = client.get_backup_schedule request
  puts "Backup schedule: #{backup_schedule.name}"
end

# [END spanner_get_backup_schedule_config]
