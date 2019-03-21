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

require_relative "../spanner_samples"
require "rspec"
require "google/cloud/spanner"

describe "Google Cloud Spanner API samples" do
  before do
    if ENV["GOOGLE_CLOUD_SPANNER_TEST_INSTANCE"].nil? || ENV["GOOGLE_CLOUD_SPANNER_PROJECT"].nil?
      skip "GOOGLE_CLOUD_SPANNER_TEST_INSTANCE and/or GOOGLE_CLOUD_SPANNER_PROJECT not defined"
    end

    @project_id  = ENV["GOOGLE_CLOUD_SPANNER_PROJECT"]
    @instance_id = ENV["GOOGLE_CLOUD_SPANNER_TEST_INSTANCE"]
    @seed        = SecureRandom.hex 8
    @database_id = "test_db_#{@seed}"
    @spanner     = Google::Cloud::Spanner.new project: @project_id
    @instance    = @spanner.instance @instance_id
  end

  before :each do
    @test_database = @instance.database @database_id
    @test_database&.drop
  end

  after do
    @test_database = @instance.database @database_id
    @test_database&.drop
  end

  # Creates a temporary database with random ID (will be dropped after test)
  # (re-uses create_database to create database with Albums/Singers schema)
  def create_singers_albums_database
    capture do
      create_database project_id:  @project_id,
                      instance_id: @instance.instance_id,
                      database_id: @database_id

      @test_database = @instance.database @database_id
    end

    @test_database
  end

  def create_performances_table
    capture do
      create_table_with_timestamp_column project_id:  @project_id,
                                         instance_id: @instance.instance_id,
                                         database_id: @database_id
    end
  end

  # Capture and return STDOUT output by block
  def capture
    real_stdout = $stdout
    $stdout = StringIO.new
    yield
    @captured_output = $stdout.string
  ensure
    $stdout = real_stdout
  end
  attr_reader :captured_output

  example "create_database" do
    expect(@instance.databases.map(&:database_id)).not_to include @database_id

    capture do
      create_database project_id:  @project_id,
                      instance_id: @instance.instance_id,
                      database_id: @database_id
    end

    expect(captured_output).to include(
      "Waiting for create database operation to complete"
    )
    expect(captured_output).to include(
      "Created database #{@database_id} on instance #{@instance.instance_id}"
    )

    @test_database = @instance.database @database_id
    expect(@test_database).not_to be nil

    data_definition_statements = @test_database.ddl
    expect(data_definition_statements.size).to  eq 2
    expect(data_definition_statements.first).to include "CREATE TABLE Singers"
    expect(data_definition_statements.last).to  include "CREATE TABLE Albums"
  end

  example "create table with timestamp column" do
    database = create_singers_albums_database

    expect(@instance.databases.map(&:database_id)).to include @database_id

    capture do
      create_table_with_timestamp_column project_id:  @project_id,
                                         instance_id: @instance.instance_id,
                                         database_id: @database_id
    end

    expect(captured_output).to include(
      "Waiting for update database operation to complete"
    )
    expect(captured_output).to include(
      "Created table Performances in #{@database_id}"
    )

    data_definition_statements = database.ddl force: true
    expect(data_definition_statements.size).to eq 3
    expect(data_definition_statements.last).to include "CREATE TABLE Performances"
  end

  example "insert data" do
    database = create_singers_albums_database
    client   = @spanner.client @instance.instance_id, database.database_id

    expect(client.execute("SELECT * FROM Singers").rows.count).to eq 0
    expect(client.execute("SELECT * FROM Albums").rows.count).to  eq 0

    expect {
      insert_data project_id:  @project_id,
                  instance_id: @instance.instance_id,
                  database_id: database.database_id
    }.to output("Inserted data\n").to_stdout

    singers = client.execute("SELECT * FROM Singers").rows.to_a
    expect(singers.count).to eq 5
    expect(singers.find { |s| s[:FirstName] == "Catalina" }).not_to be nil

    albums = client.execute("SELECT * FROM Albums").rows.to_a
    expect(albums.count).to eq 5
    expect(albums.find { |s| s[:AlbumTitle] == "Go, Go, Go" }).not_to be nil
  end

  example "insert data with timestamp column" do
    database = create_singers_albums_database
    create_performances_table
    # Ignore the following capture block
    capture do
      # Insert Singers and Albums (re-use insert_data sample to populate)
      insert_data project_id:  @project_id,
                  instance_id: @instance.instance_id,
                  database_id: database.database_id
    end

    client = @spanner.client @instance.instance_id, database.database_id

    expect(client.execute("SELECT * FROM Performances").rows.count).to eq 0

    expect {
      insert_data_with_timestamp_column project_id:  @project_id,
                                        instance_id: @instance.instance_id,
                                        database_id: database.database_id
    }.to output("Inserted data\n").to_stdout

    performances = client.execute("SELECT * FROM Performances").rows.to_a
    expect(performances.count).to eq 3
  end

  example "query data" do
    database = create_singers_albums_database
    client   = @spanner.client @instance.instance_id, database.database_id

    # Ignore the following capture block
    capture do
      # Insert Singers and Albums (re-use insert_data sample to populate)
      insert_data project_id:  @project_id,
                  instance_id: @instance.instance_id,
                  database_id: database.database_id
    end

    capture do
      query_data project_id:  @project_id,
                 instance_id: @instance.instance_id,
                 database_id: database.database_id
    end

    expect(captured_output).to include "1 1 Total Junk"
    expect(captured_output).to include "1 2 Go, Go, Go"
    expect(captured_output).to include "2 1 Green"
    expect(captured_output).to include "2 2 Forever Hold Your Peace"
    expect(captured_output).to include "2 3 Terrified"
  end

  example "query with struct" do
    database = create_singers_albums_database
    client = @spanner.client @instance.instance_id, database.database_id

    capture do
      write_struct_data project_id:  @project_id,
                        instance_id: @instance.instance_id,
                        database_id: database.database_id
    end

    capture do
      query_with_struct project_id:  @project_id,
                        instance_id: @instance.instance_id,
                        database_id: database.database_id
    end
    expect(captured_output).to match /6/
  end

  example "query with array of struct" do
    database = create_singers_albums_database
    client = @spanner.client @instance.instance_id, database.database_id

    capture do
      write_struct_data project_id:  @project_id,
                        instance_id: @instance.instance_id,
                        database_id: database.database_id
    end

    capture do
      query_with_array_of_struct project_id:  @project_id,
                                 instance_id: @instance.instance_id,
                                 database_id: database.database_id
    end
    expect(captured_output).to match /6\n7/
  end

  example "query struct field" do
    database = create_singers_albums_database
    client = @spanner.client @instance.instance_id, database.database_id

    capture do
      write_struct_data project_id:  @project_id,
                        instance_id: @instance.instance_id,
                        database_id: database.database_id
    end

    capture do
      query_struct_field project_id:  @project_id,
                         instance_id: @instance.instance_id,
                         database_id: database.database_id
    end
    expect(captured_output).to match /6/
  end

  example "query nested struct field" do
    database = create_singers_albums_database
    client = @spanner.client @instance.instance_id, database.database_id

    capture do
      write_struct_data project_id:  @project_id,
                        instance_id: @instance.instance_id,
                        database_id: database.database_id
    end

    capture do
      query_nested_struct_field project_id:  @project_id,
                                instance_id: @instance.instance_id,
                                database_id: database.database_id
    end
    expect(captured_output).to match /6\nImagination\n9\nImagination/
  end

  example "query data_with_timestamp_column" do
    database = create_singers_albums_database
    client   = @spanner.client @instance.instance_id, database.database_id

    # Ignore the following capture block
    capture do
      # Insert Singers and Albums (re-use insert_data sample to populate)
      insert_data project_id:  @project_id,
                  instance_id: @instance.instance_id,
                  database_id: database.database_id

      add_column project_id:  @project_id,
                 instance_id: @instance.instance_id,
                 database_id: database.database_id

      update_data project_id:  @project_id,
                  instance_id: @instance.instance_id,
                  database_id: database.database_id

      add_timestamp_column project_id:  @project_id,
                           instance_id: @instance.instance_id,
                           database_id: database.database_id

      update_data_with_timestamp_column project_id:  @project_id,
                                        instance_id: @instance.instance_id,
                                        database_id: database.database_id
    end

    capture do
      query_data_with_timestamp_column project_id:  @project_id,
                                       instance_id: @instance.instance_id,
                                       database_id: database.database_id
    end

    expect(captured_output).to match /1 1 100000 \d+/
  end

  example "read data" do
    database = create_singers_albums_database
    client   = @spanner.client @instance.instance_id, database.database_id

    # Ignore the following capture block
    capture do
      # Insert Singers and Albums (re-use insert_data sample to populate)
      insert_data project_id:  @project_id,
                  instance_id: @instance.instance_id,
                  database_id: database.database_id
    end

    capture do
      read_data project_id:  @project_id,
                instance_id: @instance.instance_id,
                database_id: database.database_id
    end

    expect(captured_output).to include "1 1 Total Junk"
    expect(captured_output).to include "1 2 Go, Go, Go"
    expect(captured_output).to include "2 1 Green"
    expect(captured_output).to include "2 2 Forever Hold Your Peace"
    expect(captured_output).to include "2 3 Terrified"
  end

  example "read stale data" do
    database = create_singers_albums_database
    client   = @spanner.client @instance.instance_id, database.database_id

    # Ignore the following capture block
    capture do
      # Insert Singers and Albums (re-use insert_data sample to populate)
      insert_data project_id:  @project_id,
                  instance_id: @instance.instance_id,
                  database_id: database.database_id
    end

    capture do
      read_stale_data project_id:  @project_id,
                      instance_id: @instance.instance_id,
                      database_id: database.database_id
    end

    expect(captured_output).not_to include "1 1 Total Junk"
    expect(captured_output).not_to include "1 2 Go, Go, Go"
    expect(captured_output).not_to include "2 1 Green"
    expect(captured_output).not_to include "2 2 Forever Hold Your Peace"
    expect(captured_output).not_to include "2 3 Terrified"

    sleep 16 # read_stale_data expects staleness of at least 15 seconds

    capture do
      read_stale_data project_id:  @project_id,
                      instance_id: @instance.instance_id,
                      database_id: database.database_id
    end

    expect(captured_output).to include "1 1 Total Junk"
    expect(captured_output).to include "1 2 Go, Go, Go"
    expect(captured_output).to include "2 1 Green"
    expect(captured_output).to include "2 2 Forever Hold Your Peace"
    expect(captured_output).to include "2 3 Terrified"
  end

  example "create index" do
    database = create_singers_albums_database

    expect(database.ddl(force: true).join).not_to include(
      "CREATE INDEX AlbumsByAlbumTitle ON Albums(AlbumTitle)"
    )

    capture do
      create_index project_id:  @project_id,
                   instance_id: @instance.instance_id,
                   database_id: database.database_id
    end

    expect(captured_output).to include "Waiting for database update to complete"
    expect(captured_output).to include "Added the AlbumsByAlbumTitle index"

    expect(database.ddl(force: true).join).to include(
      "CREATE INDEX AlbumsByAlbumTitle ON Albums(AlbumTitle)"
    )
  end

  example "create storing index" do
    database = create_singers_albums_database

    # Ignore the following capture block
    capture do
      # Add MarketingBudget column (re-use add_column to add)
      add_column project_id:  @project_id,
                 instance_id: @instance.instance_id,
                 database_id: database.database_id
    end

    expect(database.ddl(force: true).join).not_to include(
      "CREATE INDEX AlbumsByAlbumTitle2 ON Albums(AlbumTitle) STORING (MarketingBudget)"
    )

    capture do
      create_storing_index project_id:  @project_id,
                           instance_id: @instance.instance_id,
                           database_id: database.database_id
    end

    expect(captured_output).to include "Waiting for database update to complete"
    expect(captured_output).to include "Added the AlbumsByAlbumTitle2 storing index"

    expect(database.ddl(force: true).join).to include(
      "CREATE INDEX AlbumsByAlbumTitle2 ON Albums(AlbumTitle) STORING (MarketingBudget)"
    )
  end

  example "add column" do
    database = create_singers_albums_database

    expect(database.ddl(force: true).join).not_to include(
      "MarketingBudget INT64"
    )

    capture do
      add_column project_id:  @project_id,
                 instance_id: @instance.instance_id,
                 database_id: database.database_id
    end

    expect(database.ddl(force: true).join).to include(
      "MarketingBudget INT64"
    )
  end

  example "add column timestamp column" do
    database = create_singers_albums_database

    expect(database.ddl(force: true).join).not_to include(
      "MarketingBudget INT64"
    )

    capture do
      add_timestamp_column project_id:  @project_id,
                           instance_id: @instance.instance_id,
                           database_id: database.database_id
    end

    expect(database.ddl(force: true).join).to include(
      "LastUpdateTime TIMESTAMP"
    )
  end

  example "update data" do
    database = create_singers_albums_database
    client   = @spanner.client @instance.instance_id, database.database_id

    # Ignore the following capture block
    capture do
      # Insert Singers and Albums (re-use insert_data sample to populate)
      insert_data project_id:  @project_id,
                  instance_id: @instance.instance_id,
                  database_id: database.database_id
    end

    # Add MarketingBudget column (re-use add_column to add)
    capture do
      add_column project_id:  @project_id,
                 instance_id: @instance.instance_id,
                 database_id: database.database_id
    end

    albums = client.execute("SELECT * FROM Albums").rows.map &:to_h
    expect(albums).to include(
      SingerId: 1, AlbumId: 1, AlbumTitle: "Total Junk", MarketingBudget: nil
    )

    capture do
      update_data project_id:  @project_id,
                  instance_id: @instance.instance_id,
                  database_id: database.database_id
    end

    expect(captured_output).to include "Updated data"

    albums = client.execute("SELECT * FROM Albums").rows.map &:to_h
    expect(albums).to include(
      SingerId: 1, AlbumId: 1, AlbumTitle: "Total Junk", MarketingBudget: 100_000
    )
  end

  example "update data with timestamp column" do
    database = create_singers_albums_database
    client   = @spanner.client @instance.instance_id, database.database_id

    # Ignore the following capture block
    capture do
      # Insert Singers and Albums (re-use insert_data sample to populate)
      insert_data project_id:  @project_id,
                  instance_id: @instance.instance_id,
                  database_id: database.database_id

      # Add MarketingBudget column (re-use add_column to add)
      add_column project_id:  @project_id,
                 instance_id: @instance.instance_id,
                 database_id: database.database_id

      # Add Timestamp column
      add_timestamp_column project_id:  @project_id,
                           instance_id: @instance.instance_id,
                           database_id: database.database_id
    end

    albums = client.execute("SELECT * FROM Albums").rows.map &:to_h
    expect(albums).to include(
      SingerId: 1, AlbumId: 1, AlbumTitle: "Total Junk", MarketingBudget: nil, LastUpdateTime: nil
    )

    capture do
      update_data_with_timestamp_column project_id:  @project_id,
                                        instance_id: @instance.instance_id,
                                        database_id: database.database_id
    end

    expect(captured_output).to include "Updated data"

    albums = client.execute("SELECT * FROM Albums").rows.map &:to_h
    expect(albums).not_to include(
      LastUpdateTime: nil
    )
  end

  example "query data with new column" do
    database = create_singers_albums_database
    client   = @spanner.client @instance.instance_id, database.database_id

    # Ignore the following capture block
    capture do
      # Insert Singers and Albums (re-use insert_data sample to populate)
      insert_data project_id:  @project_id,
                  instance_id: @instance.instance_id,
                  database_id: database.database_id

      # Add MarketingBudget column (re-use add_column to add)
      add_column project_id:  @project_id,
                 instance_id: @instance.instance_id,
                 database_id: database.database_id

      # Add data to MarketingBudget column (re-use update_data to populate)
      update_data project_id:  @project_id,
                  instance_id: @instance.instance_id,
                  database_id: database.database_id
    end

    capture do
      query_data_with_new_column project_id:  @project_id,
                                 instance_id: @instance.instance_id,
                                 database_id: database.database_id
    end

    expect(captured_output).to include "1 1 100000"
    expect(captured_output).to include "1 2"
    expect(captured_output).to include "2 1"
    expect(captured_output).to include "2 2 500000"
    expect(captured_output).to include "2 3"
  end

  example "read/write transaction (successful transfer)" do
    database = create_singers_albums_database
    client   = @spanner.client @instance.instance_id, database.database_id

    # Ignore the following capture block
    capture do
      # Insert Singers and Albums (re-use insert_data sample to populate)
      insert_data project_id:  @project_id,
                  instance_id: @instance.instance_id,
                  database_id: database.database_id

      # Add MarketingBudget column (re-use add_column to add)
      add_column project_id:  @project_id,
                 instance_id: @instance.instance_id,
                 database_id: database.database_id

      # Second Album(2, 2) needs at least $300,000 to transfer successfully
      # to Album(1, 1). This should transfer successfully.
      client.commit do |c|
        c.update "Albums", [
          { SingerId: 1, AlbumId: 1, MarketingBudget: 100_000 },
          { SingerId: 2, AlbumId: 2, MarketingBudget: 300_000 }
        ]
      end
    end

    capture do
      read_write_transaction project_id:  @project_id,
                             instance_id: @instance.instance_id,
                             database_id: database.database_id
    end

    expect(captured_output).to include "Transaction complete"

    first_album  = client.read("Albums", [:MarketingBudget], keys: [[1, 1]]).rows.first
    second_album = client.read("Albums", [:MarketingBudget], keys: [[2, 2]]).rows.first

    expect(first_album[:MarketingBudget]).to  eq 300_000
    expect(second_album[:MarketingBudget]).to eq 100_000
  end

  example "read/write transaction (not enough funds)" do
    database = create_singers_albums_database
    client   = @spanner.client @instance.instance_id, database.database_id

    # Ignore the following capture block
    capture do
      # Insert Singers and Albums (re-use insert_data sample to populate)
      insert_data project_id:  @project_id,
                  instance_id: @instance.instance_id,
                  database_id: database.database_id

      # Add MarketingBudget column (re-use add_column to add)
      add_column project_id:  @project_id,
                 instance_id: @instance.instance_id,
                 database_id: database.database_id

      # Second Album(2, 2) needs at least $300,000 to transfer successfully
      # to Album(1, 1). Without enough funds, an exception should be raised.
      client.commit do |c|
        c.update "Albums", [
          { SingerId: 1, AlbumId: 1, MarketingBudget: 100_000 },
          { SingerId: 2, AlbumId: 2, MarketingBudget: 299_999 }
        ]
      end
    end

    expect {
      read_write_transaction project_id:  @project_id,
                             instance_id: @instance.instance_id,
                             database_id: database.database_id
    }.to raise_error("The second album does not have enough funds to transfer")
  end

  example "query data with index" do
    database = create_singers_albums_database
    client   = @spanner.client @instance.instance_id, database.database_id

    # Ignore the following capture block
    capture do
      # Insert Singers and Albums (re-use insert_data sample to populate)
      insert_data project_id:  @project_id,
                  instance_id: @instance.instance_id,
                  database_id: database.database_id

      # Add MarketingBudget column (re-use add_column to add)
      add_column project_id:  @project_id,
                 instance_id: @instance.instance_id,
                 database_id: database.database_id

      # Add index on Albums(AlbumTitle) (re-use create_index to add)
      create_index project_id:  @project_id,
                   instance_id: @instance.instance_id,
                   database_id: database.database_id
    end

    capture do
      query_data_with_index project_id:  @project_id,
                            instance_id: @instance.instance_id,
                            database_id: database.database_id
    end

    expect(captured_output).to include "2 Go, Go, Go"
    expect(captured_output).to include "2 Forever Hold Your Peace"
  end

  example "read data with index" do
    database = create_singers_albums_database
    client   = @spanner.client @instance.instance_id, database.database_id

    # Ignore the following capture block
    capture do
      # Insert Singers and Albums (re-use insert_data sample to populate)
      insert_data project_id:  @project_id,
                  instance_id: @instance.instance_id,
                  database_id: database.database_id

      # Add MarketingBudget column (re-use add_column to add)
      add_column project_id:  @project_id,
                 instance_id: @instance.instance_id,
                 database_id: database.database_id

      # Add index on Albums(AlbumTitle) (re-use create_index to add)
      create_index project_id:  @project_id,
                   instance_id: @instance.instance_id,
                   database_id: database.database_id
    end

    capture do
      read_data_with_index project_id:  @project_id,
                           instance_id: @instance.instance_id,
                           database_id: database.database_id
    end

    expect(captured_output).to include "1 Total Junk"
    expect(captured_output).to include "2 Forever Hold Your Peace"
  end

  example "read data with storing index" do
    database = create_singers_albums_database
    client   = @spanner.client @instance.instance_id, database.database_id

    # Ignore the following capture block
    capture do
      # Insert Singers and Albums (re-use insert_data sample to populate)
      insert_data project_id:  @project_id,
                  instance_id: @instance.instance_id,
                  database_id: database.database_id

      # Add MarketingBudget column (re-use add_column to add)
      add_column project_id:  @project_id,
                 instance_id: @instance.instance_id,
                 database_id: database.database_id

      # Add index on Albums(AlbumTitle) (re-use create_index to add)
      create_storing_index project_id:  @project_id,
                           instance_id: @instance.instance_id,
                           database_id: database.database_id
    end

    capture do
      read_data_with_storing_index project_id:  @project_id,
                                   instance_id: @instance.instance_id,
                                   database_id: database.database_id
    end

    expect(captured_output).to include "1 Total Junk"
    expect(captured_output).to include "2 Forever Hold Your Peace"
  end

  example "read only transaction" do
    database = create_singers_albums_database
    client   = @spanner.client @instance.instance_id, database.database_id

    # Ignore the following capture block
    capture do
      # Insert Singers and Albums (re-use insert_data sample to populate)
      insert_data project_id:  @project_id,
                  instance_id: @instance.instance_id,
                  database_id: database.database_id
    end

    capture do
      read_only_transaction project_id:  @project_id,
                            instance_id: @instance.instance_id,
                            database_id: database.database_id
    end

    expect(captured_output).to include "1 Total Junk 1"
    expect(captured_output).to include "2 Forever Hold Your Peace 2"
  end

  example "batch client read partitions across threads" do
    database = create_singers_albums_database
    client   = @spanner.client @instance.instance_id, database.database_id

    # Ignore the following capture block
    capture do
      # Insert Singers and Albums (re-use insert_data sample to populate)
      insert_data project_id:  @project_id,
                  instance_id: @instance.instance_id,
                  database_id: database.database_id
    end

    capture do
      spanner_batch_client project_id:  @project_id,
                           instance_id: @instance.instance_id,
                           database_id: database.database_id
    end

    expect(captured_output).to include "Total Records: 5"
  end

  example "insert data using dml" do
    database = create_singers_albums_database
    # Ignore the following capture block
    capture do
      # Insert Singers and Albums (re-use insert_data sample to populate)
      insert_data project_id:  @project_id,
                  instance_id: @instance.instance_id,
                  database_id: database.database_id
    end

    client = @spanner.client @instance.instance_id, database.database_id

    expect(client.execute("SELECT * FROM Singers").rows.count).to eq 5

    expect {
      insert_using_dml project_id:  @project_id,
                       instance_id: @instance.instance_id,
                       database_id: database.database_id
    }.to output("1 record inserted.\n").to_stdout

    singers = client.execute("SELECT * FROM Singers").rows.to_a
    expect(singers.count).to eq 6
    expect(singers.find { |s| s[:FirstName] == "Virginia" }).not_to be nil
  end

  example "update using dml" do
    database = create_singers_albums_database
    client   = @spanner.client @instance.instance_id, database.database_id

    # Ignore the following capture block
    capture do
      # Insert Singers and Albums (re-use insert_data sample to populate)
      insert_data project_id:  @project_id,
                  instance_id: @instance.instance_id,
                  database_id: database.database_id

      # Add MarketingBudget column (re-use add_column to add)
      add_column project_id:  @project_id,
                 instance_id: @instance.instance_id,
                 database_id: database.database_id

      # First Album(1, 1) set MarketingBudget to $300,000
      client.commit do |c|
        c.update "Albums", [
          { SingerId: 1, AlbumId: 1, MarketingBudget: 300_000 }
        ]
      end
    end

    capture do
      update_using_dml project_id:  @project_id,
                       instance_id: @instance.instance_id,
                       database_id: database.database_id
    end

    expect(captured_output).to include "1 record updated."

    first_album = client.read("Albums", [:MarketingBudget], keys: [[1, 1]]).rows.first

    expect(first_album[:MarketingBudget]).to eq 600_000
  end

  example "delete data using dml" do
    database = create_singers_albums_database
    # Ignore the following capture block
    capture do
      # Insert Singers and Albums (re-use insert_data sample to populate)
      insert_data project_id:  @project_id,
                  instance_id: @instance.instance_id,
                  database_id: database.database_id
    end

    client = @spanner.client @instance.instance_id, database.database_id

    expect(client.execute("SELECT * FROM Singers").rows.count).to eq 5

    expect {
      delete_using_dml project_id:  @project_id,
                       instance_id: @instance.instance_id,
                       database_id: database.database_id
    }.to output("1 record deleted.\n").to_stdout

    singers = client.execute("SELECT * FROM Singers").rows.to_a
    expect(singers.count).to eq 4
    expect(singers.find { |s| s[:FirstName] == "Alice" }).to be_nil
  end

  example "update data using dml with timestamp column" do
    database = create_singers_albums_database
    client   = @spanner.client @instance.instance_id, database.database_id

    # Ignore the following capture block
    capture do
      # Insert Singers and Albums (re-use insert_data sample to populate)
      insert_data project_id:  @project_id,
                  instance_id: @instance.instance_id,
                  database_id: database.database_id

      # Add MarketingBudget column (re-use add_column to add)
      add_column project_id:  @project_id,
                 instance_id: @instance.instance_id,
                 database_id: database.database_id

      # Add Timestamp column
      add_timestamp_column project_id:  @project_id,
                           instance_id: @instance.instance_id,
                           database_id: database.database_id
    end

    original_timestamp = client.read("Albums", [:LastUpdateTime], keys: [[1, 1]]).rows.first.to_h
    capture do
      update_using_dml_with_timestamp project_id:  @project_id,
                                      instance_id: @instance.instance_id,
                                      database_id: database.database_id
    end
    expect(captured_output).to include "2 records updated."
    updated_timestamp = client.read("Albums", [:LastUpdateTime], keys: [[1, 1]]).rows.first.to_h
    expect(original_timestamp[:LastUpdateTime].to_i < updated_timestamp[:LastUpdateTime].to_i).to be true
  end

  example "write and read data using dml" do
    database = create_singers_albums_database
    # Ignore the following capture block
    capture do
      # Insert Singers and Albums (re-use insert_data sample to populate)
      insert_data project_id:  @project_id,
                  instance_id: @instance.instance_id,
                  database_id: database.database_id
    end

    client = @spanner.client @instance.instance_id, database.database_id

    expect(client.execute("SELECT * FROM Singers").rows.count).to eq 5

    expect {
      write_and_read_using_dml project_id:  @project_id,
                               instance_id: @instance.instance_id,
                               database_id: database.database_id
    }.to output(/1 record updated.\nTimothy Campbell\n/).to_stdout

    singers = client.execute("SELECT * FROM Singers").rows.to_a
    expect(singers.count).to eq 6
  end

  example "update data using dml with struct" do
    database = create_singers_albums_database
    # Ignore the following capture block
    capture do
      # Insert Singers and Albums (re-use insert_data sample to populate)
      insert_data project_id:  @project_id,
                  instance_id: @instance.instance_id,
                  database_id: database.database_id

      # Insert single Singer record to be updated
      write_and_read_using_dml project_id:  @project_id,
                               instance_id: @instance.instance_id,
                               database_id: database.database_id
    end

    client = @spanner.client @instance.instance_id, database.database_id

    expect(client.execute("SELECT * FROM Singers").rows.count).to eq 6

    expect {
      update_using_dml_with_struct project_id:  @project_id,
                                   instance_id: @instance.instance_id,
                                   database_id: database.database_id
    }.to output("1 record updated.\n").to_stdout

    singers = client.execute("SELECT * FROM Singers").rows.to_a
    expect(singers.count).to eq 6
    expect(singers.find { |s| s[:LastName] == "Grant" }).not_to be nil
  end

  example "insert multiple records using dml" do
    database = create_singers_albums_database
    # Ignore the following capture block
    capture do
      # Insert Singers and Albums (re-use insert_data sample to populate)
      insert_data project_id:  @project_id,
                  instance_id: @instance.instance_id,
                  database_id: database.database_id
    end

    client = @spanner.client @instance.instance_id, database.database_id

    expect(client.execute("SELECT * FROM Singers").rows.count).to eq 5

    expect {
      write_using_dml project_id:  @project_id,
                      instance_id: @instance.instance_id,
                      database_id: database.database_id
    }.to output("4 records inserted.\n").to_stdout

    singers = client.execute("SELECT * FROM Singers").rows.to_a
    expect(singers.count).to eq 9
    expect(singers.find { |s| s[:FirstName] == "Dylan" }).not_to be nil
  end

  example "write with transaction using dml (successful transfer)" do
    database = create_singers_albums_database
    client   = @spanner.client @instance.instance_id, database.database_id

    # Ignore the following capture block
    capture do
      # Insert Singers and Albums (re-use insert_data sample to populate)
      insert_data project_id:  @project_id,
                  instance_id: @instance.instance_id,
                  database_id: database.database_id

      # Add MarketingBudget column (re-use add_column to add)
      add_column project_id:  @project_id,
                 instance_id: @instance.instance_id,
                 database_id: database.database_id

      # First Album(1, 1) needs at least $300,000 to transfer successfully
      # to Album(2, 2). This should transfer successfully.
      client.commit do |c|
        c.update "Albums", [
          { SingerId: 1, AlbumId: 1, MarketingBudget: 300_000 },
          { SingerId: 2, AlbumId: 2, MarketingBudget: 100_000 }
        ]
      end
    end

    capture do
      write_with_transaction_using_dml project_id:  @project_id,
                                       instance_id: @instance.instance_id,
                                       database_id: database.database_id
    end

    first_album  = client.read("Albums", [:MarketingBudget], keys: [[1, 1]]).rows.first
    second_album = client.read("Albums", [:MarketingBudget], keys: [[2, 2]]).rows.first

    expect(first_album[:MarketingBudget]).to  eq 100_000
    expect(second_album[:MarketingBudget]).to eq 300_000
  end

  example "update data using partioned dml" do
    database = create_singers_albums_database
    client   = @spanner.client @instance.instance_id, database.database_id

    # Ignore the following capture block
    capture do
      # Insert Singers and Albums (re-use insert_data sample to populate)
      insert_data project_id:  @project_id,
                  instance_id: @instance.instance_id,
                  database_id: database.database_id

      # Add MarketingBudget column (re-use add_column to add)
      add_column project_id:  @project_id,
                 instance_id: @instance.instance_id,
                 database_id: database.database_id
    end

    capture do
      update_using_partitioned_dml project_id:  @project_id,
                                   instance_id: @instance.instance_id,
                                   database_id: database.database_id
    end

    first_album  = client.read("Albums", [:MarketingBudget], keys: [[2, 1]]).rows.first
    second_album = client.read("Albums", [:MarketingBudget], keys: [[2, 2]]).rows.first
    third_album = client.read("Albums", [:MarketingBudget], keys: [[2, 3]]).rows.first

    expect(first_album[:MarketingBudget]).to  eq 100_000
    expect(second_album[:MarketingBudget]).to eq 100_000
    expect(third_album[:MarketingBudget]).to eq 100_000
  end

  example "delete multiple records using dml" do
    database = create_singers_albums_database
    # Ignore the following capture block
    capture do
      # Insert Singers and Albums (re-use insert_data sample to populate)
      insert_data project_id:  @project_id,
                  instance_id: @instance.instance_id,
                  database_id: database.database_id

      # Insert additinal multiple records into Singers table
      write_using_dml project_id:  @project_id,
                      instance_id: @instance.instance_id,
                      database_id: database.database_id
    end

    client = @spanner.client @instance.instance_id, database.database_id

    expect(client.execute("SELECT * FROM Singers").rows.count).to eq 9

    expect {
      delete_using_partitioned_dml project_id:  @project_id,
                                   instance_id: @instance.instance_id,
                                   database_id: database.database_id
    }.to output("4 records deleted.\n").to_stdout

    singers = client.execute("SELECT * FROM Singers").rows.to_a
    expect(singers.count).to eq 5
    expect(singers.find { |s| s[:FirstName] == "Melissa" }).to be_nil
  end
end
