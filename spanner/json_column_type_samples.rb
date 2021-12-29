# Copyright 2021 Google LLC
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

require_relative "./utils"

def add_json_column project_id:, instance_id:, database_id:
  # [START spanner_add_json_column]
  # project_id  = "Your Google Cloud project ID"
  # instance_id = "Your Spanner instance ID"
  # database_id = "Your Spanner database ID"

  require "google/cloud/spanner"
  require "google/cloud/spanner/admin/database"

  db_admin_client = Google::Cloud::Spanner::Admin::Database.database_admin

  database_path = db_admin_client.database_path project: project_id,
                                                instance: instance_id,
                                                database: database_id

  statements = ["ALTER TABLE Venues ADD COLUMN VenueDetails JSON"]
  job = db_admin_client.update_database_ddl database: database_path,
                                            statements: statements
  job.wait_until_done!

  puts "Added VenueDetails column to Venues table in database #{database_id}"
  # [END spanner_add_json_column]
end

def update_data_with_json_column project_id:, instance_id:, database_id:
  # [START spanner_update_data_with_json_column]
  # project_id  = "Your Google Cloud project ID"
  # instance_id = "Your Spanner instance ID"
  # database_id = "Your Spanner database ID"

  require "google/cloud/spanner"

  spanner = Google::Cloud::Spanner.new project: project_id
  client  = spanner.client instance_id, database_id

  rows = [{
    VenueId: 1,
    VenueDetails: { rating: 9, open: true }
  }]
  client.update "Venues", rows

  # VenueDetails must be specified as a string, as it contains a top-level
  # array of objects that should be inserted into a JSON column. If we were
  # to specify this value as an array instead of a string, the client
  # library would encode this value as ARRAY<JSON> instead of JSON.
  venue_details_string = [
    {
      name: "room 1",
      open: true
    },
    {
      name: "room 2",
      open: false
    }
  ].to_json

  rows = [{
    VenueId: 2,
    VenueDetails: venue_details_string
  }]
  client.update "Venues", rows

  puts "Rows are updated."
  # [END spanner_update_data_with_json_column]
end

def query_with_json_params project_id:, instance_id:, database_id:
  # [START spanner_query_with_json_parameter]
  # project_id  = "Your Google Cloud project ID"
  # instance_id = "Your Spanner instance ID"
  # database_id = "Your Spanner database ID"

  require "google/cloud/spanner"

  spanner = Google::Cloud::Spanner.new project: project_id
  client = spanner.client instance_id, database_id

  query = "SELECT VenueId, VenueDetails FROM Venues
    WHERE JSON_VALUE(VenueDetails, '$.rating') = JSON_VALUE(@details, '$.rating')"
  result = client.execute_query query,
                                params: { details: { rating: 9 } },
                                types: { details: :JSON }

  result.rows.each do |row|
    puts "VenueId: #{row['VenueId']}, VenueDetails: #{row['VenueDetails']}"
  end
  # [END spanner_query_with_json_parameter]
end

def usage
  puts <<~USAGE
    Usage: bundle exec ruby json_column_type_samples.rb [command] [arguments]

    Commands:
      add_json_column               <instance_id> <database_id> Add JSON column to table.
      update_data_with_json_column  <instance_id> <database_id> Updates rows JSON field value.
      query_with_json_params        <instance_id> <database_id> Query data using JSON datatype.

    Environment variables:
      GOOGLE_CLOUD_PROJECT must be set to your Google Cloud project ID
  USAGE
end

def run_sample arguments
  commands = [
    "add_json_column", "update_data_with_json_column", "query_with_json_params"
  ]
  command = arguments.shift

  return usage unless commands.include? command

  run_command command, arguments, ENV["GOOGLE_CLOUD_PROJECT"]
end

run_sample ARGV if $PROGRAM_NAME == __FILE__
