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
require "google/cloud/spanner"
require "google/cloud/spanner/admin/instance"

def spanner_delete_instance_partition instance_partition_id:
  # instance_partition_id = "The instance partition's full name, e.g projects/{project}/instances/{instance}/instancePartitions/custom_nam11"

  instance_admin_client = Google::Cloud::Spanner::Admin::Instance.instance_admin
  instance_admin_client.delete_instance_partition name: instance_partition_id
  puts "Deleted instance partition #{instance_partition_id}"
end
# [END spanner_delete_instance_partition]

if $PROGRAM_NAME == __FILE__
  spanner_delete_instance_partition instance_partition_id: ARGV.shift
end
