# Copyright 2017 Google, Inc
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

def create_database project_id:, instance_id:, database_id:
  # [START create_database]
  # project_id  = "Your Google Cloud project ID"
  # instance_id = "Your Spanner instance ID"
  # database_id = "Your Spanner database ID"

  require "google/cloud/spanner"

  spanner  = Google::Cloud::Spanner.new project: project_id
  instance = spanner.instance instance_id

  job = instance.create_database database_id, statements: [
    "CREATE TABLE Singers (
      SingerId     INT64 NOT NULL,
      FirstName    STRING(1024),
      LastName     STRING(1024),
      SingerInfo   BYTES(MAX)
    ) PRIMARY KEY (SingerId)",

    "CREATE TABLE Albums (
      SingerId     INT64 NOT NULL,
      AlbumId      INT64 NOT NULL,
      AlbumTitle   STRING(MAX)
    ) PRIMARY KEY (SingerId, AlbumId),
    INTERLEAVE IN PARENT Singers ON DELETE CASCADE"
  ]

  puts "Waiting for create database operation to complete"

  job.wait_until_done!

  puts "Created database #{database_id} on instance #{instance_id}"
  # [END create_database]
end

def insert_data project_id:, instance_id:, database_id:
  # [START insert_data]
  # project_id  = "Your Google Cloud project ID"
  # instance_id = "Your Spanner instance ID"
  # database_id = "Your Spanner database ID"

  require "google/cloud/spanner"

  spanner = Google::Cloud::Spanner.new project: project_id

  # Creates a Cloud Spanner client for your database.
  # A client is used to read and/or modify data in a Cloud Spanner database.
  # All of your interactions with Cloud Spanner data must go through a client.
  # Typically you create a client when your application starts up,
  # then you re-use that client to read, write, and execute transactions.
  client = spanner.client instance_id, database_id

  client.commit do |c|
    c.insert "Singers", [
      { SingerId: "1", FirstName: "Marc", LastName: "Richards" },
      { SingerId: "2", FirstName: "Catalina", LastName: "Smith" },
      { SingerId: "3", FirstName: "Alice", LastName: "Trentor" },
      { SingerId: "4", FirstName: "Lea", LastName: "Martin" },
      { SingerId: "5", FirstName: "David", LastName: "Lomond" }
    ]
    c.insert "Albums", [
      { SingerId: "1", AlbumId: "1", AlbumTitle: "Go, Go, Go" },
      { SingerId: "1", AlbumId: "2", AlbumTitle: "Total Junk" },
      { SingerId: "2", AlbumId: "1", AlbumTitle: "Green" },
      { SingerId: "2", AlbumId: "2", AlbumTitle: "Forever Hold your Peace" },
      { SingerId: "2", AlbumId: "3", AlbumTitle: "Terrified" }
    ]
  end

  puts "Inserted data"
  # [END insert_data]
end

def query_data project_id:, instance_id:, database_id:
  # [START query_data]
  # project_id  = "Your Google Cloud project ID"
  # instance_id = "Your Spanner instance ID"
  # database_id = "Your Spanner database ID"

  require "google/cloud/spanner"

  spanner = Google::Cloud::Spanner.new project: project_id
  client  = spanner.client instance_id, database_id

  client.execute("SELECT SingerId, AlbumId, AlbumTitle FROM Albums").rows.each do |row|
    puts "#{row[:SingerId]} #{row[:AlbumId]} #{row[:AlbumTitle]}"
  end
  # [END query_data]
end
