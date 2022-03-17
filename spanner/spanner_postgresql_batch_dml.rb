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

# [START spanner_postgresql_batch_dml]
require "google/cloud/spanner"

def postgresql_batch_dml project_id:, instance_id:, database_id:
  # project_id  = "Your Google Cloud project ID"
  # instance_id = "Your Spanner instance ID"
  # database_id = "Your Spanner database ID"

  spanner = Google::Cloud::Spanner.new project: project_id
  client  = spanner.client instance_id, database_id

  row_counts = nil
  client.transaction do |transaction|
    row_counts = transaction.batch_update do |b|
      b.batch_update "INSERT INTO Singers (SingerId, FirstName, LastName) VALUES ($1, $2, $3)",
                     params: { p1: 3, p2: "Olivia", p3: "Garcia" }
    end
  end

  statement_count = row_counts.count

  puts "Executed #{statement_count} SQL statements using Batch DML."
end
# [END spanner_postgresql_batch_dml]

if $PROGRAM_NAME == __FILE__
  postgresql_batch_dml project_id: ARGV.shift, instance_id: ARGV.shift, database_id: ARGV.shift
end
