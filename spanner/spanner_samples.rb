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

def read_stale_data project_id:, instance_id:, database_id:
  # [START read_stale_data]
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
  # [END read_stale_data]
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
    "CREATE INDEX AlbumsByAlbumTitle2 ON Albums(AlbumTitle)
     STORING (MarketingBudget)"
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
      { SingerId: 1, AlbumId: 1, MarketingBudget: 100_000 },
      { SingerId: 2, AlbumId: 2, MarketingBudget: 500_000 }
    ]
  end

  puts "Updated data"
  # [END update_data]
end

def query_data_with_new_column project_id:, instance_id:, database_id:
  # [START query_data_with_new_column]
  # project_id  = "Your Google Cloud project ID"
  # instance_id = "Your Spanner instance ID"
  # database_id = "Your Spanner database ID"

  require "google/cloud/spanner"

  spanner = Google::Cloud::Spanner.new project: project_id
  client  = spanner.client instance_id, database_id

  client.execute("SELECT SingerId, AlbumId, MarketingBudget FROM Albums").rows.each do |row|
    puts "#{row[:SingerId]} #{row[:AlbumId]} #{row[:MarketingBudget]}"
  end
  # [END query_data_with_new_column]
end

def read_write_transaction project_id:, instance_id:, database_id:
  # [START read_write_transaction]
  # project_id  = "Your Google Cloud project ID"
  # instance_id = "Your Spanner instance ID"
  # database_id = "Your Spanner database ID"

  require "google/cloud/spanner"

  spanner = Google::Cloud::Spanner.new project: project_id
  client  = spanner.client instance_id, database_id

  client.transaction do |transaction|
    first_album  = transaction.read("Albums", [:MarketingBudget], keys: [[1,1]]).rows.first
    second_album = transaction.read("Albums", [:MarketingBudget], keys: [[2,2]]).rows.first

    if second_album[:MarketingBudget] < 300_000
      raise "The second album does not have enough funds to transfer"
    end

    new_first_album_budget  = first_album[:MarketingBudget]  + 200_000
    new_second_album_budget = second_album[:MarketingBudget] - 200_000

    transaction.update "Albums", [
      { SingerId: 1, AlbumId: 1, MarketingBudget: new_first_album_budget  },
      { SingerId: 2, AlbumId: 2, MarketingBudget: new_second_album_budget }
    ]
  end

  puts "Transaction complete"
  # [END read_write_transaction]
end

def query_data_with_index project_id:, instance_id:, database_id:, start_title: "Ardvark", end_title: "Goo"
  # [START query_data_with_index]
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

  result = client.read "Albums", [:AlbumId, :AlbumTitle],
                       index: "AlbumsByAlbumTitle"

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

  result = client.read "Albums", [:AlbumId, :AlbumTitle, :MarketingBudget],
                       index: "AlbumsByAlbumTitle2"

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
  # [END read_only_transaction]
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
  # TODO: What is a pre-executed partition?
  partitions       = batch_snapshot.partition_query "SELECT SingerId, FirstName, LastName FROM Singers"
  total_partitions = partitions.size

  # Enqueue a new thread pool job
  partitions.each_with_index do |partition, partition_index|
    thread_pool.post do
      # Increment total_records per new row
      batch_snapshot.execute_partition(partition).rows.each do |row|
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

def usage
    puts <<-usage
Usage: bundle exec ruby spanner_samples.rb [command] [arguments]

Commands:
  create_database              <instance_id> <database_id> Create Database
  insert_data                  <instance_id> <database_id> Insert Data
  query_data                   <instance_id> <database_id> Query Data
  read_data                    <instance_id> <database_id> Read Data
  read_stale_data              <instance_id> <database_id> Read Stale Data
  create_index                 <instance_id> <database_id> Create Index
  create_storing_index         <instance_id> <database_id> Create Storing Index
  add_column                   <instance_id> <database_id> Add Column
  update_data                  <instance_id> <database_id> Update Data
  query_data_with_new_column   <instance_id> <database_id> Query Data with New Column
  query_data_with_index        <instance_id> <database_id> <start_title> <end_title> Query Data with Index
  read_write_transaction       <instance_id> <database_id> Read-Write Transaction
  read_data_with_index         <instance_id> <database_id> Read Data with Index
  read_data_with_storing_index <instance_id> <database_id> Read Data with Storing Index
  read_only_transaction        <instance_id> <database_id> Read-Only Transaction
  spanner_batch_client         <instance_id> <database_id> Use Spanner batch query with a thread pool

Environment variables:
  GOOGLE_CLOUD_PROJECT must be set to your Google Cloud project ID
    usage
end

def run_sample arguments
  command     = arguments.shift
  instance_id = arguments.shift
  database_id = arguments.shift
  project_id  = ENV["GOOGLE_CLOUD_PROJECT"]

  commands = [
    "create_database", "insert_data", "query_data", "read_data", "read_stale_data",
    "create_index", "create_storing_index", "add_column", "update_data",
    "query_data_with_new_column", "read_write_transaction", "query_data_with_index",
    "read_data_with_index", "read_data_with_storing_index", "read_only_transaction",
    "spanner_batch_client"
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

if __FILE__ == $PROGRAM_NAME
  run_sample ARGV
end
