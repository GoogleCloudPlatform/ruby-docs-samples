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

    # Most samples create Cloud Spanner database(s)
    # @temporary_databases tracks databases to drop after the test runs
    @temporary_databases = []
  end

  after do
    @temporary_databases.each &:drop
  end

  # All code samples use this database schema (Singers and Albums tables)
  # By default this database will be dropped after the test runs
  # TODO Create table before(:all), truncate after each test, drop after(:all)
  def create_singers_albums_database instance: @instance, temporary: true
    database_id = "db_for_all_tests_#{Time.now.to_i}"

    instance.create_database(database_id, statements: [
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
    ]).wait_until_done!

    database = instance.database database_id
    @temporary_databases << database if temporary
    database
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

    expect(database.ddl force: true).not_to include(
      "CREATE INDEX AlbumsByAlbumTitle ON Albums(AlbumTitle)"
    )

    capture do
      create_index project_id:  @project_id,
                   instance_id: @instance.instance_id,
                   database_id: database.database_id
    end

    expect(captured_output).to include "Waiting for database update to complete"
    expect(captured_output).to include "Added the AlbumsByAlbumTitle index"

    expect(database.ddl force: true).to include(
      "CREATE INDEX AlbumsByAlbumTitle ON Albums(AlbumTitle)"
    )
  end
end
