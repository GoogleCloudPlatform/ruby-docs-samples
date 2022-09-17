# Copyright 2022 Google, Inc
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

# [START spanner_enable_fine_grained_access]
require "google/cloud/spanner"

def spanner_enable_fine_grained_access project_id:, instance_id:, database_id:, iam_member:, database_role:, title:
  # project_id  = "Your Google Cloud project ID"
  # instance_id = "Your Spanner instance ID"
  # database_id = "Your Spanner database ID"
  # iam_member = "user:alice@example.com"
  # database_role = "new_parent"
  # title = "condition title"

  admin_client = Google::Cloud::Spanner::Admin::Database::V1::DatabaseAdmin::Client.new
  db_path = admin_client.database_path project: project_id, instance: instance_id, database: database_id

  policy = admin_client.get_iam_policy resource: db_path, options: { requested_policy_version: 3 }

  policy.version = 3 if policy.version < 3

  binding = Google::Iam::V1::Binding.new(
    role: "roles/spanner.fineGrainedAccessUser",
    members: [iam_member],
    condition: Google::Type::Expr.new(
      title: title,
      expression: "resource.name.endsWith('/databaseRoles/#{database_role}')"
    )
  )

  policy.bindings << binding
  result = admin_client.set_iam_policy resource: db_path, policy: policy

  puts "Enabled fine-grained access in IAM."
end
# [END spanner_enable_fine_grained_access]

if $PROGRAM_NAME == __FILE__
  spanner_enable_fine_grained_access project_id: ARGV.shift, instance_id: ARGV.shift, database_id: ARGV.shift
end
