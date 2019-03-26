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
  # [START spanner_create_database]
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
  # [END spanner_create_database]
end

def create_table_with_timestamp_column project_id:, instance_id:, database_id:
  # [START spanner_create_table_with_timestamp_column]
  # project_id  = "Your Google Cloud project ID"
  # instance_id = "Your Spanner instance ID"
  # database_id = "Your Spanner database ID"

  require "google/cloud/spanner"

  spanner = Google::Cloud::Spanner.new project: project_id
  client  = spanner.database instance_id, database_id

  job = client.update statements: [
    "CREATE TABLE Performances (
      SingerId     INT64 NOT NULL,
      VenueId      INT64 NOT NULL,
      EventDate    Date,
      Revenue      INT64,
      LastUpdateTime TIMESTAMP NOT NULL OPTIONS (allow_commit_timestamp=true)
     ) PRIMARY KEY (SingerId, VenueId, EventDate),
     INTERLEAVE IN PARENT Singers ON DELETE CASCADE"
  ]

  puts "Waiting for update database operation to complete"

  job.wait_until_done!

  puts "Created table Performances in #{database_id}"
  # [END spanner_create_table_with_timestamp_column]
end

def insert_data project_id:, instance_id:, database_id:
  # [START spanner_insert_data]
  # project_id  = "Your Google Cloud project ID"
  # instance_id = "Your Spanner instance ID"
  # database_id = "Your Spanner database ID"

  require "google/cloud/spanner"

  spanner = Google::Cloud::Spanner.new project: project_id
  client  = spanner.client instance_id, database_id

  client.commit do |c|
    c.insert "Singers", [
      { SingerId: 1, FirstName: "Marc",     LastName: "Richards" },
      { SingerId: 2, FirstName: "Catalina", LastName: "Smith"    },
      { SingerId: 3, FirstName: "Alice",    LastName: "Trentor"  },
      { SingerId: 4, FirstName: "Lea",      LastName: "Martin"   },
      { SingerId: 5, FirstName: "David",    LastName: "Lomond"   }
    ]
    c.insert "Albums", [
      { SingerId: 1, AlbumId: 1, AlbumTitle: "Total Junk"              },
      { SingerId: 1, AlbumId: 2, AlbumTitle: "Go, Go, Go"              },
      { SingerId: 2, AlbumId: 1, AlbumTitle: "Green"                   },
      { SingerId: 2, AlbumId: 2, AlbumTitle: "Forever Hold Your Peace" },
      { SingerId: 2, AlbumId: 3, AlbumTitle: "Terrified"               }
    ]
  end

  puts "Inserted data"
  # [END spanner_insert_data]
end

def insert_data_with_timestamp_column project_id:, instance_id:, database_id:
  # [START spanner_insert_data_with_timestamp_column]
  # project_id  = "Your Google Cloud project ID"
  # instance_id = "Your Spanner instance ID"
  # database_id = "Your Spanner database ID"

  require "google/cloud/spanner"

  spanner = Google::Cloud::Spanner.new project: project_id
  client  = spanner.client instance_id, database_id

  # Get commit_timestamp
  commit_timestamp = client.commit_timestamp

  client.commit do |c|
    c.insert "Performances", [
      { SingerId: 1, VenueId: 4, EventDate: "2017-10-05", Revenue: 11_000, LastUpdateTime: commit_timestamp },
      { SingerId: 1, VenueId: 19, EventDate: "2017-11-02", Revenue: 15_000, LastUpdateTime: commit_timestamp },
      { SingerId: 2, VenueId: 42, EventDate: "2017-12-23", Revenue: 7000, LastUpdateTime: commit_timestamp }
    ]
  end

  puts "Inserted data"
  # [END spanner_insert_data_with_timestamp_column]
end

def query_data project_id:, instance_id:, database_id:
  # [START spanner_query_data]
  # project_id  = "Your Google Cloud project ID"
  # instance_id = "Your Spanner instance ID"
  # database_id = "Your Spanner database ID"

  require "google/cloud/spanner"

  spanner = Google::Cloud::Spanner.new project: project_id
  client  = spanner.client instance_id, database_id

  client.execute("SELECT SingerId, AlbumId, AlbumTitle FROM Albums").rows.each do |row|
    puts "#{row[:SingerId]} #{row[:AlbumId]} #{row[:AlbumTitle]}"
  end
  # [END spanner_query_data]
end

