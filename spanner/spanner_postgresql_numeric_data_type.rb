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

# [START spanner_postgresql_numeric_data_type]
require "google/cloud/spanner"

def spanner_postgresql_numeric_data_type project_id:, instance_id:, database_id:
  # project_id  = "Your Google Cloud project ID"
  # instance_id = "Your Spanner instance ID"
  # database_id = "Your Spanner database ID"

  spanner = Google::Cloud::Spanner.new project: project_id
  client  = spanner.client instance_id, database_id

  # Fetch all singers whose rating is above 3
  results = client.execute "SELECT SingerId, FirstName, Rating FROM Singers WHERE Rating > $1",
                           params: { p1: BigDecimal(3) },
                           types: { p1: :PG_NUMERIC }

  results.rows.each do |row|
    puts "SingerId: #{row[:singerid]}"
    puts "FirstName: #{row[:firstname]}"

    # Converts a bigdecimal from scientific notation (0.36e1) to human-readable format (3.6)
    puts "Rating: #{row[:rating].to_s 'F'}"
  end
end
# [END spanner_postgresql_numeric_data_type]

if $PROGRAM_NAME == __FILE__
  spanner_postgresql_numeric_data_type project_id: ARGV.shift, instance_id: ARGV.shift, database_id: ARGV.shift
end
