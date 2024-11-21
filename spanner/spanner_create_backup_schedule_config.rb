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

# [START spanner_create_backup_schedule_config]
require "google/cloud/spanner/admin/database"
require "google/cloud/spanner/admin/database/v1"

##
# This is a snippet for showcasing how to create a schedule for backups.
#
# @param project_id  [String] The ID of the Google Cloud project.
# @param instance_id [String] The ID of the spanner instance.
# @param database_id [String] The ID of the database.
# @param backup_schedule_id [String] The ID of the backup schedule to be created.
#
def spanner_create_backup_schedule project_id:, instance_id:, database_id:, backup_schedule_id:
  client = Google::Cloud::Spanner::Admin::Database.database_admin project_id: project_id
  database_name = "projects/#{project_id}/instances/#{instance_id}/databases/#{database_id}"

  # For creating schedule for incremental backup use:
  # backup_spec = Google::Cloud::Spanner::Admin::Database::V1::IncrementalBackupSpec.new
  backup_spec = Google::Cloud::Spanner::Admin::Database::V1::FullBackupSpec.new
  retention_duration = Google::Protobuf::Duration.new(seconds: 3600 * 24)

  encryption_type = Google::Cloud::Spanner::Admin::Database::V1::CreateBackupEncryptionConfig::EncryptionType::USE_DATABASE_ENCRYPTION
  encryption_config = Google::Cloud::Spanner::Admin::Database::V1::CreateBackupEncryptionConfig.new(
    encryption_type: encryption_type
  )

  cron_spec = Google::Cloud::Spanner::Admin::Database::V1::CrontabSpec.new(text: "30 12 * * *")
  backup_schedule_spec = Google::Cloud::Spanner::Admin::Database::V1::BackupScheduleSpec.new(
    cron_spec: cron_spec
  )

  backup_schedule = Google::Cloud::Spanner::Admin::Database::V1::BackupSchedule.new(
    full_backup_spec: backup_spec,
    retention_duration: retention_duration,
    spec: backup_schedule_spec,
    encryption_config: encryption_config
  )

  request = Google::Cloud::Spanner::Admin::Database::V1::CreateBackupScheduleRequest.new(
    parent: database_name,
    backup_schedule_id: backup_schedule_id,
    backup_schedule: backup_schedule
  )

  created_backup_schedule = client.create_backup_schedule request
  puts "Created backup schedule for #{created_backup_schedule.name}"
end
# [END spanner_create_backup_schedule_config]
