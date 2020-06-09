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

def create_instance project_id:, instance_id:
  # [START spanner_create_instance]
  # project_id  = "Your Google Cloud project ID"
  # instance_id = "Your Spanner instance ID"

  require "google/cloud/spanner"

  spanner  = Google::Cloud::Spanner.new project: project_id
  instance = spanner.instance instance_id

  job = spanner.create_instance instance_id,
                                name:   instance_id,
                                config: "regional-us-central1",
                                nodes:  2,
                                labels: { "cloud_spanner_samples": true }

  puts "Waiting for create instance operation to complete"

  job.wait_until_done!

  if job.error?
    puts job.error
  else
    puts "Created instance #{instance_id}"
  end
  # [END spanner_create_instance]
end

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

def delete_data project_id:, instance_id:, database_id:
  # [START spanner_delete_data]
  # project_id  = "Your Google Cloud project ID"
  # instance_id = "Your Spanner instance ID"
  # database_id = "Your Spanner database ID"

  require "google/cloud/spanner"

  spanner = Google::Cloud::Spanner.new project: project_id
  client  = spanner.client instance_id, database_id

  # Delete individual rows
  client.delete "Albums", [[2, 1], [2, 3]]

  # Delete a range of rows where the column key is >=3 and <5
  key_range = client.range 3, 5, exclude_end: true
  client.delete "Singers", key_range

  # Delete remaining Singers rows, which will also delete the remaining
  # Albums rows because Albums was defined with ON DELETE CASCADE
  client.delete "Singers"

  # [END spanner_delete_data]
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

  spanner         = Google::Cloud::Spanner.new project: project_id
  client          = spanner.client instance_id, database_id
  transfer_amount = 200_000

  client.transaction do |transaction|
    first_album  = transaction.read("Albums", [:MarketingBudget], keys: [[1, 1]]).rows.first
    second_album = transaction.read("Albums", [:MarketingBudget], keys: [[2, 2]]).rows.first

    raise "The second album does not have enough funds to transfer" if second_album[:MarketingBudget] < transfer_amount

    new_first_album_budget  = first_album[:MarketingBudget] + transfer_amount
    new_second_album_budget = second_album[:MarketingBudget] - transfer_amount

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
    average_records_per_partition = total_records.value / total_partitions.to_f
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
       (15, 'Dylan', 'Shaw'),
       (16, 'Billie', 'Eillish'),
       (17, 'Judy', 'Garland'),
       (18, 'Taylor', 'Swift'),
       (19, 'Miley', 'Cyrus'),
       (20, 'Michael', 'Jackson'),
       (21, 'Ariana', 'Grande'),
       (22, 'Elvis', 'Presley'),
       (23, 'Kanye', 'West'),
       (24, 'Lady', 'Gaga'),
       (25, 'Nick', 'Jonas')"
    )
  end

  puts "#{row_count} records inserted."
  # [END spanner_dml_getting_started_insert]
end

def query_with_parameter project_id:, instance_id:, database_id:
  # [START spanner_query_with_parameter]
  # project_id  = "Your Google Cloud project ID"
  # instance_id = "Your Spanner instance ID"
  # database_id = "Your Spanner database ID"

  require "google/cloud/spanner"

  spanner = Google::Cloud::Spanner.new project: project_id
  client  = spanner.client instance_id, database_id

  sql_query = "SELECT SingerId, FirstName, LastName
               FROM Singers
               WHERE LastName = @lastName"

  params      = { lastName: "Garcia" }
  param_types = { lastName: :STRING }

  client.execute(sql_query, params: params, types: param_types).rows.each do |row|
    puts "#{row[:SingerId]} #{row[:FirstName]} #{row[:LastName]}"
  end
  # [END spanner_query_with_parameter]
end

def write_with_transaction_using_dml project_id:, instance_id:, database_id:
  # [START spanner_dml_getting_started_update]
  # project_id  = "Your Google Cloud project ID"
  # instance_id = "Your Spanner instance ID"
  # database_id = "Your Spanner database ID"

  require "google/cloud/spanner"

  spanner         = Google::Cloud::Spanner.new project: project_id
  client          = spanner.client instance_id, database_id
  transfer_amount = 200_000

  client.transaction do |transaction|
    first_album = transaction.execute(
      "SELECT MarketingBudget from Albums
       WHERE SingerId = 1 and AlbumId = 1"
    ).rows.first
    second_album = transaction.execute(
      "SELECT MarketingBudget from Albums
      WHERE SingerId = 2 and AlbumId = 2"
    ).rows.first
    raise "The second album does not have enough funds to transfer" if second_album[:MarketingBudget] < transfer_amount

    new_first_album_budget  = first_album[:MarketingBudget] + transfer_amount
    new_second_album_budget = second_album[:MarketingBudget] - transfer_amount

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

