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

require_relative "./spec_helper"

describe "Google Cloud Spanner API samples" do
  before :each do
    cleanup_database_resources
  end

  after :each do
    cleanup_database_resources
    cleanup_instance_resources
  end

  example "create_instance" do
    instance_id = "rb-test-#{seed}"
    @created_instance_ids << instance_id

    capture do
      create_instance project_id:  @project_id,
                      instance_id: instance_id
    end

    expect(captured_output).to include(
      "Waiting for create instance operation to complete"
    )
    expect(captured_output).to include(
      "Created instance #{instance_id}"
    )
  end

  example "create_instance_with_processing_units" do
    instance_id = "rb-test-pu-#{seed}"
    @created_instance_ids << instance_id

    capture do
      create_instance_with_processing_units project_id: @project_id,
                                            instance_id: instance_id
    end

    expect(captured_output).to include(
      "Waiting for creating instance operation to complete"
    )
    expect(captured_output).to include(
      "Instance #{instance_id} has 500 processing units."
    )
  end

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

    expect(data_definition_statements.size).to eq 2

    expect(data_definition_statements).to include(match "CREATE TABLE Singers")
    expect(data_definition_statements).to include(match "CREATE TABLE Albums")
  end

  example "create_database_with_version_retention_period" do
    expect(@instance.databases.map(&:database_id)).not_to include @database_id

    capture do
      create_database_with_version_retention_period project_id:  @project_id,
                                                    instance_id: @instance.instance_id,
                                                    database_id: @database_id
    end

    expect(captured_output).to include(
      "Waiting for create database operation to complete"
    )
    expect(captured_output).to include(
      "Created database #{@database_id} on instance #{@instance.instance_id}"
    )
    expect(captured_output).to include(
      "\tVersion retention period: 7d"
    )

    @test_database = @instance.database @database_id
    expect(@test_database).not_to be nil

    data_definition_statements = @test_database.ddl

    expect(data_definition_statements.size).to eq 3

    expect(data_definition_statements).to include(match "CREATE TABLE Singers")
    expect(data_definition_statements).to include(match "CREATE TABLE Albums")
    expect(data_definition_statements).to include(match "version_retention_period = '7d'")
  end

  example "create_database_with_encryption_key" do
    expect(@instance.databases.map(&:database_id)).not_to include @database_id

    kms_key_name = "projects/#{@project_id}/locations/us-central1/keyRings/spanner-test-keyring/cryptoKeys/spanner-test-cmek"

    capture do
      create_database_with_encryption_key project_id:  @project_id,
                                          instance_id: @instance.instance_id,
                                          database_id: @database_id,
                                          kms_key_name: kms_key_name
    end

    expect(captured_output).to include(
      "Database #{@database_id} created with encryption key #{kms_key_name}"
    )
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
    expect(captured_output).to include "8"
    expect(captured_output).to include "7"
    expect(captured_output).to include "6"
  end

  example "query struct field" do
    database = create_singers_albums_database

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

  example "query data with timestamp column" do
    database = create_singers_albums_database

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

  example "delete data" do
    database = create_singers_albums_database

    # Ignore the following capture block
    capture do
      # Insert Singers and Albums (re-use insert_data sample to populate)
      insert_data project_id:  @project_id,
                  instance_id: @instance.instance_id,
                  database_id: database.database_id
    end

    capture do
      delete_data project_id:  @project_id,
                instance_id: @instance.instance_id,
                database_id: database.database_id
    end

    capture do
      read_data project_id:  @project_id,
                instance_id: @instance.instance_id,
                database_id: database.database_id
    end

    client = @spanner.client @instance.instance_id, database.database_id

    expect(client.execute("SELECT * FROM Singers").rows.count).to eq 0
    expect(client.execute("SELECT * FROM Albums").rows.count).to eq 0
  end

  example "read stale data" do
    database = create_singers_albums_database

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

      # Second Album(2, 2) needs at least $200,000 to transfer successfully
      # to Album(1, 1). This should transfer successfully.
      client.commit do |c|
        c.update "Albums", [
          { SingerId: 1, AlbumId: 1, MarketingBudget: 100_000 },
          { SingerId: 2, AlbumId: 2, MarketingBudget: 500_000 }
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
    expect(second_album[:MarketingBudget]).to eq 300_000
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

      # Second Album(2, 2) needs at least $200,000 to transfer successfully
      # to Album(1, 1). Without enough funds, an exception should be raised.
      client.commit do |c|
        c.update "Albums", [
          { SingerId: 1, AlbumId: 1, MarketingBudget: 100_000 },
          { SingerId: 2, AlbumId: 2, MarketingBudget: 199_999 }
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
    }.to output("14 records inserted.\n").to_stdout

    singers = client.execute("SELECT * FROM Singers").rows.to_a
    expect(singers.count).to eq 19
    expect(singers.find { |s| s[:FirstName] == "Dylan" }).not_to be nil

    expect {
      query_with_parameter project_id:  @project_id,
                           instance_id: @instance.instance_id,
                           database_id: database.database_id
    }.to output("12 Melissa Garcia\n").to_stdout
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

      # First Album(2, 2) needs at least $200,000 to transfer successfully
      # to Album(1, 1). This should transfer successfully.
      client.commit do |c|
        c.update "Albums", [
          { SingerId: 1, AlbumId: 1, MarketingBudget: 100_000 },
          { SingerId: 2, AlbumId: 2, MarketingBudget: 500_000 }
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

    expect(first_album[:MarketingBudget]).to  eq 300_000
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

    expect(client.execute("SELECT * FROM Singers").rows.count).to eq 19

    expect {
      delete_using_partitioned_dml project_id:  @project_id,
                                   instance_id: @instance.instance_id,
                                   database_id: database.database_id
    }.to output("14 records deleted.\n").to_stdout

    singers = client.execute("SELECT * FROM Singers").rows.to_a
    expect(singers.count).to eq 5
    expect(singers.find { |s| s[:FirstName] == "Melissa" }).to be_nil
  end

  example "insert and update a record using batch dml" do
    database = create_singers_albums_database
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

    client = @spanner.client @instance.instance_id, database.database_id

    expect(client.execute("SELECT * FROM Albums").rows.count).to eq 5

    expect {
      update_using_batch_dml project_id:  @project_id,
                      instance_id: @instance.instance_id,
                      database_id: database.database_id
    }.to output("Executed 2 SQL statements using Batch DML.\n").to_stdout

    albums = client.execute("SELECT * FROM Albums").rows.to_a
    expect(albums.count).to eq 6
    expect(albums.find {|s| s[:AlbumTitle] == "Test Album Title" }).not_to be nil

    album  = client.read("Albums", [:MarketingBudget], keys: [[1,3]]).rows.first
    expect(album[:MarketingBudget]).to  eq 20_000
  end

  example "create table with supported datatypes columns" do
    database = create_singers_albums_database

    expect(@instance.databases.map(&:database_id)).to include @database_id

    capture do
      create_table_with_datatypes project_id:  @project_id,
                                  instance_id: @instance.instance_id,
                                  database_id: @database_id
    end

    expect(captured_output).to include(
      "Waiting for update database operation to complete"
    )
    expect(captured_output).to include(
      "Created table Venues in #{@database_id}"
    )

    data_definition_statements = database.ddl force: true
    expect(data_definition_statements.size).to eq 3
    expect(data_definition_statements.last).to include "CREATE TABLE Venues"
  end

  example "insert datatypes data" do
    database = create_singers_albums_database
    create_venues_table

    client = @spanner.client @instance.instance_id, database.database_id

    expect(client.execute("SELECT * FROM Venues").rows.count).to eq 0

    expect {
      write_datatypes_data project_id:  @project_id,
                           instance_id: @instance.instance_id,
                           database_id: database.database_id
    }.to output("Inserted data\n").to_stdout

    venues = client.execute("SELECT * FROM Venues").rows.to_a
    expect(venues.count).to eq 3
  end

  example "query data with datatypes" do
    database = create_singers_albums_database
    create_venues_table

   # Ignore the following capture block
    capture do
      write_datatypes_data project_id:  @project_id,
                           instance_id: @instance.instance_id,
                           database_id: database.database_id
    end

    capture do
      query_with_array project_id:  @project_id,
                       instance_id: @instance.instance_id,
                       database_id: database.database_id
    end

    expect(captured_output).to include "19 Venue 19 2020-11-01"
    expect(captured_output).to include "42 Venue 42 2020-10-01"

    capture do
      query_with_bool project_id:  @project_id,
                      instance_id: @instance.instance_id,
                      database_id: database.database_id
    end

    expect(captured_output).to include "19 Venue 19 true"

    capture do
      query_with_bytes project_id:  @project_id,
                      instance_id: @instance.instance_id,
                      database_id: database.database_id
    end

    expect(captured_output).to include "4 Venue 4"

    capture do
      query_with_date project_id:  @project_id,
                      instance_id: @instance.instance_id,
                      database_id: database.database_id
    end

    expect(captured_output).to include "4 Venue 4 2018-09-02"
    expect(captured_output).to include "42 Venue 42 2018-10-01"

    capture do
      query_with_float project_id:  @project_id,
                      instance_id: @instance.instance_id,
                      database_id: database.database_id
    end

    expect(captured_output).to include "4 Venue 4 0.8"
    expect(captured_output).to include "19 Venue 19 0.9"

    capture do
      query_with_int project_id:  @project_id,
                      instance_id: @instance.instance_id,
                      database_id: database.database_id
    end

    expect(captured_output).to include "19 Venue 19 6300"
    expect(captured_output).to include "42 Venue 42 3000"

    capture do
      query_with_string project_id:  @project_id,
                      instance_id: @instance.instance_id,
                      database_id: database.database_id
    end

    expect(captured_output).to include "42 Venue 42"

    capture do
      query_with_timestamp project_id:  @project_id,
                      instance_id: @instance.instance_id,
                      database_id: database.database_id
    end

    expect(captured_output).to include "4 Venue 4"
    expect(captured_output).to include "19 Venue 19"
    expect(captured_output).to include "42 Venue 42"
  end

  example "query data with query options" do
    database = create_singers_albums_database
    create_venues_table

    # Ignore the following capture block
    capture do
      write_datatypes_data project_id:  @project_id,
                           instance_id: @instance.instance_id,
                           database_id: database.database_id
    end

    capture do
      query_with_query_options project_id:  @project_id,
                      instance_id: @instance.instance_id,
                      database_id: database.database_id
    end

    expect(captured_output).to include "4 Venue 4"
    expect(captured_output).to include "19 Venue 19"
    expect(captured_output).to include "42 Venue 42"

    capture do
      create_client_with_query_options project_id:  @project_id,
                      instance_id: @instance.instance_id,
                      database_id: database.database_id
    end

    expect(captured_output).to include "4 Venue 4"
    expect(captured_output).to include "19 Venue 19"
    expect(captured_output).to include "42 Venue 42"
  end

  example "query data with numeric column" do
    database = create_singers_albums_database
    create_venues_table

    # Ignore the following capture block
    capture do
      write_datatypes_data project_id:  @project_id,
                            instance_id: @instance.instance_id,
                            database_id: database.database_id
    end

    capture do
      add_numeric_column project_id:  @project_id,
                         instance_id: @instance.instance_id,
                         database_id: database.database_id
    end

    expect(captured_output).to include "Added the Revenue as a numeric column in Venues table"

    capture do
      update_data_with_numeric_column project_id:  @project_id,
                                      instance_id: @instance.instance_id,
                                      database_id: database.database_id
    end

    expect(captured_output).to include "Updated data"

    capture do
      query_with_numeric_parameter project_id:  @project_id,
                                   instance_id: @instance.instance_id,
                                   database_id: database.database_id
    end

    expect(captured_output).to include "4 0.35e5"
  end

  example "write data with array types and read" do
    database = create_boxes_database

    capture do
      write_read_bool_array project_id: @project_id,
                            instance_id: @instance.instance_id,
                            database_id: database.database_id
    end

    expect(captured_output.split("\n")).to match_array(["true", "false", "true"])

    capture do
      write_read_empty_int64_array project_id: @project_id,
                                   instance_id: @instance.instance_id,
                                   database_id: database.database_id
    end

    expect(captured_output).to include "true"

    capture do
      write_read_null_int64_array project_id: @project_id,
                                  instance_id: @instance.instance_id,
                                  database_id: database.database_id
    end

    expect(captured_output.split("\n")).to match_array(["true", "true", "true"])

    capture do
      write_read_int64_array project_id: @project_id,
                             instance_id: @instance.instance_id,
                             database_id: database.database_id
    end

    expect(captured_output).to include "10"
    expect(captured_output).to include "11"
    expect(captured_output).to include "12"

    capture do
      write_read_empty_float64_array project_id: @project_id,
                                     instance_id: @instance.instance_id,
                                     database_id: database.database_id
    end

    expect(captured_output).to include "true"

    capture do
      write_read_null_float64_array project_id: @project_id,
                                    instance_id: @instance.instance_id,
                                    database_id: database.database_id
    end

    expect(captured_output.split("\n")).to match_array(["true", "true", "true"])

    capture do
      write_read_float64_array project_id: @project_id,
                               instance_id: @instance.instance_id,
                               database_id: database.database_id
    end

    expect(captured_output).to include "10.001"
    expect(captured_output).to include "11.1212"
    expect(captured_output).to include "104.4123101"
  end

  xexample "create backup" do
    cleanup_backup_resources
    database = create_database_with_data

    client = @spanner.client @instance.instance_id, database.database_id
    version_time = client.execute("SELECT CURRENT_TIMESTAMP() as timestamp").rows.first[:timestamp]

    capture do
      create_backup project_id:   @project_id,
                    instance_id:  @instance.instance_id,
                    database_id:  database.database_id,
                    backup_id:    @backup_id,
                    version_time: version_time
    end

    expect(captured_output).to include(
      "Backup operation in progress"
    )
    expect(captured_output).to match(
      /Backup #{@backup_id} of size \d+ bytes was created at/
    )
    expect(captured_output).to match(
      /for version of database at/
    )

    @test_backup = @instance.backup @backup_id
    expect(@test_backup).not_to be nil
  end

  xexample "copy backup" do
    cleanup_backup_resources
    create_backup_with_data

    backup_id = "test_bu_copied"

    capture do
      copy_backup project_id: @project_id,
                  instance_id: @instance.instance_id,
                  backup_id: backup_id,
                  source_backup_id: @backup_id
    end

    expect(captured_output).to include(
      "Copy backup operation in progress"
    )
    expect(captured_output).to match(
      /Backup #{backup_id} of size \d+ bytes was copied at/
    )

    test_backup = @instance.backup backup_id
    expect(test_backup).not_to be nil

    #Clean up copied backup
    test_backup&.delete

    test_backup = @instance.backup backup_id
    expect(test_backup).to be_nil
  end

  xexample "create backup with encryption key" do
    cleanup_backup_resources
    database = create_database_with_data

    client = @spanner.client @instance.instance_id, database.database_id
    kms_key_name = "projects/#{@project_id}/locations/us-central1/keyRings/spanner-test-keyring/cryptoKeys/spanner-test-cmek"

    capture do
      create_backup_with_encryption_key project_id:   @project_id,
                                        instance_id:  @instance.instance_id,
                                        database_id:  database.database_id,
                                        backup_id:    @backup_id,
                                        kms_key_name: kms_key_name
    end

    expect(captured_output).to include(
      "Backup operation in progress"
    )
    expect(captured_output).to match(
      /Backup #{@backup_id} of size \d+ bytes was created at/
    )
    expect(captured_output).to match(
      /using encryption key #{kms_key_name}/
    )

    @test_backup = @instance.backup @backup_id
    expect(@test_backup).not_to be nil
  end

  xexample "restore backup" do
    backup = create_backup_with_data
    database = @instance.database @database_id

    capture do
      restore_backup project_id:  @project_id,
                     instance_id: @instance.instance_id,
                     database_id: @restored_database_id,
                     backup_id:   backup.backup_id
    end

    expect(captured_output).to include(
      "Waiting for restore backup operation to complete"
    )
    expect(captured_output).to match(
      /Database #{database.path} was restored to #{@restored_database_id} from backup #{backup.path} with version time/
    )

    @test_database = @instance.database @restored_database_id
    expect(@test_database).not_to be nil
  end

  xexample "restore database with encryption key" do
    backup = create_backup_with_data
    database = @instance.database @database_id
    kms_key_name = "projects/#{@project_id}/locations/us-central1/keyRings/spanner-test-keyring/cryptoKeys/spanner-test-cmek"

    capture do
      restore_database_with_encryption_key project_id:   @project_id,
                                           instance_id:  @instance.instance_id,
                                           database_id:  @restored_database_id,
                                           backup_id:    backup.backup_id,
                                           kms_key_name: kms_key_name
    end

    expect(captured_output).to include(
      "Waiting for restore backup operation to complete"
    )
    expect(captured_output).to match(
      /Database #{database.path} was restored to #{@restored_database_id} from backup #{backup.path} using encryption key #{kms_key_name}/
    )

    @test_database = @instance.database @restored_database_id
    expect(@test_database).not_to be nil
  end

  xexample "cancel backup operation" do
    database = create_database_with_data

    cancel_backup_id = "cancel_#{@backup_id}"
    capture do
      create_backup_cancel project_id:  @project_id,
                           instance_id: @instance.instance_id,
                           database_id: database.database_id,
                           backup_id:   cancel_backup_id
    end

    expect(captured_output).to include(
      "Backup operation in progress"
    )
    expect(captured_output).to include(
      "#{cancel_backup_id} creation job cancelled"
    )

    @test_backup = @instance.backup cancel_backup_id
    expect(@test_backup).to be nil
  end

  xexample "list backup operations" do
    backup = create_backup_with_data
    capture do
      list_backup_operations project_id:  @project_id,
                             instance_id: @instance.instance_id,
                             database_id: @database_id
    end

    expect(captured_output).to match(
      /Backup #{backup.path} on database #{@database_id} is \d+% complete/
    )

    @test_backup = @instance.backup @backup_id
    expect(@test_backup).not_to be nil
  end

  xexample "list copy backup operations" do
    backup = create_backup_with_data
    copied_backup = create_copy_backup
    capture do
      list_copy_backup_operations project_id:  @project_id,
                                  instance_id: @instance.instance_id,
                                  backup_id: @backup_id
    end

    expect(captured_output).to match(
      /Backup #{copied_backup.path} on source backup #{@backup_id} is \d+% complete/
    )

    @test_backup = @instance.backup @backup_id
    expect(@test_backup).not_to be nil
  end

  xexample "list database operations" do
    database = restore_database_from_backup

    capture do
      list_database_operations project_id:  @project_id,
                               instance_id: @instance.instance_id
    end

    expect(captured_output).to match(
      /List database operations with optimized database filter found \d+ jobs/
    )
  end

  xexample "list backups with various filters" do
    backup = create_backup_with_data

    capture do
      list_backups project_id:  @project_id,
                   instance_id: @instance.instance_id,
                   backup_id: @backup_id,
                   database_id: backup.database_id
    end

    # Segregate each list backup filters output.
    output_segments = captured_output.split(/(All backups)/)
                                      .reject(&:empty?)
                                      .each_slice(2)
                                      .map(&:join)

    expect(output_segments.shift).to include("All backups", backup.path)

    expect(output_segments.shift).to include(
      "All backups with backup name containing",
      "\"#{backup.backup_id}\":\n#{backup.path}"
    )

    expect(output_segments.shift).to include(
      "All backups for databases with a name containing",
      "\"#{backup.database_id}\":\n#{backup.path}"
    )

    expect(output_segments.shift).to include(
      "All backups that expire before a timestamp", backup.backup_id
    )
    expect(output_segments.shift).to include(
      "All backups with a size greater than 500 bytes", backup.backup_id
    )
    expect(output_segments.shift).to include(
      "All backups that were created after a timestamp that are also ready",
      backup.backup_id
    )
    expect(output_segments.shift).to include(
      "All backups with pagination", backup.backup_id
    )

    @test_backup = @instance.backup @backup_id
    expect(@test_backup).not_to be nil
  end

  xexample "delete backup" do
    backup = create_backup_with_data

    capture do
      delete_backup project_id:  @project_id,
                    instance_id: @instance.instance_id,
                    backup_id:   backup.backup_id
    end

    expect(captured_output).to include(
      "Backup #{backup.backup_id} deleted"
    )

    @test_backup = @instance.backup @backup_id
    expect(@test_backup).to be nil
  end

  xexample "update backup" do
    backup = create_backup_with_data

    capture do
      update_backup project_id:  @project_id,
                    instance_id: @instance.instance_id,
                    backup_id:   backup.backup_id
    end

    expect(captured_output).to include(
      "Expiration time updated: #{backup.expire_time + 2_592_000}"
    )
  end

  example "set custom timeout and retry settings" do
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
      set_custom_timeout_and_retry project_id:  @project_id,
                       instance_id: @instance.instance_id,
                       database_id: database.database_id
    }.to output("1 record inserted.\n").to_stdout

    singers = client.execute("SELECT * FROM Singers").rows.to_a
    expect(singers.count).to eq 6
    expect(singers.find { |s| s[:FirstName] == "Virginia" }).not_to be nil
  end

  example "get commit stats" do
    database = create_singers_albums_database

    capture do
      insert_data project_id:  @project_id,
                  instance_id: @instance.instance_id,
                  database_id: database.database_id

      add_column project_id:  @project_id,
                 instance_id: @instance.instance_id,
                 database_id: database.database_id
    end


    capture do
      commit_stats project_id:  @project_id,
                   instance_id: @instance.instance_id,
                   database_id: database.database_id
    end

    expect(captured_output).to match /Updated data with \d+ mutations/
  end
end
