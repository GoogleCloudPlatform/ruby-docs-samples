# Copyright 2025 Google LLC
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

require_relative "./spec_helper"
require_relative "../spanner_create_backup_schedule_config"
require_relative "../spanner_delete_backup_schedule_config"
require_relative "../spanner_get_backup_schedule_config"
require_relative "../spanner_list_backup_schedules_config"
require_relative "../spanner_update_backup_schedule_config"

describe "Spanner schedule for backups:" do
  before :all do
    create_test_database @database_id
  end

  after :all do
    cleanup_database_resources
  end
  example "Create backup schedule" do
    capture do
      spanner_create_backup_schedule project_id: @project_id, instance_id: @instance_id, database_id: @database_id, backup_schedule_id: @backup_schedule_id
    end
    expect(captured_output).to include "projects/#{@project_id}/instances/#{@instance_id}/databases/#{@database_id}/backupSchedules/#{@backup_schedule_id}"
  end

  example "Get backup schedule" do
    capture do
      spanner_get_backup_schedule project_id: @project_id, instance_id: @instance_id, database_id: @database_id, backup_schedule_id: @backup_schedule_id
    end
    expect(captured_output).to include "projects/#{@project_id}/instances/#{@instance_id}/databases/#{@database_id}/backupSchedules/#{@backup_schedule_id}"
  end

  example "List backup schedules" do
    capture do
      spanner_list_backup_schedules project_id: @project_id, instance_id: @instance_id, database_id: @database_id
    end
    expect(captured_output).to include "projects/#{@project_id}/instances/#{@instance_id}/databases/#{@database_id}"
  end

  example "Update backup schedules" do
    capture do
      spanner_update_backup_schedule project_id: @project_id, instance_id: @instance_id, database_id: @database_id, backup_schedule_id: @backup_schedule_id
    end
    expect(captured_output).to include "projects/#{@project_id}/instances/#{@instance_id}/databases/#{@database_id}/backupSchedules/#{@backup_schedule_id}"
  end

  example "Delete backup schedule" do
    capture do
      spanner_delete_backup_schedule project_id: @project_id, instance_id: @instance_id, database_id: @database_id, backup_schedule_id: @backup_schedule_id
    end
    expect(captured_output).to include "projects/#{@project_id}/instances/#{@instance_id}/databases/#{@database_id}/backupSchedules/#{@backup_schedule_id}"
  end
end