def update_using_batch_dml project_id:, instance_id:, database_id:
  # [START spanner_dml_batch_update]
  # project_id  = "Your Google Cloud project ID"
  # instance_id = "Your Spanner instance ID"
  # database_id = "Your Spanner database ID"

  require "google/cloud/spanner"

  spanner = Google::Cloud::Spanner.new project: project_id
  client  = spanner.client instance_id, database_id

  row_counts = nil
  client.transaction do |transaction|
    row_counts = transaction.batch_update do |b|
      b.batch_update "INSERT INTO Albums "\
        "(SingerId, AlbumId, AlbumTitle, MarketingBudget) "\
        "VALUES (1, 3, 'Test Album Title', 10000)"
      b.batch_update "UPDATE Albums "\
        "SET MarketingBudget = MarketingBudget * 2 "\
        "WHERE SingerId = 1 and AlbumId = 3"
    end
  end

  statement_count = row_counts.count

  puts "Executed #{statement_count} SQL statements using Batch DML."
  # [END spanner_dml_batch_update]
end

def create_table_with_datatypes project_id:, instance_id:, database_id:
  # [START spanner_create_table_with_datatypes]
  # project_id  = "Your Google Cloud project ID"
  # instance_id = "Your Spanner instance ID"
  # database_id = "Your Spanner database ID"

  require "google/cloud/spanner"

  spanner = Google::Cloud::Spanner.new project: project_id
  client  = spanner.database instance_id, database_id

  job = client.update statements: [
    "CREATE TABLE Venues (
      VenueId         INT64 NOT NULL,
      VenueName       STRING(100),
      VenueInfo       BYTES(MAX),
      Capacity        INT64,
      AvailableDates  ARRAY<DATE>,
      LastContactDate DATE,
      OutdoorVenue    BOOL,
      PopularityScore FLOAT64,
      LastUpdateTime  TIMESTAMP NOT NULL OPTIONS (allow_commit_timestamp=true)
     ) PRIMARY KEY (VenueId)"
  ]

  puts "Waiting for update database operation to complete"

  job.wait_until_done!

  puts "Created table Venues in #{database_id}"
  # [END spanner_create_table_with_datatypes]
end

def write_datatypes_data project_id:, instance_id:, database_id:
  # [START spanner_insert_datatypes_data]
  # project_id  = "Your Google Cloud project ID"
  # instance_id = "Your Spanner instance ID"
  # database_id = "Your Spanner database ID"

  require "google/cloud/spanner"

  spanner = Google::Cloud::Spanner.new project: project_id
  client  = spanner.client instance_id, database_id

  # Get commit_timestamp
  commit_timestamp = client.commit_timestamp

  client.commit do |c|
    c.insert "Venues", [
      { VenueId: 4, VenueName: "Venue 4", VenueInfo: StringIO.new("Hello World 1"),
        Capacity: 1_800, AvailableDates: ["2020-12-01", "2020-12-02", "2020-12-03"],
        LastContactDate: "2018-09-02", OutdoorVenue: false, PopularityScore: 0.85543,
        LastUpdateTime: commit_timestamp },
      { VenueId: 19, VenueName: "Venue 19", VenueInfo: StringIO.new("Hello World 2"),
        Capacity: 6_300, AvailableDates: ["2020-11-01", "2020-11-05", "2020-11-15"],
        LastContactDate: "2019-01-15", OutdoorVenue: true, PopularityScore: 0.98716,
        LastUpdateTime: commit_timestamp },
      { VenueId: 42, VenueName: "Venue 42", VenueInfo: StringIO.new("Hello World 3"),
        Capacity: 3_000, AvailableDates: ["2020-10-01", "2020-10-07"],
        LastContactDate: "2018-10-01", OutdoorVenue: false, PopularityScore: 0.72598,
        LastUpdateTime: commit_timestamp }
    ]
  end

  puts "Inserted data"
  # [END spanner_insert_datatypes_data]
end

def query_with_array project_id:, instance_id:, database_id:
  # [START spanner_query_with_array_parameter]
  # project_id  = "Your Google Cloud project ID"
  # instance_id = "Your Spanner instance ID"
  # database_id = "Your Spanner database ID"

  require "google/cloud/spanner"

  spanner = Google::Cloud::Spanner.new project: project_id
  client  = spanner.client instance_id, database_id

  sql_query = "SELECT VenueId, VenueName, AvailableDate FROM Venues v,
               UNNEST(v.AvailableDates) as AvailableDate
               WHERE AvailableDate in UNNEST(@available_dates)"

  params      = { available_dates: ["2020-10-01", "2020-11-01"] }
  param_types = { available_dates: [:DATE] }

  client.execute(sql_query, params: params, types: param_types).rows.each do |row|
    puts "#{row[:VenueId]} #{row[:VenueName]} #{row[:AvailableDate]}"
  end
  # [END spanner_query_with_array_parameter]
