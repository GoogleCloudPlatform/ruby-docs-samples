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

def read_data project_id:, instance_id:, database_id:
  # [START read_data]
  # project_id  = "Your Google Cloud project ID"
  # instance_id = "Your Spanner instance ID"
  # database_id = "Your Spanner database ID"

  require "google/cloud/spanner"

  spanner = Google::Cloud::Spanner.new project: project_id
  client  = spanner.client instance_id, database_id

  client.read("Albums", [:SingerId, :AlbumId, :AlbumTitle]).rows.each do |row|
    puts "#{row[:SingerId]} #{row[:AlbumId]} #{row[:AlbumTitle]}"
  end
  # [END read_data]
end

def create_index project_id:, instance_id:, database_id:
  # [START create_index]
  # project_id  = "Your Google Cloud project ID"
  # instance_id = "Your Spanner instance ID"
  # database_id = "Your Spanner database ID"

  require "google/cloud/spanner"

  spanner  = Google::Cloud::Spanner.new project: project_id
  instance = spanner.instance instance_id
  database = instance.database database_id

  job = database.update statements: [
    "CREATE INDEX AlbumsByAlbumTitle ON Albums(AlbumTitle)"
  ]

  puts "Waiting for database update to complete"

  job.wait_until_done!

  puts "Added the AlbumsByAlbumTitle index"
  # [END create_index]
end

def create_storing_index project_id:, instance_id:, database_id:
  # [START create_storing_index]
  # project_id  = "Your Google Cloud project ID"
  # instance_id = "Your Spanner instance ID"
  # database_id = "Your Spanner database ID"

  require "google/cloud/spanner"

  spanner  = Google::Cloud::Spanner.new project: project_id
  instance = spanner.instance instance_id
  database = instance.database database_id

  job = database.update statements: [
    "CREATE INDEX AlbumsByAlbumTitle2 ON Albums(AlbumTitle) " +
    "STORING (MarketingBudget)"
  ]

  puts "Waiting for database update to complete"

  job.wait_until_done!

  puts "Added the AlbumsByAlbumTitle2 storing index"
  # [END create_storing_index]
end

def add_column project_id:, instance_id:, database_id:
  # [START add_column]
  # project_id  = "Your Google Cloud project ID"
  # instance_id = "Your Spanner instance ID"
  # database_id = "Your Spanner database ID"

  require "google/cloud/spanner"

  spanner  = Google::Cloud::Spanner.new project: project_id
  instance = spanner.instance instance_id
  database = instance.database database_id

  job = database.update statements: [
    "ALTER TABLE Albums ADD COLUMN MarketingBudget INT64"
  ]

  puts "Waiting for database update to complete"

  job.wait_until_done!

  puts "Added the MarketingBudget column"
  # [END add_column]
end

def update_data project_id:, instance_id:, database_id:
  # [START update_data]
  # project_id  = "Your Google Cloud project ID"
  # instance_id = "Your Spanner instance ID"
  # database_id = "Your Spanner database ID"

  require "google/cloud/spanner"

  spanner = Google::Cloud::Spanner.new project: project_id
  client  = spanner.client instance_id, database_id

  client.commit do |c|
    c.update "Albums", [
      { SingerId: "1", AlbumId: "1", MarketingBudget: "100000" },
      { SingerId: "2", AlbumId: "2", MarketingBudget: "500000" }
    ]
  end

  puts "Updated data"
  # [END update_data]
end

def query_data_with_index project_id:, instance_id:, database_id:
  # [START query_data_with_index]
  # project_id  = "Your Google Cloud project ID"
  # instance_id = "Your Spanner instance ID"
  # database_id = "Your Spanner database ID"

  require "google/cloud/spanner"

  spanner = Google::Cloud::Spanner.new project: project_id
  client  = spanner.client instance_id, database_id

  sql_query = 'SELECT AlbumId, AlbumTitle, MarketingBudget
               FROM Albums@{FORCE_INDEX=AlbumsByAlbumTitle}
               WHERE AlbumTitle >= "Aardvark" AND AlbumTitle < "Goo"'

  client.execute(sql_query).rows.each do |row|
    puts "#{row[:AlbumId]} #{row[:AlbumTitle]} #{row[:MarketingBudget]}"
  end
  # [END query_data_with_index]
end

def read_data_with_index project_id:, instance_id:, database_id:
  # [START read_data_with_index]
  # project_id  = "Your Google Cloud project ID"
  # instance_id = "Your Spanner instance ID"
  # database_id = "Your Spanner database ID"

  require "google/cloud/spanner"

  spanner = Google::Cloud::Spanner.new project: project_id
  client  = spanner.client instance_id, database_id

  result = client.read(
    "Albums",
    [:AlbumId, :AlbumTitle],
    index: "AlbumsByAlbumTitle"
  )

  result.rows.each do |row|
    puts "#{row[:AlbumId]} #{row[:AlbumTitle]}"
  end
  # [END read_data_with_index]
end

def read_data_with_storing_index project_id:, instance_id:, database_id:
  # [START read_data_with_storing_index]
  # project_id  = "Your Google Cloud project ID"
  # instance_id = "Your Spanner instance ID"
  # database_id = "Your Spanner database ID"

  require "google/cloud/spanner"

  spanner = Google::Cloud::Spanner.new project: project_id
  client  = spanner.client instance_id, database_id

  result = client.read(
    "Albums",
    [:AlbumId, :AlbumTitle, :MarketingBudget],
    index: "AlbumsByAlbumTitle2"
  )

  result.rows.each do |row|
    puts "#{row[:AlbumId]} #{row[:AlbumTitle]} #{row[:MarketingBudget]}"
  end
  # [END read_data_with_storing_index]
end

def read_only_transaction project_id:, instance_id:, database_id:
  # [START read_only_transaction]
  # project_id  = "Your Google Cloud project ID"
  # instance_id = "Your Spanner instance ID"
  # database_id = "Your Spanner database ID"

  require "google/cloud/spanner"

  spanner = Google::Cloud::Spanner.new project: project_id
  client  = spanner.client instance_id, database_id

  result = client.read(
    "Albums",
    [:SingerId, :AlbumId, :AlbumTitle],
    single_use: { strong: true }
  )

  result.rows.each do |row|
    puts "#{row[:SingerId]} #{row[:AlbumId]} #{row[:AlbumTitle]}"
  end
  # [END read_only_transaction]
end
