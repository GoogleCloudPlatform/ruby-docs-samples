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

# [START spanner_create_instance_config]
require "google/cloud/spanner"
require "google/cloud/spanner/admin/instance"

def spanner_create_instance_config project_id:, user_config_name:, base_config_id:
  # project_id  = "Your Google Cloud project ID"
  # user_config_name = "Your custom instance configuration name, The name must start with 'custom-'"
  # base_config_id = "Base configuration ID to be used for creation, e.g projects/<project>/instanceConfigs/nam11"

  instance_admin_client = Google::Cloud::Spanner::Admin::Instance.instance_admin
  project_path = instance_admin_client.project_path project: project_id
  base_instance_config = instance_admin_client.get_instance_config name: base_config_id
  # The replicas for the custom instance configuration must include all the replicas of the base
  # configuration, in addition to at least one from the list of optional replicas of the base
  # configuration.
  custom_replicas = []
  base_instance_config.replicas.each do |replica|
    custom_replicas << replica
  end
  custom_replicas << base_instance_config.optional_replicas[0]
  custom_instance_config_id = instance_admin_client.instance_config_path \
    project: project_id, instance_config: user_config_name
  custom_instance_config = {
    name: custom_instance_config_id,
    display_name: "custom-ruby-samples",
    config_type: :USER_MANAGED,
    replicas: custom_replicas,
    base_config: base_config_id,
    labels: { ruby_cloud_spanner_samples: "true" }
  }
  request = {
    parent: project_path,
    # Custom config names must start with the prefix “custom-”.
    instance_config_id: user_config_name,
    instance_config: custom_instance_config
  }
  job = instance_admin_client.create_instance_config request

  puts "Waiting for create instance config operation to complete"

  job.wait_until_done!

  if job.error?
    puts job.error
  else
    puts "Created instance configuration #{user_config_name}"
  end
end
# [END spanner_create_instance_config]

if $PROGRAM_NAME == __FILE__
  spanner_create_instance_config project_id: ARGV.shift, user_config_name: ARGV.shift, base_config_id: ARGV.shift
end
