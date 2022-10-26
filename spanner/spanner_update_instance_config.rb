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

# [START spanner_update_instance_config]
require "google/cloud/spanner"
require "google/cloud/spanner/admin/instance"

def spanner_update_instance_config user_config_id:
  # user_config_id = "The customer managed instance configuration ID, e.g projects/<project>/instanceConfigs/custom-nam11"

  instance_admin_client = Google::Cloud::Spanner::Admin::Instance.instance_admin
  config = instance_admin_client.get_instance_config name: user_config_id
  config.display_name = "updated custom instance config"
  config.labels["updated"] = "true"
  request = {
    instance_config: config,
    update_mask: { paths: ["display_name", "labels"] },
    validate_only: false
  }
  job = instance_admin_client.update_instance_config request

  puts "Waiting for update instance config operation to complete"

  job.wait_until_done!

  if job.error?
    puts job.error
  else
    puts "Updated instance configuration #{config.name}"
  end
end
# [END spanner_update_instance_config]

if $PROGRAM_NAME == __FILE__
  spanner_update_instance_config user_config_id: ARGV.shift
end
