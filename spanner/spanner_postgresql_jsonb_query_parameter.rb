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

# [START spanner_postgresql_jsonb_query_parameter]
require "google/cloud/spanner"

def spanner_postgresql_jsonb_query_parameter project_id:, instance_id:, database_id:
  # project_id  = "Your Google Cloud project ID"
  # instance_id = "Your Spanner instance ID"
  # database_id = "Your Spanner database ID"
  spanner = Google::Cloud::Spanner.new project: project_id
  client  = spanner.client instance_id, database_id

  sql_query = <<~QUERY
    SELECT venueid, venuedetails
    FROM Venues
    WHERE CAST(venuedetails ->> 'rating' AS INTEGER) > $1
  QUERY

  # pass parameterized query's params represented by position
  results = client.execute sql_query, params: { p1: 5 }
  puts results.rows.first

  # Read JSONB value from table
  results = client.read "Venues", [:VenueId, :VenueDetails], keys: 19
  puts results.rows.first
end
# [END spanner_postgresql_jsonb_query_parameter]

if $PROGRAM_NAME == __FILE__
  spanner_postgresql_jsonb_query_parameter project_id: ARGV.shift, instance_id: ARGV.shift, database_id: ARGV.shift
end
