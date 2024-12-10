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

# [START spanner_update_backup_schedule_config]
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
def spanner_update_backup_schedule(project_id:, instance_id:, database_id:, backup_schedule_id:) client = Google::Cloud::Spanner::Admin::Database.database_admin project_id: project_id
  backup_schedule_name = "projects/#{project_id}/instances/#{instance_id}/databases/#{database_id}/backupSchedules/#{backup_schedule_id}"
  retention_duration = Google::Protobuf::Duration.new(seconds: 3600 * 24)
  encryption_type = Google::Cloud::Spanner::Admin::Database::V1::CreateBackupEncryptionConfig::EncryptionType::GOOGLE_DEFAULT_ENCRYPTION
  encryption_config = Google::Cloud::Spanner::Admin::Database::V1::CreateBackupEncryptionConfig.new(
  encryption_type: encryption_type,
)
  cron_spec = Google::Cloud::Spanner::Admin::Database::V1::CrontabSpec.new(text: "45 10 * * *")
  backup_schedule_spec = Google::Cloud::Spanner::Admin::Database::V1::BackupScheduleSpec.new(
  cron_spec: cron_spec,
)
  backup_schedule = Google::Cloud::Spanner::Admin::Database::V1::BackupSchedule.new(
  name: backup_schedule_name,
  retention_duration: retention_duration,
  spec: backup_schedule_spec,
  encryption_config: encryption_config,
)
  field_mask = Google::Protobuf::FieldMask.new(
  paths: ["retention_duration", "spec.cron_spec.text", "encryption_config"],
)
  request = Google::Cloud::Spanner::Admin::Database::V1::UpdateBackupScheduleRequest.new(
  backup_schedule: backup_schedule,
  update_mask: field_mask,
)
  updated_backup_schedule = client.update_backup_schedule request
  puts "Updated backup schedule for #{updated_backup_schedule.name}" end

# [END spanner_update_backup_schedule_config]
