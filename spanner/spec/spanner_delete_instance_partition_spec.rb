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

require_relative "../spanner_create_instance_partition"
require_relative "../spanner_delete_instance_partition"
require_relative "./spec_helper"

describe "Spanner custom instance partition" do
  example "Delete" do
    instance_partition_id = "custom-ruby-samples-instance-partition-#{SecureRandom.hex(8)}"
    spanner_create_instance_partition project_id: @project_id,
                                      instance_id: @instance_id,
                                      instance_partition_id: instance_partition_id

    name = instance_partition_path @instance_id, instance_partition_id

    capture do
      spanner_delete_instance_partition instance_partition_id: name
    end
    expect(captured_output).to include(
                                 "Deleted instance partition #{name}"
                               )
  end
end
