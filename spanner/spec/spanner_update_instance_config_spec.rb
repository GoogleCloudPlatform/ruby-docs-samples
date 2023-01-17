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

require_relative "../spanner_create_instance_config"
require_relative "../spanner_update_instance_config"
require_relative "../spanner_delete_instance_config"
require_relative "./spec_helper"

describe "Spanner custom instance config" do
  after :each do
    @created_instance_config_ids.each do |user_config_id|
      spanner_delete_instance_config user_config_id:  user_config_id
    end
    @created_instance_config_ids.clear
  end

  example "Update" do
    base_config_id = instance_config_path("nam7")
    user_config = "custom-ruby-samples-config-#{SecureRandom.hex(8)}"
    spanner_create_instance_config project_id: @project_id,
                                   user_config_name: user_config,
                                   base_config_id: base_config_id
    @created_instance_config_ids << instance_config_path(user_config)

    capture do
      spanner_update_instance_config user_config_id: instance_config_path(user_config)
    end
    expect(captured_output).to include(
                                 "Updated instance configuration #{instance_config_path(user_config)}"
                               )
  end
end