end

def query_with_bool project_id:, instance_id:, database_id:
  # [START spanner_query_with_bool_parameter]
  # project_id  = "Your Google Cloud project ID"
  # instance_id = "Your Spanner instance ID"
  # database_id = "Your Spanner database ID"

  require "google/cloud/spanner"

  spanner = Google::Cloud::Spanner.new project: project_id
  client  = spanner.client instance_id, database_id

  sql_query = "SELECT VenueId, VenueName, OutdoorVenue FROM Venues
               WHERE OutdoorVenue = @outdoor_venue"

  params      = { outdoor_venue: true }
  param_types = { outdoor_venue: :BOOL }

  client.execute(sql_query, params: params, types: param_types).rows.each do |row|
    puts "#{row[:VenueId]} #{row[:VenueName]} #{row[:OutdoorVenue]}"
  end
  # [END spanner_query_with_bool_parameter]
end

def query_with_bytes project_id:, instance_id:, database_id:
  # [START spanner_query_with_bytes_parameter]
  # project_id  = "Your Google Cloud project ID"
  # instance_id = "Your Spanner instance ID"
  # database_id = "Your Spanner database ID"

  require "google/cloud/spanner"

  spanner = Google::Cloud::Spanner.new project: project_id
  client  = spanner.client instance_id, database_id

  example_bytes = StringIO.new "Hello World 1"
  sql_query = "SELECT VenueId, VenueName FROM Venues
               WHERE VenueInfo = @venue_info"

  params      = { venue_info: example_bytes }
  param_types = { venue_info: :BYTES }

  client.execute(sql_query, params: params, types: param_types).rows.each do |row|
    puts "#{row[:VenueId]} #{row[:VenueName]}"
  end
  # [END spanner_query_with_bytes_parameter]
end

def query_with_date project_id:, instance_id:, database_id:
  # [START spanner_query_with_date_parameter]
  # project_id  = "Your Google Cloud project ID"
  # instance_id = "Your Spanner instance ID"
  # database_id = "Your Spanner database ID"

  require "google/cloud/spanner"

  spanner = Google::Cloud::Spanner.new project: project_id
  client  = spanner.client instance_id, database_id

  sql_query = "SELECT VenueId, VenueName, LastContactDate FROM Venues
               WHERE LastContactDate < @last_contact_date"

  params      = { last_contact_date: "2019-01-01" }
  param_types = { last_contact_date: :DATE }

  client.execute(sql_query, params: params, types: param_types).rows.each do |row|
    puts "#{row[:VenueId]} #{row[:VenueName]} #{row[:LastContactDate]}"
  end
  # [END spanner_query_with_date_parameter]
end

def query_with_float project_id:, instance_id:, database_id:
  # [START spanner_query_with_float_parameter]
  # project_id  = "Your Google Cloud project ID"
  # instance_id = "Your Spanner instance ID"
  # database_id = "Your Spanner database ID"

  require "google/cloud/spanner"

  spanner = Google::Cloud::Spanner.new project: project_id
  client  = spanner.client instance_id, database_id

  sql_query = "SELECT VenueId, VenueName, PopularityScore FROM Venues
               WHERE PopularityScore > @popularity_score"

  params      = { popularity_score: 0.8 }
  param_types = { popularity_score: :FLOAT64 }

  client.execute(sql_query, params: params, types: param_types).rows.each do |row|
    puts "#{row[:VenueId]} #{row[:VenueName]} #{row[:PopularityScore]}"
  end
  # [END spanner_query_with_float_parameter]
end

def query_with_int project_id:, instance_id:, database_id:
  # [START spanner_query_with_int_parameter]
  # project_id  = "Your Google Cloud project ID"
  # instance_id = "Your Spanner instance ID"
  # database_id = "Your Spanner database ID"

  require "google/cloud/spanner"

  spanner = Google::Cloud::Spanner.new project: project_id
  client  = spanner.client instance_id, database_id

  sql_query = "SELECT VenueId, VenueName, Capacity FROM Venues
               WHERE Capacity >= @capacity"

  params      = { capacity: 3_000 }
  param_types = { capacity: :INT64 }

  client.execute(sql_query, params: params, types: param_types).rows.each do |row|
    puts "#{row[:VenueId]} #{row[:VenueName]} #{row[:Capacity]}"
  end
  # [END spanner_query_with_int_parameter]
end

