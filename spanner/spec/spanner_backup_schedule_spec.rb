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

require_relative "./spec_helper"
<<<<<<< HEAD
require_relative "../spanner_create_full_backup_schedule_config"
require_relative "../spanner_create_incremental_backup_schedule_config"
require_relative "../spanner_delete_backup_schedule_config"

describe "Spanner schedule for backups" do
  project_id = @project_id
  instance_id = @instance_id
  database_id = @database_id
  backup_schedule_id = @backup_schedule_id
  backup_schedule_name = "#{project_id}_#{instance_id}_#{database_id}_#{backup_schedule_id}"

  example "Create full backup schedule" do        
    capture do
      spanner_create_full_backup_schedule project_id: project_id, instance_id: instance_id, database_id: database_id, backup_schedule_id: backup_schedule_id
    end
    expect(captured_output).to include "Created full backup schedule for #{backup_schedule_name}"
  end

  example "Create incremental backup schedule" do
    capture do
      spanner_create_incremental_backup_schedule project_id: project_id, instance_id: instance_id, database_id: database_id, backup_schedule_id: backup_schedule_id
    end
    expect(captured_output).to include "Created incremental backup schedule for #{backup_schedule_name}"
  end

  example "Delete backup schedule" do
    capture do
      spanner_delete_backup_schedule project_id: project_id, instance_id: instance_id, database_id: database_id, backup_schedule_id: backup_schedule_id
    end
    expect(captured_output).to include "Deleted backup schedule for #{backup_schedule_name}"
=======
require_relative "../spanner_create_backup_schedule_config"
require_relative "../spanner_delete_backup_schedule_config"
require_relative "../spanner_get_backup_schedule_config"
require_relative "../spanner_list_backup_schedules_config"
require_relative "../spanner_update_backup_schedule_config"

describe "Spanner schedule for backups:" do
  example "Create backup schedule" do 
    capture do
      spanner_create_backup_schedule project_id: @project_id, instance_id: @instance_id, database_id: @database_id, backup_schedule_id: @backup_schedule_id
    end
    expect(captured_output).to include "projects/#{@project_id}/instances/#{@instance_id}/databases/#{@database_id}/backupSchedules/#{@backup_schedule_id}"
>>>>>>> 886cdfcf (This PR adds code samples for the following APIs:)
  end

  example "Get backup schedule" do
    capture do
<<<<<<< HEAD
      spanner_get_backup_schedule project_id: project_id, instance_id: instance_id, database_id: database_id, backup_schedule_id: backup_schedule_id
    end
    expect(captured_output).to include "Backup schedule: #{backup_schedule_name}"
=======
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
>>>>>>> 886cdfcf (This PR adds code samples for the following APIs:)
  end
end
