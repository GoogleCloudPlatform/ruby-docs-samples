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

def request_tagging project_id:, instance_id:, database_id:
  # [START spanner_set_request_tag]
  # project_id  = "Your Google Cloud project ID"
  # instance_id = "Your Spanner instance ID"
  # database_id = "Your Spanner database ID"

  require "google/cloud/spanner"

  spanner = Google::Cloud::Spanner.new project: project_id
  client = spanner.client instance_id, database_id

  client.execute(
    "SELECT SingerId, AlbumId, MarketingBudget FROM Albums",
    request_options: { tag: "app=concert,env=dev,action=select" }
  ).rows.each do |row|
    puts "#{row[:SingerId]} #{row[:AlbumId]} #{row[:MarketingBudget]}"
  end

  # [END spanner_set_request_tag]
end

def transaction_tagging project_id:, instance_id:, database_id:
  # [START spanner_set_transaction_tag]
  # project_id  = "Your Google Cloud project ID"
  # instance_id = "Your Spanner instance ID"
  # database_id = "Your Spanner database ID"

  require "google/cloud/spanner"

  spanner = Google::Cloud::Spanner.new project: project_id
  client = spanner.client instance_id, database_id

  client.transaction request_options: { tag: "app=cart,env=dev" } do |tx|
    tx.execute_update \
      "UPDATE Venues SET Capacity = CAST(Capacity/4 AS INT64) WHERE OutdoorVenue = false",
      request_options: { tag: "app=concert,env=dev,action=update" }

    puts "Venue capacities updated."

    tx.execute_update \
      "INSERT INTO Venues (VenueId, VenueName, Capacity, OutdoorVenue) " \
      "VALUES (@venue_id, @venue_name, @capacity, @outdoor_venue)",
      params: {
        venue_id: 81,
        venue_name: "Venue 81",
        capacity: 1440,
        outdoor_venue: true
      },
      request_options: { tag: "app=concert,env=dev,action=insert" }

    puts "New venue inserted."
  end

  # [END spanner_set_transaction_tag]
end

def usage
  puts <<~USAGE
    Usage: bundle exec ruby tagging_samples.rb [command] [arguments]

    Commands:
      request_tagging      <instance_id> <database_id> Request tagging.
      transaction_tagging  <instance_id> <database_id> Transaction tagging.
    Environment variables:
      GOOGLE_CLOUD_PROJECT must be set to your Google Cloud project ID
  USAGE
end

def run_sample arguments
  commands = ["request_tagging", "transaction_tagging"]
  command = arguments.shift

  return usage unless commands.include? command

  run_command command, arguments, ENV["GOOGLE_CLOUD_PROJECT"]
end

run_sample ARGV if $PROGRAM_NAME == __FILE__