def query_with_string project_id:, instance_id:, database_id:
  # [START spanner_query_with_string_parameter]
  # project_id  = "Your Google Cloud project ID"
  # instance_id = "Your Spanner instance ID"
  # database_id = "Your Spanner database ID"

  require "google/cloud/spanner"

  spanner = Google::Cloud::Spanner.new project: project_id
  client  = spanner.client instance_id, database_id

  sql_query = "SELECT VenueId, VenueName FROM Venues
               WHERE VenueName = @venue_name"

  params      = { venue_name: "Venue 42" }
  param_types = { venue_name: :STRING }

  client.execute(sql_query, params: params, types: param_types).rows.each do |row|
    puts "#{row[:VenueId]} #{row[:VenueName]}"
  end
  # [END spanner_query_with_string_parameter]
end

def query_with_timestamp project_id:, instance_id:, database_id:
  # [START spanner_query_with_timestamp_parameter]
  # project_id  = "Your Google Cloud project ID"
  # instance_id = "Your Spanner instance ID"
  # database_id = "Your Spanner database ID"

  require "google/cloud/spanner"

  spanner = Google::Cloud::Spanner.new project: project_id
  client  = spanner.client instance_id, database_id

  example_timestamp = DateTime.now
  sql_query = "SELECT VenueId, VenueName, LastUpdateTime FROM Venues
               WHERE LastUpdateTime < @last_update_time"

  params      = { last_update_time: example_timestamp }
  param_types = { last_update_time: :TIMESTAMP }

  client.execute(sql_query, params: params, types: param_types).rows.each do |row|
    puts "#{row[:VenueId]} #{row[:VenueName]} #{row[:LastUpdateTime]}"
  end
  # [END spanner_query_with_timestamp_parameter]
end

def query_with_query_options project_id:, instance_id:, database_id:
  # [START spanner_query_with_query_options]
  # project_id  = "Your Google Cloud project ID"
  # instance_id = "Your Spanner instance ID"
  # database_id = "Your Spanner database ID"

  require "google/cloud/spanner"

  spanner = Google::Cloud::Spanner.new project: project_id
  client  = spanner.client instance_id, database_id

  sql_query = "SELECT VenueId, VenueName, LastUpdateTime FROM Venues"
  query_options = { optimizer_version: "1" }

  client.execute(sql_query, query_options: query_options).rows.each do |row|
    puts "#{row[:VenueId]} #{row[:VenueName]} #{row[:LastUpdateTime]}"
  end
  # [END spanner_query_with_query_options]
end

def create_client_with_query_options project_id:, instance_id:, database_id:
  # [START spanner_create_client_with_query_options]
  # project_id  = "Your Google Cloud project ID"
  # instance_id = "Your Spanner instance ID"
  # database_id = "Your Spanner database ID"

  require "google/cloud/spanner"

  query_options = { optimizer_version: "1" }

  spanner = Google::Cloud::Spanner.new project: project_id
  client  = spanner.client instance_id, database_id, query_options: query_options

  sql_query = "SELECT VenueId, VenueName, LastUpdateTime FROM Venues"

  client.execute(sql_query).rows.each do |row|
    puts "#{row[:VenueId]} #{row[:VenueName]} #{row[:LastUpdateTime]}"
  end
  # [END spanner_create_client_with_query_options]
end

def write_read_bool_array project_id:, instance_id:, database_id:
  # [START spanner_write_read_bool_array]
  # project_id  = "Your Google Cloud project ID"
  # instance_id = "Your Spanner instance ID"
  # database_id = "Your Spanner database ID"

  require "google/cloud/spanner"
  require "securerandom"

  spanner = Google::Cloud::Spanner.new project: project_id
  database = spanner.database instance_id, database_id
  job = database.update statements: [
    "CREATE TABLE Boxes (
        BoxId             STRING(36) NOT NULL,
        Heights           ARRAY<INT64>,
        Weights           ARRAY<FLOAT64>,
        ErrorChecks       ARRAY<BOOL>
      ) PRIMARY KEY (BoxId)"
  ]
  job.wait_until_done!

  client = spanner.client instance_id, database_id

  box_id = SecureRandom.uuid
  client.insert "Boxes", BoxId: box_id, ErrorChecks: [true, false, true]
  results = client.read "Boxes", [:BoxId, :ErrorChecks], keys: box_id

  results.rows.each do |row|
    puts row["ErrorChecks"]
  end
  # [END spanner_write_read_bool_array]
end

