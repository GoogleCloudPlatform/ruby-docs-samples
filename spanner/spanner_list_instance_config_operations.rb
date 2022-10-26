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

# [START spanner_list_instance_config_operations]
require "google/cloud/spanner"
require "google/cloud/spanner/admin/instance"

def spanner_list_instance_config_operations project_id:
  # project_id  = "Your Google Cloud project ID"

  instance_admin_client = Google::Cloud::Spanner::Admin::Instance.instance_admin
  project_path = instance_admin_client.project_path project: project_id

  jobs = instance_admin_client.list_instance_config_operations parent: project_path,
                                                               filter: "(metadata.@type=type.googleapis.com/google.spanner.admin.instance.v1.CreateInstanceConfigMetadata)"
  jobs.each do |job|
    puts "List instance config operations #{job.metadata.instance_config.name} is #{job.metadata.progress.progress_percent}% complete."
  end
end
# [END spanner_list_instance_config_operations]

if $PROGRAM_NAME == __FILE__
  spanner_list_instance_config_operations project_id: ARGV.shift
end
