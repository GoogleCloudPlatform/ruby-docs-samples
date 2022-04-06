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

# [START spanner_postgresql_order_nulls]
require "google/cloud/spanner"

def spanner_postgresql_order_nulls project_id:, instance_id:, database_id:
  # project_id  = "Your Google Cloud project ID"
  # instance_id = "Your Spanner instance ID"
  # database_id = "Your Spanner database ID"

  spanner = Google::Cloud::Spanner.new project: project_id
  client  = spanner.client instance_id, database_id

  row_counts = nil
  client.transaction do |transaction|
    row_counts = transaction.batch_update do |b|
      b.batch_update "INSERT INTO Singers (SingerId, FirstName) VALUES (51, 'Alice')"
      b.batch_update "INSERT INTO Singers (SingerId, FirstName) VALUES (52, 'Bruce')"
      b.batch_update "INSERT INTO Singers (SingerId, FirstName) VALUES ($1, $2)",
                     params: { p1: 53, p2: nil },
                     types: { p2: :STRING }
    end
  end

  # Spanner PostgreSQL follows the ORDER BY rules for NULL values of PostgreSQL. This means
  # that:
  # 1. NULL values are ordered last by default when a query result is ordered in ascending
  #    order.
  # 2. NULL values are ordered first by default when a query result is ordered in descending
  #    order.
  # 3. NULL values can be ordered first or last by specifying NULLS FIRST or NULLS LAST in the
  #    ORDER BY clause.

  ordered_names = []
  # This returns the singers in order Alice, Bruce, nil
  results = client.execute "SELECT FirstName FROM Singers ORDER BY FirstName"
  results.rows.each do |row|
    ordered_names << row[:firstname]
  end
  puts "Result 1: #{ordered_names}"

  ordered_names = []
  # This returns the singers in order nil, Bruce, Alice
  results = client.execute "SELECT FirstName FROM Singers ORDER BY FirstName DESC"
  results.rows.each do |row|
    ordered_names << row[:firstname]
  end
  puts "Result 2: #{ordered_names}"

  ordered_names = []
  # This returns the singers in order nil, Alice, Bruce
  results = client.execute "SELECT FirstName FROM Singers ORDER BY FirstName NULLS FIRST"
  results.rows.each do |row|
    ordered_names << row[:firstname]
  end
  puts "Result 3: #{ordered_names}"

  ordered_names = []
  # This returns the singers in order Alice, ̉Bruce, nil
  results = client.execute "SELECT FirstName FROM Singers ORDER BY FirstName NULLS LAST"
  results.rows.each do |row|
    ordered_names << row[:firstname]
  end
  puts "Result 4: #{ordered_names}"
end
# [END spanner_postgresql_order_nulls]

if $PROGRAM_NAME == __FILE__
  spanner_postgresql_order_nulls project_id: ARGV.shift, instance_id: ARGV.shift, database_id: ARGV.shift
end
