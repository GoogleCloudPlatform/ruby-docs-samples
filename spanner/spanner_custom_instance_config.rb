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

def create_instance_config project_id:, instance_config_id:
  # [START spanner_create_instance_config]
  # project_id  = "Your Google Cloud project ID"
  # instance_config_id = "The customer managed instance configuration id. The id must start with 'custom-'"

  require "google/cloud/spanner"
  require "google/cloud/spanner/admin/instance"

  instance_admin_client = Google::Cloud::Spanner::Admin::Instance::V1::InstanceAdmin::Client.new do |config|
    # TODO: remove endpoint before GA
    config.endpoint = "staging-wrenchworks.sandbox.googleapis.com"
  end

  project_path = instance_admin_client.project_path project: project_id

  custom_instance_config_path = instance_admin_client.instance_config_path \
    project: project_id, instance_config: instance_config_id
  # Get a Google Managed instance configuration to use as the base for our custom instance configuration.
  # TODO: Update to an actual instance config.
  base_instance_config_path = instance_admin_client.instance_config_path \
    project: project_id, instance_config: "nam3-cmmr"
  base_instance_config = instance_admin_client.get_instance_config name: base_instance_config_path

  # To create user managed configurations, input
  # `replicas` must include all replicas in `replicas` of the `base_instance_config`
  # and include one or more replicas in the `optional_replicas` of the `base_instance_config`.
  custom_replicas = []
  base_instance_config.replicas.each do |replica|
    custom_replicas << replica
  end
  custom_replicas << base_instance_config.optional_replicas[0]
  custom_instance_config = {
    name: custom_instance_config_path,
    display_name: "Ruby test custom instance config",
    config_type: :USER_MANAGED,
    base_config: base_instance_config_path,
    replicas: custom_replicas,
  }
  request = {
    parent: project_path,
    instance_config_id: instance_config_id,
    instance_config: custom_instance_config
  }
  job = instance_admin_client.create_instance_config request

  puts "Waiting for create instance config operation to complete"

  job.wait_until_done!

  if job.error?
    puts job.error
  else
    puts "Created instance configuration #{instance_config_id}"
  end
  # [END spanner_create_instance_config]
end

def update_instance_config project_id:, instance_config_id:
  # [START spanner_update_instance_config]
  # project_id  = "Your Google Cloud project ID"
  # instance_config_id = "The customer managed instance configuration id. The id must start with 'custom-'"

  require "google/cloud/spanner"
  require "google/cloud/spanner/admin/instance"

  instance_admin_client = Google::Cloud::Spanner::Admin::Instance::V1::InstanceAdmin::Client.new do |config|
    # TODO: remove endpoint before GA
    config.endpoint = "staging-wrenchworks.sandbox.googleapis.com"
  end

  instance_config_path = instance_admin_client.instance_config_path \
    project: project_id, instance_config: instance_config_id
  config = instance_admin_client.get_instance_config name: instance_config_path

  labels_map = Google::Protobuf::Map.new(:string, :string)
  labels_map["cloud_spanner_samples"] = "true"
  labels_map["updates"] = "true"

  config.display_name = "Ruby test new display name custom instance config"
  config.labels = labels_map

  request = {
    instance_config: config,
    update_mask: { paths: ["display_name", "labels"] }
  }
  job = instance_admin_client.update_instance_config request

  puts "Waiting for update instance config operation to complete"

  job.wait_until_done!

  if job.error?
    puts job.error
  else
    puts "Updated instance configuration #{instance_config_id}"
  end
  # [END spanner_update_instance_config]
end

def delete_instance_config project_id:, instance_config_id:
  # [START spanner_delete_instance_config]
  # project_id  = "Your Google Cloud project ID"
  # instance_config_id = "The customer managed instance configuration id. The id must start with 'custom-'"

  require "google/cloud/spanner"
  require "google/cloud/spanner/admin/instance"

  instance_admin_client = Google::Cloud::Spanner::Admin::Instance::V1::InstanceAdmin::Client.new do |config|
    # TODO: remove endpoint before GA
    config.endpoint = "staging-wrenchworks.sandbox.googleapis.com"
  end

  instance_config_path = instance_admin_client.instance_config_path \
    project: project_id, instance_config: instance_config_id

  instance_admin_client.delete_instance_config name: instance_config_path
  puts "Deleted instance configuration #{instance_config_id}"
  # [END spanner_delete_instance_config]
end

def list_instance_config_operations project_id:
  # [START spanner_list_instance_config_operations]
  # project_id  = "Your Google Cloud project ID"

  require "google/cloud/spanner"
  require "google/cloud/spanner/admin/instance"

  instance_admin_client = Google::Cloud::Spanner::Admin::Instance::V1::InstanceAdmin::Client.new do |config|
    # TODO: remove endpoint before GA
    config.endpoint = "staging-wrenchworks.sandbox.googleapis.com"
  end

  project_path = instance_admin_client.project_path project: project_id
  jobs = instance_admin_client.list_instance_config_operations parent: project_path

  jobs.each do |job|
    puts "Instance config operation for #{job.metadata.instance_config.name} of type #{job.metadata.instance_config.config_type} has status #{job.done? ? 'done' : 'running'}."
  end
  # [END spanner_list_instance_config_operations]
end

def usage
  puts <<~USAGE
    Usage: bundle exec ruby spanner_custom_instance_config.rb [command] [arguments]

    Commands:
      create_instance_config                    <instance_config_id> Create a custom instance config, The id must start with 'custom-'
      update_instance_config                    <instance_config_id> Update the custom instance config, The id must start with 'custom-'
      delete_instance_config                    <instance_config_id> Delete the custom instance config, The id must start with 'custom-'
      list_instance_config_operations           List all the instance config operations

    Environment variables:
      GOOGLE_CLOUD_PROJECT must be set to your Google Cloud project ID
  USAGE
end

def run_sample arguments
  commands = [
    "create_instance_config", "update_instance_config", "delete_instance_config", "list_instance_config_operations",
  ]

  command = arguments.shift
  project_id = ENV["GOOGLE_CLOUD_PROJECT"]

  return usage unless commands.include? command

  sample_method = method command
  parameters = { project_id: project_id }

  sample_method.parameters.each do |paramater|
    next if paramater.last == :project_id
    parameters[paramater.last] = arguments.shift
  end

  sample_method.call(**parameters)
end

run_sample ARGV if $PROGRAM_NAME == __FILE__