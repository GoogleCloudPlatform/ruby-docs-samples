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

# [START spanner_create_full_backup_schedule_config]
require "google/cloud/spanner/admin/database/v1"

##
# This is a snippet for showcasing how to create a schedule for full backups.
#
# @param project_id  [String] The ID of the Google Cloud project.
# @param instance_id [String] The ID of the spanner instance.
# @param database_id [String] The ID of the database.
# @param backup_schedule_id [String] The ID of the backup schedule to be created.
#
def spanner_create_full_backup_schedule project_id:, instance_id:, database_id:, backup_schedule_id:
  client = Google::Cloud::Spanner::Admin::Database.database_admin project_id: project_id
  db_path = client.database_path project: project_id, instance: instance_id, database: database_id
  database = client.get_database name: db_path

  cron_spec = Google::Cloud::Spanner::Admin::Database::V1::DatabaseAdmin::CrontabSpec.new text: "30 12 * * *"
  backup_schedule_spec = Google::Cloud::Spanner::Admin::Database::V1::DatabaseAdmin::BackupScheduleSpec.new cron_spec: cron_spec

  encryption_config = Google::Cloud::Spanner::Admin::Database::V1::DatabaseAdmin::CreateBackupEncryptionConfig::EncryptionType.USE_DATABASE_ENCRYPTION

  backup_schedule = {
    full_backup_schedule: Google::Cloud::Spanner::Admin::Database::V1::DatabaseAdmin::FullBackupSpec.new,
    retention_duration: Google::Protobuf::Duration.new(seconds: 3600 * 24),
    spec: backup_schedule_spec,
    encryption_config: encryption_config
  }

  request = {
    parent: database.name,
    backup_schedule_id: backup_schedule_id,
    backup_schedule: backup_schedule
  }

  created_backup_schedule = client.create_backup_schedule request
  puts "Created full backup schedule for #{created_backup_schedule.name}"
  puts created_backup_schedule
end
# [END spanner_create_full_backup_schedule_config]
