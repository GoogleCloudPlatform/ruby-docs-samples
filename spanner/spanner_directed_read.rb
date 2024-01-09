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

# [START spanner_directed_read]
require "google/cloud/spanner"

##
# This is a snippet for showcasing how to pass in directed read options.
#
# @param project_id  [String] The ID of the Google Cloud project.
# @param instance_id [String] The ID of the spanner instance.
# @param database_id [String] The ID of the database.
#
def spanner_directed_read project_id:, instance_id:, database_id:
  # Only one of exclude_replicas or include_replicas can be set.
  # Each accepts a list of replica_selections which contains location and type
  #   * `location` - The location must be one of the regions within the
  #      multi-region configuration of your database.
  #   * `type` - The type of the replica
  # Some examples of using replicaSelectors are:
  #   * `location:us-east1` --> The "us-east1" replica(s) of any available type
  #                             will be used to process the request.
  #   * `type:READ_ONLY`    --> The "READ_ONLY" type replica(s) in the nearest
  # .                            available location will be used to process the
  #                             request.
  #   * `location:us-east1 type:READ_ONLY` --> The "READ_ONLY" type replica(s)
  #                          in location "us-east1" will be used to process
  #                          the request.
  #  include_replicas also contains an option for auto_failover_disabled. If set
  #  Spanner will not route requests to a replica outside the
  #  include_replicas list even if all the specified replicas are
  #  unavailable or unhealthy. The default value is `false`.
  directed_read_options_for_client = {
    include_replicas: {
      replica_selections: [{ location: "us-east4" }]
    }
  }

  # Instantiates a client with directedReadOptions
  spanner = Google::Cloud::Spanner.new project: project_id
  client  = spanner.client instance_id, database_id, directed_read_options: directed_read_options_for_client

  directed_read_options = {
    include_replicas: {
      replica_selections: [{ type: "READ_WRITE" }],
      auto_failover_disabled: true
    }
  }

  result = client.execute_sql "SELECT SingerId, AlbumId, AlbumTitle FROM Albums", directed_read_options: directed_read_options
  result.rows.each do |row|
    puts "SingerId: #{row[:SingerId]}"
    puts "AlbumId: #{row[:AlbumId]}"
    puts "AlbumTitle: #{row[:AlbumTitle]}"
  end
  puts "Successfully executed read-only transaction with directed_read_options"
end
# [END spanner_directed_read]
