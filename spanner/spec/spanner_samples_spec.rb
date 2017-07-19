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
    @spanner    = Google::Cloud::Spanner.new
    @project_id = @spanner.project_id
    @instance   = @spanner.instance ENV["GOOGLE_CLOUD_SPANNER_TEST_INSTANCE"]
  end

  after do
    @test_database.drop if @test_database
  end

  # Creates a temporary database with random ID (will be dropped after test)
  # (re-uses create_database to create database with Albums/Singers schema)
  def create_singers_albums_database
    database_id = "db_for_all_tests_#{Time.now.to_i}"

    create_database project_id:  @project_id,
                    instance_id: @instance.instance_id,
                    database_id: database_id

    @test_database = @instance.database database_id
    @test_database
  end

  # Capture and return STDOUT output by block
  def capture &block
    real_stdout = $stdout
    $stdout = StringIO.new
    block.call
    @captured_output = $stdout.string
  ensure
    $stdout = real_stdout
  end
  attr_reader :captured_output

  example "create_database" do
    @database_id = "test_database_#{Time.now.to_i}"

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

    database = @instance.database @database_id
    expect(database).not_to be nil

    data_definition_statements = database.ddl
    expect(data_definition_statements.size).to eq 2
    expect(data_definition_statements.first).to include "CREATE TABLE Singers"
    expect(data_definition_statements.last).to  include "CREATE TABLE Albums"
  end

  example "insert data" do
    database = create_singers_albums_database
    client   = @spanner.client @instance.instance_id, database.database_id

    expect(client.execute("SELECT * FROM Singers").rows.count).to eq 0
    expect(client.execute("SELECT * FROM Albums").rows.count).to eq 0

    expect {
      insert_data project_id:  @project_id,
                  instance_id: @instance.instance_id,
                  database_id: database.database_id
    }.to output("Inserted data\n").to_stdout

    singers = client.execute("SELECT * FROM Singers").rows.to_a
    expect(singers.count).to eq 5
    expect(singers.find {|s| s[:FirstName] == "Catalina" }).not_to be nil

    albums = client.execute("SELECT * FROM Albums").rows.to_a
    expect(albums.count).to eq 5
    expect(albums.find {|s| s[:AlbumTitle] == "Go, Go, Go" }).not_to be nil
  end

  example "query data" do
    database = create_singers_albums_database
    client   = @spanner.client @instance.instance_id, database.database_id

    # Insert Singers and Albums (re-use insert_data sample to populate)
    insert_data project_id:  @project_id,
                instance_id: @instance.instance_id,
                database_id: database.database_id

    capture do
      query_data project_id:  @project_id,
                 instance_id: @instance.instance_id,
                 database_id: database.database_id
    end

    expect(captured_output).to include "1 1 Go, Go, Go"
    expect(captured_output).to include "1 2 Total Junk"
    expect(captured_output).to include "2 1 Green"
    expect(captured_output).to include "2 2 Forever Hold your Peace"
    expect(captured_output).to include "2 3 Terrified"
  end

  example "read data" do
    database = create_singers_albums_database
    client   = @spanner.client @instance.instance_id, database.database_id

    # Insert Singers and Albums (re-use insert_data sample to populate)
    insert_data project_id:  @project_id,
                instance_id: @instance.instance_id,
                database_id: database.database_id

    capture do
      read_data project_id:  @project_id,
                instance_id: @instance.instance_id,
                database_id: database.database_id
    end

    expect(captured_output).to include "1 1 Go, Go, Go"
    expect(captured_output).to include "1 2 Total Junk"
    expect(captured_output).to include "2 1 Green"
    expect(captured_output).to include "2 2 Forever Hold your Peace"
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
    pending
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

  example "update data" do
    database = create_singers_albums_database
    client   = @spanner.client @instance.instance_id, database.database_id

    # Insert Singers and Albums (re-use insert_data sample to populate)
    insert_data project_id:  @project_id,
                instance_id: @instance.instance_id,
                database_id: database.database_id

    # Add MarketingBudget column (re-use add_column to add)
    add_column project_id:  @project_id,
               instance_id: @instance.instance_id,
               database_id: database.database_id

    albums = client.execute("SELECT * FROM Albums").rows.map &:to_h
    expect(albums).to include(
      { SingerId: 1, AlbumId: 1, AlbumTitle: "Go, Go, Go", MarketingBudget: nil }
    )

    capture do
      update_data project_id:  @project_id,
                  instance_id: @instance.instance_id,
                  database_id: database.database_id
    end

    expect(captured_output).to include "Updated data"

    albums = client.execute("SELECT * FROM Albums").rows.map &:to_h
    expect(albums).to include(
      { SingerId: 1, AlbumId: 1, AlbumTitle: "Go, Go, Go", MarketingBudget: 100000 }
    )
  end

  example "read/write transaction (successful transfer)" do
    database = create_singers_albums_database
    client   = @spanner.client @instance.instance_id, database.database_id

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
        { SingerId: "1", AlbumId: "1", MarketingBudget: "100000" },
        { SingerId: "2", AlbumId: "2", MarketingBudget: "300000" }
      ]
    end

    capture do
      read_write_transaction project_id:  @project_id,
                             instance_id: @instance.instance_id,
                             database_id: database.database_id
    end

    expect(captured_output).to include "Transaction complete"

    first_album  = client.read("Albums", [:MarketingBudget], keys: [[1,1]]).rows.first
    second_album = client.read("Albums", [:MarketingBudget], keys: [[2,2]]).rows.first

    expect(first_album[:MarketingBudget]).to eq 300_000
    expect(second_album[:MarketingBudget]).to eq 100_000
  end

  example "read/write transaction (not enough funds)" do
    database = create_singers_albums_database
    client   = @spanner.client @instance.instance_id, database.database_id

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
        { SingerId: "1", AlbumId: "1", MarketingBudget: "100000" },
        { SingerId: "2", AlbumId: "2", MarketingBudget: "299999" }
      ]
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

    capture do
      query_data_with_index project_id:  @project_id,
                            instance_id: @instance.instance_id,
                            database_id: database.database_id
    end

    expect(captured_output).to include "1 Go, Go, Go"
    expect(captured_output).to include "2 Forever Hold your Peace"
  end

  example "read data with index" do
    database = create_singers_albums_database
    client   = @spanner.client @instance.instance_id, database.database_id

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

    capture do
      read_data_with_index project_id:  @project_id,
                           instance_id: @instance.instance_id,
                           database_id: database.database_id
    end

    expect(captured_output).to include "1 Go, Go, Go"
    expect(captured_output).to include "2 Forever Hold your Peace"
  end

  example "read data with storing index" do
    database = create_singers_albums_database
    client   = @spanner.client @instance.instance_id, database.database_id

    # Insert Singers and Albums (re-use insert_data sample to populate)
    insert_data project_id:  @project_id,
                instance_id: @instance.instance_id,
                database_id: database.database_id

    # Add MarketingBudget column (re-use add_column to add)
    add_column project_id:  @project_id,
               instance_id: @instance.instance_id,
               database_id: database.database_id

    # Add index on Albums(AlbumTitle) (re-use create_index to add)
    # XXX create_storing_index is not yet tested, but is required by this test
    create_storing_index project_id:  @project_id,
                         instance_id: @instance.instance_id,
                         database_id: database.database_id

    capture do
      read_data_with_storing_index project_id:  @project_id,
                                   instance_id: @instance.instance_id,
                                   database_id: database.database_id
    end

    expect(captured_output).to include "1 Go, Go, Go"
    expect(captured_output).to include "2 Forever Hold your Peace"
  end

  example "read only transaction" do
    database = create_singers_albums_database
    client   = @spanner.client @instance.instance_id, database.database_id

    # Insert Singers and Albums (re-use insert_data sample to populate)
    insert_data project_id:  @project_id,
                instance_id: @instance.instance_id,
                database_id: database.database_id

    capture do
      read_only_transaction project_id:  @project_id,
                            instance_id: @instance.instance_id,
                            database_id: database.database_id
    end

    expect(captured_output).to include "1 1 Go, Go, Go"
    expect(captured_output).to include "2 2 Forever Hold your Peace"
  end
end
