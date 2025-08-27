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

# [START spanner_delete_instance_partition]
def spanner_delete_instance_partition project_id:, instance_id:, instance_partition_id:
  # project_id  = "Your Google Cloud project ID"
  # instance_id = "Your Spanner instance ID"
  # instance_partition_id = "Your Spanner instance partition ID"

  require "google/cloud/spanner/admin/instance"

  instance_admin_client = Google::Cloud::Spanner::Admin::Instance.instance_admin

  instance_partition_path = instance_admin_client.instance_partition_path \
    project: project_id,
    instance: instance_id,
    instance_partition: instance_partition_id

  instance_admin_client.delete_instance_partition name: instance_partition_path

  puts "Deleted instance partition #{instance_partition_id}"
end
# [END spanner_delete_instance_partition]

if $PROGRAM_NAME == __FILE__
  spanner_delete_instance_partition project_id: ARGV.shift,
                                    instance_id: ARGV.shift,
                                    instance_partition_id: ARGV.shift
end