def query_data_with_timestamp_column project_id:, instance_id:, database_id:
  # [START spanner_query_data_with_timestamp_column]
  # project_id  = "Your Google Cloud project ID"
  # instance_id = "Your Spanner instance ID"
  # database_id = "Your Spanner database ID"

  require "google/cloud/spanner"

  spanner = Google::Cloud::Spanner.new project: project_id
  client  = spanner.client instance_id, database_id

  client.execute("SELECT SingerId, AlbumId, MarketingBudget, LastUpdateTime
                  FROM Albums ORDER BY LastUpdateTime DESC").rows.each do |row|
    puts "#{row[:SingerId]} #{row[:AlbumId]} #{row[:MarketingBudget]} #{row[:LastUpdateTime]}"
  end
  # [END spanner_query_data_with_timestamp_column]
end

def read_data project_id:, instance_id:, database_id:
  # [START spanner_read_data]
  # project_id  = "Your Google Cloud project ID"
  # instance_id = "Your Spanner instance ID"
  # database_id = "Your Spanner database ID"

  require "google/cloud/spanner"

  spanner = Google::Cloud::Spanner.new project: project_id
  client  = spanner.client instance_id, database_id

  client.read("Albums", [:SingerId, :AlbumId, :AlbumTitle]).rows.each do |row|
    puts "#{row[:SingerId]} #{row[:AlbumId]} #{row[:AlbumTitle]}"
  end
  # [END spanner_read_data]
end

def read_stale_data project_id:, instance_id:, database_id:
  # [START spanner_read_stale_data]
  # project_id  = "Your Google Cloud project ID"
  # instance_id = "Your Spanner instance ID"
  # database_id = "Your Spanner database ID"
  require "google/cloud/spanner"

  spanner = Google::Cloud::Spanner.new project: project_id
  client  = spanner.client instance_id, database_id

  # Perform a read with a data staleness of 15 seconds
  client.snapshot staleness: 15 do |snapshot|
    snapshot.read("Albums", [:SingerId, :AlbumId, :AlbumTitle]).rows.each do |row|
      puts "#{row[:SingerId]} #{row[:AlbumId]} #{row[:AlbumTitle]}"
    end
  end
  # [END spanner_read_stale_data]
end

def create_index project_id:, instance_id:, database_id:
  # [START spanner_create_index]
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
  # [END spanner_create_index]
end

def create_storing_index project_id:, instance_id:, database_id:
  # [START spanner_create_storing_index]
  # project_id  = "Your Google Cloud project ID"
  # instance_id = "Your Spanner instance ID"
  # database_id = "Your Spanner database ID"

  require "google/cloud/spanner"

  spanner  = Google::Cloud::Spanner.new project: project_id
  instance = spanner.instance instance_id
  database = instance.database database_id

  job = database.update statements: [
    "CREATE INDEX AlbumsByAlbumTitle2 ON Albums(AlbumTitle)
     STORING (MarketingBudget)"
  ]

  puts "Waiting for database update to complete"

  job.wait_until_done!

  puts "Added the AlbumsByAlbumTitle2 storing index"
  # [END spanner_create_storing_index]
end

def add_column project_id:, instance_id:, database_id:
  # [START spanner_add_column]
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
  # [END spanner_add_column]
end

def add_timestamp_column project_id:, instance_id:, database_id:
  # [START spanner_add_timestamp_column]
  # project_id  = "Your Google Cloud project ID"
  # instance_id = "Your Spanner instance ID"
  # database_id = "Your Spanner database ID"

  require "google/cloud/spanner"

  spanner  = Google::Cloud::Spanner.new project: project_id
  instance = spanner.instance instance_id
  database = instance.database database_id

  job = database.update statements: [
    "ALTER TABLE Albums ADD COLUMN LastUpdateTime TIMESTAMP
     OPTIONS (allow_commit_timestamp=true)"
  ]

  puts "Waiting for database update to complete"

  job.wait_until_done!

  puts "Added the LastUpdateTime as a commit timestamp column in Albums table"
  # [END spanner_add_timestamp_column]
end

def write_struct_data project_id:, instance_id:, database_id:
  # [START spanner_write_data_for_struct_queries]
  # project_id  = "Your Google Cloud project ID"
  # instance_id = "Your Spanner instance ID"
  # database_id = "Your Spanner database ID"

  require "google/cloud/spanner"

  spanner = Google::Cloud::Spanner.new project: project_id
  client  = spanner.client instance_id, database_id

  client.commit do |c|
    c.insert "Singers", [
      { SingerId: 6, FirstName: "Elena",    LastName: "Campbell" },
      { SingerId: 7, FirstName: "Gabriel",  LastName: "Wright"    },
      { SingerId: 8, FirstName: "Benjamin", LastName: "Martinez"  },
      { SingerId: 9, FirstName: "Hannah",   LastName: "Harris" }
    ]
  end
  puts "Inserted Data for Struct queries"
  # [END spanner_write_data_for_struct_queries]
end

def query_with_struct project_id:, instance_id:, database_id:
  # [START spanner_create_struct_with_data]
  name_struct = { FirstName: "Elena", LastName: "Campbell" }
  # [END spanner_create_struct_with_data]

  # [START spanner_query_data_with_struct]
  # project_id  = "Your Google Cloud project ID"
  # instance_id = "Your Spanner instance ID"
  # database_id = "Your Spanner database ID"

  require "google/cloud/spanner"

  spanner = Google::Cloud::Spanner.new project: project_id
  client  = spanner.client instance_id, database_id
  client.execute(
    "SELECT SingerId FROM Singers WHERE " +
    "(FirstName, LastName) = @name",
    params: { name: name_struct }
  ).rows.each do |row|
    puts row[:SingerId].to_s
  end
  # [END spanner_query_data_with_struct]
end

def query_with_array_of_struct project_id:, instance_id:, database_id:
  # project_id  = "Your Google Cloud project ID"
  # instance_id = "Your Spanner instance ID"
  # database_id = "Your Spanner database ID"

  require "google/cloud/spanner"

  spanner = Google::Cloud::Spanner.new project: project_id
  client  = spanner.client instance_id, database_id

  # [START spanner_create_user_defined_struct]
  name_type = client.fields FirstName: :STRING, LastName: :STRING
  # [END spanner_create_user_defined_struct]

  # [START spanner_create_array_of_struct_with_data]
  band_members = [name_type.struct(["Elena", "Campbell"]),
                  name_type.struct(["Gabriel", "Wright"]),
                  name_type.struct(["Benjamin", "Martinez"])]
  # [END spanner_create_array_of_struct_with_data]

  # [START spanner_query_data_with_array_of_struct]
  client.execute(
    "SELECT SingerId FROM Singers WHERE " +
    "STRUCT<FirstName STRING, LastName STRING>(FirstName, LastName) IN UNNEST(@names)",
    params: { names: band_members }
  ).rows.each do |row|
    puts row[:SingerId].to_s
  end
  # [END spanner_query_data_with_array_of_struct]
end

def query_struct_field project_id:, instance_id:, database_id:
  # [START spanner_field_access_on_struct_parameters]
  # project_id  = "Your Google Cloud project ID"
  # instance_id = "Your Spanner instance ID"
  # database_id = "Your Spanner database ID"

  require "google/cloud/spanner"

  spanner = Google::Cloud::Spanner.new project: project_id
  client  = spanner.client instance_id, database_id

  name_struct = { FirstName: "Elena", LastName: "Campbell" }
  client.execute(
    "SELECT SingerId FROM Singers WHERE FirstName = @name.FirstName",
    params: { name: name_struct }
  ).rows.each do |row|
    puts row[:SingerId].to_s
  end
  # [END spanner_field_access_on_struct_parameters]
end

def query_nested_struct_field project_id:, instance_id:, database_id:
  # [START spanner_field_access_on_nested_struct_parameters]
  # project_id  = "Your Google Cloud project ID"
  # instance_id = "Your Spanner instance ID"
  # database_id = "Your Spanner database ID"

  require "google/cloud/spanner"

  spanner = Google::Cloud::Spanner.new project: project_id
  client  = spanner.client instance_id, database_id

  name_type = client.fields FirstName: :STRING, LastName: :STRING

  song_info_struct = {
    SongName:    "Imagination",
    ArtistNames: [name_type.struct(["Elena", "Campbell"]), name_type.struct(["Hannah", "Harris"])]
  }

  client.execute(
    "SELECT SingerId, @song_info.SongName " +
    "FROM Singers WHERE STRUCT<FirstName STRING, LastName STRING>(FirstName, LastName) " +
    "IN UNNEST(@song_info.ArtistNames)",
    params: { song_info: song_info_struct }
  ).rows.each do |row|
    puts (row[:SingerId]).to_s, (row[:SongName]).to_s
  end
  # [END spanner_field_access_on_nested_struct_parameters]
end

def update_data project_id:, instance_id:, database_id:
  # [START spanner_update_data]
  # project_id  = "Your Google Cloud project ID"
  # instance_id = "Your Spanner instance ID"
  # database_id = "Your Spanner database ID"

  require "google/cloud/spanner"

  spanner = Google::Cloud::Spanner.new project: project_id
  client  = spanner.client instance_id, database_id

  client.commit do |c|
    c.update "Albums", [
      { SingerId: 1, AlbumId: 1, MarketingBudget: 100_000 },
      { SingerId: 2, AlbumId: 2, MarketingBudget: 500_000 }
    ]
  end

  puts "Updated data"
  # [END spanner_update_data]
end

def update_data_with_timestamp_column project_id:, instance_id:, database_id:
  # [START spanner_update_data_with_timestamp_column]
  # project_id  = "Your Google Cloud project ID"
  # instance_id = "Your Spanner instance ID"
  # database_id = "Your Spanner database ID"

  require "google/cloud/spanner"

  spanner = Google::Cloud::Spanner.new project: project_id
  client  = spanner.client instance_id, database_id

  commit_timestamp = client.commit_timestamp

  client.commit do |c|
    c.update "Albums", [
      { SingerId: 1, AlbumId: 1, MarketingBudget: 100_000, LastUpdateTime: commit_timestamp },
      { SingerId: 2, AlbumId: 2, MarketingBudget: 750_000, LastUpdateTime: commit_timestamp }
    ]
  end

  puts "Updated data"
  # [END spanner_update_data_with_timestamp_column]
end

def query_data_with_new_column project_id:, instance_id:, database_id:
  # [START spanner_query_data_with_new_column]
  # project_id  = "Your Google Cloud project ID"
  # instance_id = "Your Spanner instance ID"
  # database_id = "Your Spanner database ID"

  require "google/cloud/spanner"

  spanner = Google::Cloud::Spanner.new project: project_id
  client  = spanner.client instance_id, database_id

  client.execute("SELECT SingerId, AlbumId, MarketingBudget FROM Albums").rows.each do |row|
    puts "#{row[:SingerId]} #{row[:AlbumId]} #{row[:MarketingBudget]}"
  end
  # [END spanner_query_data_with_new_column]
end

def read_write_transaction project_id:, instance_id:, database_id:
  # [START spanner_read_write_transaction]
  # project_id  = "Your Google Cloud project ID"
  # instance_id = "Your Spanner instance ID"
  # database_id = "Your Spanner database ID"

  require "google/cloud/spanner"

  spanner = Google::Cloud::Spanner.new project: project_id
  client  = spanner.client instance_id, database_id

  client.transaction do |transaction|
    first_album  = transaction.read("Albums", [:MarketingBudget], keys: [[1, 1]]).rows.first
    second_album = transaction.read("Albums", [:MarketingBudget], keys: [[2, 2]]).rows.first

    raise "The second album does not have enough funds to transfer" if second_album[:MarketingBudget] < 300_000

    new_first_album_budget  = first_album[:MarketingBudget] + 200_000
    new_second_album_budget = second_album[:MarketingBudget] - 200_000

    transaction.update "Albums", [
      { SingerId: 1, AlbumId: 1, MarketingBudget: new_first_album_budget  },
      { SingerId: 2, AlbumId: 2, MarketingBudget: new_second_album_budget }
    ]
  end

  puts "Transaction complete"
  # [END spanner_read_write_transaction]
end

def query_data_with_index project_id:, instance_id:, database_id:, start_title: "Ardvark", end_title: "Goo"
  # [START spanner_query_data_with_index]
  # project_id  = "Your Google Cloud project ID"
  # instance_id = "Your Spanner instance ID"
  # database_id = "Your Spanner database ID"
  # start_title = "An album title to start with such as 'Ardvark'"
  # end_title   = "An album title to end with such as 'Goo'"

  require "google/cloud/spanner"

  spanner = Google::Cloud::Spanner.new project: project_id
  client  = spanner.client instance_id, database_id

  sql_query = "SELECT AlbumId, AlbumTitle, MarketingBudget
               FROM Albums@{FORCE_INDEX=AlbumsByAlbumTitle}
               WHERE AlbumTitle >= @start_title AND AlbumTitle < @end_title"

  params      = { start_title: start_title, end_title: end_title }
  param_types = { start_title: :STRING,     end_title: :STRING }

  client.execute(sql_query, params: params, types: param_types).rows.each do |row|
    puts "#{row[:AlbumId]} #{row[:AlbumTitle]} #{row[:MarketingBudget]}"
  end
  # [END spanner_query_data_with_index]
end

def read_data_with_index project_id:, instance_id:, database_id:
  # [START spanner_read_data_with_index]
  # project_id  = "Your Google Cloud project ID"
  # instance_id = "Your Spanner instance ID"
  # database_id = "Your Spanner database ID"

  require "google/cloud/spanner"

  spanner = Google::Cloud::Spanner.new project: project_id
  client  = spanner.client instance_id, database_id

  result = client.read "Albums", [:AlbumId, :AlbumTitle],
                       index: "AlbumsByAlbumTitle"

  result.rows.each do |row|
    puts "#{row[:AlbumId]} #{row[:AlbumTitle]}"
  end
  # [END spanner_read_data_with_index]
end

def read_data_with_storing_index project_id:, instance_id:, database_id:
  # [START spanner_read_data_with_storing_index]
  # project_id  = "Your Google Cloud project ID"
  # instance_id = "Your Spanner instance ID"
  # database_id = "Your Spanner database ID"

  require "google/cloud/spanner"

  spanner = Google::Cloud::Spanner.new project: project_id
  client  = spanner.client instance_id, database_id

  result = client.read "Albums", [:AlbumId, :AlbumTitle, :MarketingBudget],
                       index: "AlbumsByAlbumTitle2"

  result.rows.each do |row|
    puts "#{row[:AlbumId]} #{row[:AlbumTitle]} #{row[:MarketingBudget]}"
  end
  # [END spanner_read_data_with_storing_index]
end

def read_only_transaction project_id:, instance_id:, database_id:
  # [START spanner_read_only_transaction]
  # project_id  = "Your Google Cloud project ID"
  # instance_id = "Your Spanner instance ID"
  # database_id = "Your Spanner database ID"

  require "google/cloud/spanner"

  spanner = Google::Cloud::Spanner.new project: project_id
  client  = spanner.client instance_id, database_id

  client.snapshot do |snapshot|
    snapshot.execute("SELECT SingerId, AlbumId, AlbumTitle FROM Albums").rows.each do |row|
      puts "#{row[:AlbumId]} #{row[:AlbumTitle]} #{row[:SingerId]}"
    end

    # Even if changes occur in-between the reads, the transaction ensures that
    # both return the same data.
    snapshot.read("Albums", [:AlbumId, :AlbumTitle, :SingerId]).rows.each do |row|
      puts "#{row[:AlbumId]} #{row[:AlbumTitle]} #{row[:SingerId]}"
    end
  end
  # [END spanner_read_only_transaction]
end

def spanner_batch_client project_id:, instance_id:, database_id:
  # [START spanner_batch_client]
  # project_id  = "Your Google Cloud project ID"
  # instance_id = "Your Spanner instance ID"
  # database_id = "Your Spanner database ID"

  require "google/cloud/spanner"

  # Prepare a thread pool with number of processors
  processor_count  = Concurrent.processor_count
  thread_pool      = Concurrent::FixedThreadPool.new processor_count

  # Prepare AtomicFixnum to count total records using multiple threads
  total_records = Concurrent::AtomicFixnum.new

  # Create a new Spanner batch client
  spanner        = Google::Cloud::Spanner.new project: project_id
  batch_client   = spanner.batch_client instance_id, database_id

  # Get a strong timestamp bound batch_snapshot
  batch_snapshot = batch_client.batch_snapshot strong: true

  # Get partitions for specified query
  partitions       = batch_snapshot.partition_query "SELECT SingerId, FirstName, LastName FROM Singers"
  total_partitions = partitions.size

  # Enqueue a new thread pool job
  partitions.each_with_index do |partition, _partition_index|
    thread_pool.post do
      # Increment total_records per new row
      batch_snapshot.execute_partition(partition).rows.each do |_row|
        total_records.increment
      end
    end
  end

  # Wait for queued jobs to complete
  thread_pool.shutdown
  thread_pool.wait_for_termination

  # Close the client connection and release resources.
  batch_snapshot.close

  # Collect statistics for batch query
  average_records_per_partition = 0.0
  if total_partitions != 0
    average_records_per_partition = total_records.value.to_f / total_partitions.to_f
  end

  puts "Total Partitions: #{total_partitions}"
  puts "Total Records: #{total_records.value}"
  puts "Average records per Partition: #{average_records_per_partition}"
  # [END spanner_batch_client]
end

def insert_using_dml project_id:, instance_id:, database_id:
  # [START spanner_dml_standard_insert]
  # project_id  = "Your Google Cloud project ID"
  # instance_id = "Your Spanner instance ID"
  # database_id = "Your Spanner database ID"

  require "google/cloud/spanner"

  spanner   = Google::Cloud::Spanner.new project: project_id
  client    = spanner.client instance_id, database_id
  row_count = 0

  client.transaction do |transaction|
    row_count = transaction.execute_update(
      "INSERT INTO Singers (SingerId, FirstName, LastName) VALUES (10, 'Virginia', 'Watson')"
    )
  end

  puts "#{row_count} record inserted."
  # [END spanner_dml_standard_insert]
end

def update_using_dml project_id:, instance_id:, database_id:
  # [START spanner_dml_standard_update]
  # project_id  = "Your Google Cloud project ID"
  # instance_id = "Your Spanner instance ID"
  # database_id = "Your Spanner database ID"

  require "google/cloud/spanner"

  spanner = Google::Cloud::Spanner.new project: project_id
  client  = spanner.client instance_id, database_id
  row_count = 0

  client.transaction do |transaction|
    row_count = transaction.execute_update(
      "UPDATE Albums
       SET MarketingBudget = MarketingBudget * 2
       WHERE SingerId = 1 and AlbumId = 1"
    )
  end

  puts "#{row_count} record updated."
  # [END spanner_dml_standard_update]
end

def delete_using_dml project_id:, instance_id:, database_id:
  # [START spanner_dml_standard_delete]
  # project_id  = "Your Google Cloud project ID"
  # instance_id = "Your Spanner instance ID"
  # database_id = "Your Spanner database ID"

  require "google/cloud/spanner"

  spanner = Google::Cloud::Spanner.new project: project_id
  client  = spanner.client instance_id, database_id
  row_count = 0

  client.transaction do |transaction|
    row_count = transaction.execute_update(
      "DELETE FROM Singers WHERE FirstName = 'Alice'"
    )
  end

  puts "#{row_count} record deleted."
  # [END spanner_dml_standard_delete]
end

def update_using_dml_with_timestamp project_id:, instance_id:, database_id:
  # [START spanner_dml_standard_update_with_timestamp]
  # project_id  = "Your Google Cloud project ID"
  # instance_id = "Your Spanner instance ID"
  # database_id = "Your Spanner database ID"

  require "google/cloud/spanner"

  spanner = Google::Cloud::Spanner.new project: project_id
  client  = spanner.client instance_id, database_id
  row_count = 0

  client.transaction do |transaction|
    row_count = transaction.execute_update(
      "UPDATE Albums SET LastUpdateTime = PENDING_COMMIT_TIMESTAMP() WHERE SingerId = 1"
    )
  end

  puts "#{row_count} records updated."
  # [END spanner_dml_standard_update_with_timestamp]
end

def write_and_read_using_dml project_id:, instance_id:, database_id:
  # [START spanner_dml_write_then_read]
  # project_id  = "Your Google Cloud project ID"
  # instance_id = "Your Spanner instance ID"
  # database_id = "Your Spanner database ID"

  require "google/cloud/spanner"

  spanner = Google::Cloud::Spanner.new project: project_id
  client  = spanner.client instance_id, database_id
  row_count = 0

  client.transaction do |transaction|
    row_count = transaction.execute_update(
      "INSERT INTO Singers (SingerId, FirstName, LastName) VALUES (11, 'Timothy', 'Campbell')"
    )
    puts "#{row_count} record updated."
    transaction.execute("SELECT FirstName, LastName FROM Singers WHERE SingerId = 11").rows.each do |row|
      puts "#{row[:FirstName]} #{row[:LastName]}"
    end
  end
  # [END spanner_dml_write_then_read]
end

def update_using_dml_with_struct project_id:, instance_id:, database_id:
  # [START spanner_dml_structs]
  # project_id  = "Your Google Cloud project ID"
  # instance_id = "Your Spanner instance ID"
  # database_id = "Your Spanner database ID"

  require "google/cloud/spanner"

  spanner = Google::Cloud::Spanner.new project: project_id
  client  = spanner.client instance_id, database_id
  row_count = 0
  name_struct = { FirstName: "Timothy", LastName: "Campbell" }

  client.transaction do |transaction|
    row_count = transaction.execute_update(
      "UPDATE Singers SET LastName = 'Grant'
       WHERE STRUCT<FirstName STRING, LastName STRING>(FirstName, LastName) = @name",
      params: { name: name_struct }
    )
  end

  puts "#{row_count} record updated."
  # [END spanner_dml_structs]
end

def write_using_dml project_id:, instance_id:, database_id:
  # [START spanner_dml_getting_started_insert]
  # project_id  = "Your Google Cloud project ID"
  # instance_id = "Your Spanner instance ID"
  # database_id = "Your Spanner database ID"

  require "google/cloud/spanner"

  spanner = Google::Cloud::Spanner.new project: project_id
  client  = spanner.client instance_id, database_id
  row_count = 0

  client.transaction do |transaction|
    row_count = transaction.execute_update(
      "INSERT INTO Singers (SingerId, FirstName, LastName) VALUES
       (12, 'Melissa', 'Garcia'),
       (13, 'Russell', 'Morales'),
       (14, 'Jacqueline', 'Long'),
       (15, 'Dylan', 'Shaw')"
    )
  end

  puts "#{row_count} records inserted."
  # [END spanner_dml_getting_started_insert]
end

def write_with_transaction_using_dml project_id:, instance_id:, database_id:
  # [START spanner_dml_getting_started_update]
  # project_id  = "Your Google Cloud project ID"
  # instance_id = "Your Spanner instance ID"
  # database_id = "Your Spanner database ID"

  require "google/cloud/spanner"

  spanner = Google::Cloud::Spanner.new project: project_id
  client  = spanner.client instance_id, database_id

  client.transaction do |transaction|
    first_album = transaction.execute(
      "SELECT MarketingBudget from Albums
       WHERE SingerId = 1 and AlbumId = 1"
    ).rows.first
    second_album = transaction.execute(
      "SELECT MarketingBudget from Albums
      WHERE SingerId = 2 and AlbumId = 2"
    ).rows.first
    raise "The first album does not have enough funds to transfer" if first_album[:MarketingBudget] < 300_000

    new_second_album_budget = second_album[:MarketingBudget] + 200_000
    new_first_album_budget  = first_album[:MarketingBudget] - 200_000

    transaction.execute_update(
      "UPDATE Albums SET MarketingBudget = @albumBudget WHERE SingerId = 1 and AlbumId = 1",
      params: { albumBudget: new_first_album_budget }
    )
    transaction.execute_update(
      "UPDATE Albums SET MarketingBudget = @albumBudget WHERE SingerId = 2 and AlbumId = 2",
      params: { albumBudget: new_second_album_budget }
    )
  end

  puts "Transaction complete"
  # [END spanner_dml_getting_started_update]
end

def update_using_partitioned_dml project_id:, instance_id:, database_id:
  # [START spanner_dml_partitioned_update]
  # project_id  = "Your Google Cloud project ID"
  # instance_id = "Your Spanner instance ID"
  # database_id = "Your Spanner database ID"

  require "google/cloud/spanner"

  spanner = Google::Cloud::Spanner.new project: project_id
  client  = spanner.client instance_id, database_id

  row_count = client.execute_partition_update(
    "UPDATE Albums SET MarketingBudget = 100000 WHERE SingerId > 1"
  )

  puts "#{row_count} records updated."
  # [END spanner_dml_partitioned_update]
end

def delete_using_partitioned_dml project_id:, instance_id:, database_id:
  # [START spanner_dml_partitioned_delete]
  # project_id  = "Your Google Cloud project ID"
  # instance_id = "Your Spanner instance ID"
  # database_id = "Your Spanner database ID"

  require "google/cloud/spanner"

  spanner = Google::Cloud::Spanner.new project: project_id
  client  = spanner.client instance_id, database_id

  row_count = client.execute_partition_update(
    "DELETE FROM Singers WHERE SingerId > 10"
  )

  puts "#{row_count} records deleted."
  # [END spanner_dml_partitioned_delete]
end

def usage
  puts <<~USAGE
    Usage: bundle exec ruby spanner_samples.rb [command] [arguments]

    Commands:
      create_database                    <instance_id> <database_id> Create Database
      create_table_with_timestamp_column <instance_id> <database_id> Create table Performances with commit timestamp column
      insert_data                        <instance_id> <database_id> Insert Data
      insert_data_with_timestamp_column  <instance_id> <database_id> Inserts data into Performances table containing the commit timestamp column
      query_data                         <instance_id> <database_id> Query Data
      read_data                          <instance_id> <database_id> Read Data
      read_stale_data                    <instance_id> <database_id> Read Stale Data
      create_index                       <instance_id> <database_id> Create Index
      create_storing_index               <instance_id> <database_id> Create Storing Index
      add_column                         <instance_id> <database_id> Add Column
      add_timestamp_column               <instance_id> <database_id> Alters existing Albums table, adding a commit timestamp column
      update_data                        <instance_id> <database_id> Update Data
      update_data_with_timestamp_column  <instance_id> <database_id> Updates two records in the altered table where the commit timestamp column was added
      query_data_with_new_column         <instance_id> <database_id> Query Data with New Column
      query_data_with_timestamp_column   <instance_id> <database_id> Queries data from altered table where the commit timestamp column was added
      write_struct_data                  <instance_id> <database_id> Inserts sample data that can be used for STRUCT queries
      query_with_struct                  <instance_id> <database_id> Queries data using a STRUCT paramater
      query_with_array_of_struct         <instance_id> <database_id> Queries data using an array of STRUCT values as parameter
      query_struct_field                 <instance_id> <database_id> Queries data by accessing field from a STRUCT parameter
      query_nested_struct_field          <instance_id> <database_id> Queries data by accessing field from nested STRUCT parameters
      query_data_with_index              <instance_id> <database_id> <start_title> <end_title> Query Data with Index
      read_write_transaction             <instance_id> <database_id> Read-Write Transaction
      read_data_with_index               <instance_id> <database_id> Read Data with Index
      read_data_with_storing_index       <instance_id> <database_id> Read Data with Storing Index
      read_only_transaction              <instance_id> <database_id> Read-Only Transaction
      spanner_batch_client               <instance_id> <database_id> Use Spanner batch query with a thread pool
      insert_using_dml                   <instance_id> <database_id> Insert Data using a DML statement.
      update_using_dml                   <instance_id> <database_id> Update Data using a DML statement.
      delete_using_dml                   <instance_id> <database_id> Delete Data using a DML statement.
      update_using_dml_with_timestamp    <instance_id> <database_id> Update the timestamp value of specifc records using a DML statement.
      write_and_read_using_dml           <instance_id> <database_id> Insert data using a DML statement and then read the inserted data.
      update_using_dml_with_struct       <instance_id> <database_id> Update data using a DML statement combined with a Spanner struct.
      write_using_dml                    <instance_id> <database_id> Insert multiple records using a DML statement.
      write_with_transaction_using_dml   <instance_id> <database_id> Update data using a DML statement within a read-write transaction.
      update_using_partitioned_dml       <instance_id> <database_id> Update multiple records using a partitioned DML statement.
      delete_using_partitioned_dml       <instance_id> <database_id> Delete multiple records using a partitioned DML statement.

    Environment variables:
      GOOGLE_CLOUD_PROJECT must be set to your Google Cloud project ID
  USAGE
end

def run_sample arguments
  command     = arguments.shift
  instance_id = arguments.shift
  database_id = arguments.shift
  project_id  = ENV["GOOGLE_CLOUD_PROJECT"]

  commands = ["create_database", "create_table_with_timestamp_column", "insert_data", "insert_data_with_timestamp_column", "query_data", "query_data_with_timestamp_column", "read_data", "read_stale_data", "create_index", "create_storing_index", "add_column", "add_timestamp_column", "update_data", "query_data_with_new_column", "update_data_with_timestamp_column", "read_write_transaction", "query_data_with_index", "read_data_with_index", "read_data_with_storing_index", "read_only_transaction", "spanner_batch_client", "write_struct_data", "query_with_struct", "query_with_array_of_struct", "query_struct_field", "query_nested_struct_field", "insert_using_dml", "update_using_dml", "delete_using_dml", "update_using_dml_with_timestamp", "write_and_read_using_dml", "update_using_dml_with_struct", "write_using_dml", "write_with_transaction_using_dml", "update_using_partitioned_dml", "delete_using_partitioned_dml"]
  if command.eql?("query_data_with_index") && instance_id && database_id && arguments.size >= 2
    query_data_with_index project_id:  project_id,
                          instance_id: instance_id,
                          database_id: database_id,
                          start_title: arguments.shift,
                          end_title:   arguments.shift
  elsif commands.include?(command) && instance_id && database_id
    send command, project_id:  project_id,
                  instance_id: instance_id,
                  database_id: database_id
  else
    usage
  end
end

if $PROGRAM_NAME == __FILE__
  run_sample ARGV
end