def write_read_empty_int64_array project_id:, instance_id:, database_id:
  # [START spanner_write_read_empty_int64_array]
  # project_id  = "Your Google Cloud project ID"
  # instance_id = "Your Spanner instance ID"
  # database_id = "Your Spanner database ID"

  require "google/cloud/spanner"
  require "securerandom"

  spanner = Google::Cloud::Spanner.new project: project_id
  database = spanner.database instance_id, database_id
  job = database.update statements: [
    "CREATE TABLE Boxes (
        BoxId             STRING(36) NOT NULL,
        Heights           ARRAY<INT64>,
        Weights           ARRAY<FLOAT64>,
        ErrorChecks       ARRAY<BOOL>
      ) PRIMARY KEY (BoxId)"
  ]
  job.wait_until_done!

  client = spanner.client instance_id, database_id

  box_id = SecureRandom.uuid
  client.insert "Boxes", BoxId: box_id, Heights: []
  results = client.read "Boxes", [:BoxId, :Heights], keys: box_id

  results.rows.each do |row|
    puts row["Heights"].empty?
  end
  # [END spanner_write_read_empty_int64_array]
end

def write_read_null_int64_array project_id:, instance_id:, database_id:
  # [START spanner_write_read_null_int64_array]
  # project_id  = "Your Google Cloud project ID"
  # instance_id = "Your Spanner instance ID"
  # database_id = "Your Spanner database ID"

  require "google/cloud/spanner"
  require "securerandom"

  spanner = Google::Cloud::Spanner.new project: project_id
  database = spanner.database instance_id, database_id
  job = database.update statements: [
    "CREATE TABLE Boxes (
        BoxId             STRING(36) NOT NULL,
        Heights           ARRAY<INT64>,
        Weights           ARRAY<FLOAT64>,
        ErrorChecks       ARRAY<BOOL>
      ) PRIMARY KEY (BoxId)"
  ]
  job.wait_until_done!

  client = spanner.client instance_id, database_id

  box_id = SecureRandom.uuid
  client.insert "Boxes", BoxId: box_id, Heights: [nil, nil, nil]
  results = client.read "Boxes", [:BoxId, :Heights], keys: box_id

  results.rows.each do |row|
    row["Heights"].each { |height| puts height.nil? }
  end
  # [END spanner_write_read_null_int64_array]
end

def write_read_int64_array project_id:, instance_id:, database_id:
  # [START spanner_write_read_int64_array]
  # project_id  = "Your Google Cloud project ID"
  # instance_id = "Your Spanner instance ID"
  # database_id = "Your Spanner database ID"

  require "google/cloud/spanner"
  require "securerandom"

  spanner = Google::Cloud::Spanner.new project: project_id
  database = spanner.database instance_id, database_id
  job = database.update statements: [
    "CREATE TABLE Boxes (
        BoxId             STRING(36) NOT NULL,
        Heights           ARRAY<INT64>,
        Weights           ARRAY<FLOAT64>,
        ErrorChecks       ARRAY<BOOL>
      ) PRIMARY KEY (BoxId)"
  ]
  job.wait_until_done!

  client = spanner.client instance_id, database_id

  box_id = SecureRandom.uuid
  client.insert "Boxes", BoxId: box_id, Heights: [10, 11, 12]
  results = client.read "Boxes", [:BoxId, :Heights], keys: box_id

  results.rows.each do |row|
    puts row["Heights"]
  end
  # [END spanner_write_read_int64_array]
end

def write_read_empty_float64_array project_id:, instance_id:, database_id:
  # [START spanner_write_read_empty_float64_array]
  # project_id  = "Your Google Cloud project ID"
  # instance_id = "Your Spanner instance ID"
  # database_id = "Your Spanner database ID"

  require "google/cloud/spanner"
  require "securerandom"

  spanner = Google::Cloud::Spanner.new project: project_id
  database = spanner.database instance_id, database_id
  job = database.update statements: [
    "CREATE TABLE Boxes (
        BoxId             STRING(36) NOT NULL,
        Heights           ARRAY<INT64>,
        Weights           ARRAY<FLOAT64>,
        ErrorChecks       ARRAY<BOOL>
      ) PRIMARY KEY (BoxId)"
  ]
  job.wait_until_done!

  client = spanner.client instance_id, database_id

  box_id = SecureRandom.uuid
  client.insert "Boxes", BoxId: box_id, Weights: []
  results = client.read "Boxes", [:BoxId, :Weights], keys: box_id

  results.rows.each do |row|
    puts row["Weights"].empty?
  end
  # [END spanner_write_read_empty_float64_array]
end

def write_read_null_float64_array project_id:, instance_id:, database_id:
  # [START spanner_write_read_null_float64_array]
  # project_id  = "Your Google Cloud project ID"
  # instance_id = "Your Spanner instance ID"
  # database_id = "Your Spanner database ID"

  require "google/cloud/spanner"
  require "securerandom"

  spanner = Google::Cloud::Spanner.new project: project_id
  database = spanner.database instance_id, database_id
  job = database.update statements: [
    "CREATE TABLE Boxes (
        BoxId             STRING(36) NOT NULL,
        Heights           ARRAY<INT64>,
        Weights           ARRAY<FLOAT64>,
        ErrorChecks       ARRAY<BOOL>
      ) PRIMARY KEY (BoxId)"
  ]
  job.wait_until_done!

  client = spanner.client instance_id, database_id

  box_id = SecureRandom.uuid
  client.insert "Boxes", BoxId: box_id, Weights: [nil, nil, nil]
  results = client.read "Boxes", [:BoxId, :Weights], keys: box_id

  results.rows.each do |row|
    row["Weights"].each { |weight| puts weight.nil? }
  end
  # [END spanner_write_read_null_float64_array]
