# Copyright 2022 Google LLC
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

require_relative "../spanner_custom_instance_config"
require_relative "./spec_helper"

describe "Spanner custom instance config" do

  after :each do
    @created_instance_config_ids.each do |instance_config_id|
      delete_instance_config project_id: @project_id, instance_config_id: instance_config_id
    end
    @created_instance_config_ids.clear
  end

  example "create custom instance_config" do
    instance_config_id = "custom-#{SecureRandom.hex(8)}"
    @created_instance_config_ids << instance_config_id

    capture do
      create_instance_config project_id: @project_id, instance_config_id: instance_config_id
    end

    expect(captured_output).to include(
                                 "Created instance configuration #{instance_config_id}"
                               )
  end

  example "update custom instance_config" do
    instance_config_id = "custom-#{SecureRandom.hex(8)}"
    @created_instance_config_ids << instance_config_id
    create_instance_config project_id: @project_id, instance_config_id: instance_config_id

    capture do
      update_instance_config project_id: @project_id, instance_config_id: instance_config_id
    end

    expect(captured_output).to include(
                                 "Updated instance configuration #{instance_config_id}"
                               )
  end

  example "delete custom instance config" do
    instance_config_id = "custom-#{SecureRandom.hex(8)}"
    @created_instance_config_ids << instance_config_id
    create_instance_config project_id: @project_id, instance_config_id: instance_config_id

    capture do
      delete_instance_config project_id: @project_id, instance_config_id: instance_config_id
    end

    expect(captured_output).to include(
                                 "Deleted instance configuration #{instance_config_id}"
                               )
  end

  example "list custom instance config operations" do
    capture do
      list_instance_config_operations project_id: @project_id
    end

    expect(captured_output).to include(
                                 "Instance config operation for"
                               )
  end
end
