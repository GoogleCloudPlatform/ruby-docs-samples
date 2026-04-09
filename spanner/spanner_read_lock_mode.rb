# Copyright 2026 Google, Inc
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

# [START spanner_read_lock_mode]
require "google/cloud/spanner"

def spanner_read_lock_mode project_id:, instance_id:, database_id:
  # Instantiates a client with read_lock_mode: :OPTIMISTIC
  spanner = Google::Cloud::Spanner.new project: project_id
  client = spanner.client instance_id, database_id, read_lock_mode: :OPTIMISTIC

  # Overrides read_lock_mode to :PESSIMISTIC at transaction level
  client.transaction read_lock_mode: :PESSIMISTIC do |tx|
    results = tx.execute_query "SELECT AlbumTitle FROM Albums WHERE SingerId = 2 AND AlbumId = 1"

    results.rows.each do |row|
      puts "AlbumTitle: #{row[:AlbumTitle]}"
    end

    row_count = tx.execute_update "UPDATE Albums SET AlbumTitle = 'A New Title' WHERE SingerId = 2 AND AlbumId = 1"

    puts "#{row_count} records updated."
  end
end
# [END spanner_read_lock_mode]