end

def write_read_float64_array project_id:, instance_id:, database_id:
  # [START spanner_write_read_float64_array]
  # project_id  = "Your Google Cloud project ID"
  # instance_id = "Your Spanner instance ID"
  # database_id = "Your Spanner database ID"

  require "google/cloud/spanner"
  require "securerandom"

  spanner = Google::Cloud::Spanner.new project: project_id
  database = spanner.database instance_id, database_id
  job = database.update statements: [
    "CREATE TABLE Boxes (
        BoxId             STRING(36) NOT NULL,
        Heights           ARRAY<INT64>,
        Weights           ARRAY<FLOAT64>,
        ErrorChecks       ARRAY<BOOL>
      ) PRIMARY KEY (BoxId)"
  ]
  job.wait_until_done!

  client = spanner.client instance_id, database_id

  box_id = SecureRandom.uuid
  client.insert "Boxes", BoxId: box_id, Weights: [10.001, 11.1212, 104.4123101]
  results = client.read "Boxes", [:BoxId, :Weights], keys: box_id

  results.rows.each do |row|
    puts row["Weights"]
  end
  # [END spanner_write_read_float64_array]
end

def create_backup project_id:, instance_id:, database_id:, backup_id:
  # [START spanner_create_backup]
  # project_id  = "Your Google Cloud project ID"
  # instance_id = "Your Spanner instance ID"
  # database_id = "Your Spanner database ID"
  # backup_id = "Your Spanner backup ID"

  require "google/cloud/spanner"

  spanner  = Google::Cloud::Spanner.new project: project_id
  instance = spanner.instance instance_id
  database = instance.database database_id
  expire_time = Time.now + 14 * 24 * 3600 # 14 days from now

  job = database.create_backup backup_id, expire_time

  puts "Backup operation in progress"

  job.wait_until_done!

  backup = instance.backup backup_id
  puts "Backup #{backup.backup_id} of size #{backup.size_in_bytes} bytes was created at #{backup.create_time}"
  # [END spanner_create_backup]
end

def restore_backup project_id:, instance_id:, database_id:, backup_id:
  # [START spanner_restore_backup]
  # project_id  = "Your Google Cloud project ID"
  # instance_id = "Your Spanner instance ID"
  # database_id = "Your Spanner database ID of where to restore"
  # backup_id = "Your Spanner backup ID"

  require "google/cloud/spanner"

  spanner  = Google::Cloud::Spanner.new project: project_id
  instance = spanner.instance instance_id

  backup = instance.backup backup_id
  job = backup.restore database_id

  puts "Waiting for restore backup operation to complete"

  job.wait_until_done!

  restore_info = job.database.restore_info
  puts "Database #{restore_info.backup_info.source_database_id} was restored to #{database_id} from backup #{restore_info.backup_info.backup_id}"
  # [END spanner_restore_backup]
end

def create_backup_cancel project_id:, instance_id:, database_id:, backup_id:
  # [START spanner_cancel_backup_create]
  # project_id  = "Your Google Cloud project ID"
  # instance_id = "Your Spanner instance ID"
  # database_id = "Your Spanner database ID"
  # backup_id = "Your Spanner backup ID"

  require "google/cloud/spanner"

  spanner  = Google::Cloud::Spanner.new project: project_id
  instance = spanner.instance instance_id
  database = instance.database database_id
  expire_time = Time.now + 14 * 24 * 3600 # 14 days from now

  job = database.create_backup backup_id, expire_time

  puts "Backup operation in progress"

  job.cancel
  job.wait_until_done!

  backup = instance.backup backup_id

  backup.delete if backup

  puts "#{backup_id} creation job cancelled"
  # [END spanner_cancel_backup_create]
end

def list_backup_operations project_id:, instance_id:, database_id:
  # [START spanner_list_backup_operations]
  # project_id  = "Your Google Cloud project ID"
  # instance_id = "Your Spanner instance ID"
  # database_id = "Your Spanner database ID"

  require "google/cloud/spanner"

  spanner  = Google::Cloud::Spanner.new project: project_id
  instance = spanner.instance instance_id

  jobs = instance.backup_operations filter: "metadata.@type:type.googleapis.com/google.spanner.admin.database.v1.CreateBackupMetadata"
  jobs.each do |job|
    if job.error?
      puts job.error
    else
      puts "Backup #{job.backup.backup_id} on database #{database_id} is #{job.progress_percent}% complete"
    end
  end
  # [END spanner_list_backup_operations]
