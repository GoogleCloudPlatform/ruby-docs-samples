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

require_relative "../tagging_samples"
require_relative "./spec_helper"

describe "Google Cloud Spanner tagging samples" do
  def create_database_with_data
    statements = [
      "CREATE TABLE Singers (
        SingerId     INT64 NOT NULL,
        FirstName    STRING(1024),
        LastName     STRING(1024),
        SingerInfo   BYTES(MAX)
      ) PRIMARY KEY (SingerId)",

      "CREATE TABLE Albums (
        SingerId     INT64 NOT NULL,
        AlbumId      INT64 NOT NULL,
        AlbumTitle   STRING(MAX),
        MarketingBudget INT64
      ) PRIMARY KEY (SingerId, AlbumId),
      INTERLEAVE IN PARENT Singers ON DELETE CASCADE",

      "CREATE TABLE Venues (
        VenueId         INT64 NOT NULL,
        VenueName       STRING(100),
        VenueInfo       BYTES(MAX),
        Capacity        INT64,
        OutdoorVenue    BOOL,
      ) PRIMARY KEY (VenueId)"
    ]

    @test_database = create_test_database @database_id, statements: statements

    client = @spanner.client @instance_id, @database_id
    client.commit do |c|
      c.insert "Singers", [
        { SingerId: 1, FirstName: "Marc", LastName: "Richards" },
      ]
      c.insert "Albums", [
        { SingerId: 1, AlbumId: 1, AlbumTitle: "Total Junk", MarketingBudget: 10_000 },
      ]
      c.insert "Venues", [
        {
          VenueId: 1, VenueName: "Venue 1", VenueInfo: StringIO.new("Hello World 1"),
          Capacity: 1_600, OutdoorVenue: true
        }
      ]
    end

    @test_databas
  end

  before :each do
    cleanup_database_resources
    create_database_with_data
  end

  after :each do
    cleanup_database_resources
  end

  example "request_tagging" do
    capture do
      request_tagging project_id: @project_id,
                      instance_id: @instance_id,
                      database_id: @database_id
    end


    expect(captured_output).to include "1 1 10000"
  end

  example "transaction_tagging" do
    capture do
      transaction_tagging project_id: @project_id,
                          instance_id: @instance_id,
                          database_id: @database_id
    end


    expect(captured_output).to include "Venue capacities updated."
    expect(captured_output).to include "New venue inserted."
  end
end