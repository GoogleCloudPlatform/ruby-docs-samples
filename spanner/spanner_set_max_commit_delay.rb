# Copyright 2024 Google, Inc
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

# [START spanner_set_max_commit_delay]
require "google/cloud/spanner"

##
# This is a snippet for showcasing how to pass max_commit_delay in  commit_options.
#
# @param project_id  [String] The ID of the Google Cloud project.
# @param instance_id [String] The ID of the spanner instance.
# @param database_id [String] The ID of the database.
#
def spanner_set_max_commit_delay project_id:, instance_id:, database_id:
  # Instantiates a client
  spanner = Google::Cloud::Spanner.new project: project_id
  client  = spanner.client instance_id, database_id

  records = [
    { SingerId: 1, AlbumId: 1, MarketingBudget: 200_000 },
    { SingerId: 2, AlbumId: 2, MarketingBudget: 400_000 }
  ]
  # max_commit_delay is the amount of latency in millisecond, this request
  # is willing to incur in order to improve throughput.
  # The commit delay must be at least 0ms and at most 500ms.
  # Default value is nil.
  commit_options = {
    return_commit_stats: true,
    max_commit_delay: 100
  }
  resp = client.upsert "Albums", records, commit_options: commit_options
  puts "Updated data with #{resp.stats.mutation_count} mutations."
end
# [END spanner_set_max_commit_delay]