end

def list_database_operations project_id:, instance_id:
  # [START spanner_list_database_operations]
  # project_id  = "Your Google Cloud project ID"
  # instance_id = "Your Spanner instance ID"

  require "google/cloud/spanner"

  spanner  = Google::Cloud::Spanner.new project: project_id
  instance = spanner.instance instance_id

  jobs = instance.database_operations filter: "metadata.@type:type.googleapis.com/google.spanner.admin.database.v1.OptimizeRestoredDatabaseMetadata"

  jobs.each do |job|
    if job.error?
      puts job.error
    elsif job.database
      progress_percent = job.grpc.metadata.progress.progress_percent
      puts "Database #{job.database.database_id} restored from backup is #{progress_percent}% optimized"
    end
  end
  # [END spanner_list_database_operations]
end

def list_backups project_id:, instance_id:, backup_id:, database_id:
  # [START spanner_list_backups]
  # project_id  = "Your Google Cloud project ID"
  # instance_id = "Your Spanner instance ID"
  # backup_id = "Your Spanner database backup ID"
  # database_id = "Your Spanner databaseID"

  require "google/cloud/spanner"

  spanner  = Google::Cloud::Spanner.new project: project_id
  instance = spanner.instance instance_id

  puts "All backups"
  instance.backups.all.each do |backup|
    puts backup.backup_id
  end

  puts "All backups with backup name containing \"#{backup_id}\":"
  instance.backups(filter: "name:#{backup_id}").all.each do |backup|
    puts backup.backup_id
  end

  puts "All backups for databases with a name containing \"#{database_id}\":"
  instance.backups(filter: "database:#{database_id}").all.each do |backup|
    puts backup.backup_id
  end

  puts "All backups that expire before a timestamp:"
  expire_time = Time.now + 30 * 24 * 3600 # 30 days from now
  instance.backups(filter: "expire_time < \"#{expire_time.iso8601}\"").all.each do |backup|
    puts backup.backup_id
  end

  puts "All backups with a size greater than 500 bytes:"
  instance.backups(filter: "size_bytes > 500").all.each do |backup|
    puts backup.backup_id
  end

  puts "All backups that were created after a timestamp that are also ready:"
  create_time = Time.now - 24 * 3600 # From 1 day ago
  instance.backups(filter: "create_time >= \"#{create_time.iso8601}\" AND state:READY").all.each do |backup|
    puts backup.backup_id
  end

  puts "All backups with pagination:"
  list = instance.backups page_size: 5
  list.each do |backup|
    puts backup.backup_id
  end
  # [END spanner_list_backups]
end

def delete_backup project_id:, instance_id:, backup_id:
  # [START spanner_delete_backup]
  # project_id  = "Your Google Cloud project ID"
  # instance_id = "Your Spanner instance ID"
  # backup_id = "Your Spanner backup ID"

  require "google/cloud/spanner"

  spanner  = Google::Cloud::Spanner.new project: project_id
  instance = spanner.instance instance_id

  backup = instance.backup backup_id
  backup.delete
  puts "Backup #{backup_id} deleted"
  # [END spanner_delete_backup]
end

def update_backup project_id:, instance_id:, backup_id:
  # [START spanner_update_backup]
  # project_id  = "Your Google Cloud project ID"
  # instance_id = "Your Spanner instance ID"
  # backup_id = "Your Spanner backup ID"

  require "google/cloud/spanner"

  spanner  = Google::Cloud::Spanner.new project: project_id
  instance = spanner.instance instance_id

  backup = instance.backup backup_id
  backup.expire_time = backup.expire_time + 2_592_000 # Extending the expiry time by 30 days.

  puts "Expiration time updated: #{backup.expire_time}"
  # [END spanner_update_backup]
end

def usage
  puts <<~USAGE

    Usage: bundle exec ruby spanner_samples.rb [command] [arguments]

    Commands:
      create_instance                    <instance_id> Create Instance
      create_database                    <instance_id> <database_id> Create Database
      create_table_with_timestamp_column <instance_id> <database_id> Create table Performances with commit timestamp column
      insert_data                        <instance_id> <database_id> Insert Data
      insert_data_with_timestamp_column  <instance_id> <database_id> Inserts data into Performances table containing the commit timestamp column
      query_data                         <instance_id> <database_id> Query Data
      read_data                          <instance_id> <database_id> Read Data
      delete_data                        <instance_id> <database_id> Delete Data
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
      query_with_parameter               <instance_id> <database_id> Query record inserted using DML with a query parameter.
      write_with_transaction_using_dml   <instance_id> <database_id> Update data using a DML statement within a read-write transaction.
      update_using_partitioned_dml       <instance_id> <database_id> Update multiple records using a partitioned DML statement.
      delete_using_partitioned_dml       <instance_id> <database_id> Delete multiple records using a partitioned DML statement.
      update_using_batch_dml             <instance_id> <database_id> Updates sample data in the database using Batch DML.
      create_table_with_datatypes        <instance_id> <database_id> Create table Venues with supported datatype columns.
      write_datatypes_data               <instance_id> <database_id> Inserts sample data that can be used for datatype queries.
      query_with_array                   <instance_id> <database_id> Queries data using an ARRAY parameter.
      query_with_bool                    <instance_id> <database_id> Queries data using a BOOL parameter.
      query_with_bytes                   <instance_id> <database_id> Queries data using a BYTES parameter.
      query_with_date                    <instance_id> <database_id> Queries data using a DATE parameter.
      query_with_float                   <instance_id> <database_id> Queries data using a FLOAT64 parameter.
      query_with_int                     <instance_id> <database_id> Queries data using a INT64 parameter.
      query_with_string                  <instance_id> <database_id> Queries data using a STRING parameter.
      query_with_timestamp               <instance_id> <database_id> Queries data using a TIMESTAMP parameter.
      query_with_query_options           <instance_id> <database_id> Queries data with query options.
      create_client_with_query_options   <instance_id> <database_id> Create a client with query options.
      write_read_bool_array              <instance_id> <database_id> Writes and read BOOL array.
      write_read_empty_int64_array       <instance_id> <database_id> Writes empty INT64 array and read.
      write_read_null_int64_array        <instance_id> <database_id> Writes nil to INT64 array and read.
      write_read_int64_array             <instance_id> <database_id> Writes INT64 array and read.
      write_read_empty_float64_array     <instance_id> <database_id> Writes empty FLOAT64 array and read.
      write_read_null_float64_array      <instance_id> <database_id> Writes nil to FLOAT64 array and read.
      write_read_float64_array           <instance_id> <database_id> Writes FLOAT64 array and read.
      create_backup                      <instance_id> <database_id> <backup_id> Create a backup.
      restore_backup                     <instance_id> <database_id> <backup_id> Restore a database.
      create_backup_cancel               <instance_id> <database_id> <backup_id> Cancel a backup.
      list_backup_operations             <instance_id> List backup operations.
      list_database_operations           <instance_id> List database operations.
      list_backups                       <instance_id> <backup_id> <database_id> List and filter backups.
      delete_backup                      <instance_id> <backup_id> Delete a backup.
      update_backup                      <instance_id> <backup_id> Update the backup.

    Environment variables:
      GOOGLE_CLOUD_PROJECT must be set to your Google Cloud project ID
  USAGE
end

def run_sample arguments
  command     = arguments.shift
  instance_id = arguments.shift
  database_id = arguments.shift
  project_id  = ENV["GOOGLE_CLOUD_PROJECT"]

  commands = [
    "create_instance", "create_database", "create_table_with_timestamp_column",
    "insert_data", "insert_data_with_timestamp_column", "query_data",
    "query_data_with_timestamp_column", "read_data", "delete_data", "read_stale_data",
    "create_index", "create_storing_index", "add_column", "add_timestamp_column",
    "update_data", "query_data_with_new_column",
    "update_data_with_timestamp_column", "read_write_transaction",
    "query_data_with_index", "read_data_with_index",
    "read_data_with_storing_index", "read_only_transaction",
    "spanner_batch_client", "write_struct_data", "query_with_struct",
    "query_with_array_of_struct", "query_struct_field", "query_nested_struct_field",
    "insert_using_dml", "update_using_dml", "delete_using_dml",
    "update_using_dml_with_timestamp", "write_and_read_using_dml",
    "update_using_dml_with_struct", "write_using_dml", "query_with_parameter",
    "write_with_transaction_using_dml", "update_using_partitioned_dml",
    "delete_using_partitioned_dml", "update_using_batch_dml",
    "create_table_with_datatypes", "write_datatypes_data",
    "query_with_array", "query_with_bool", "query_with_bytes", "query_with_date",
    "query_with_float", "query_with_int", "query_with_string",
    "query_with_timestamp", "query_with_query_options",
    "create_client_with_query_options", "write_read_bool_array",
    "write_read_empty_int64_array", "write_read_null_int64_array",
    "write_read_int64_array", "write_read_empty_float64_array",
    "write_read_null_float64_array", "write_read_float64_array",
    "create_backup", "restore_backup", "create_backup_cancel",
    "list_backup_operations", "list_database_operations", "list_backups",
    "delete_backup", "update_backup_expiration_time"
  ]
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
