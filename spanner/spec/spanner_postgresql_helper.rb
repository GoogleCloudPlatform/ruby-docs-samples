# Copyright 2022 Google, Inc
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

require "google/cloud/spanner"
require "google/cloud/spanner/admin/database"
require_relative "../spanner_postgresql_create_database"

def create_spangres_singers_albums_database
  capture do
    postgresql_create_database project_id:  @project_id,
                               instance_id: @instance.instance_id,
                               database_id: @database_id
    
    @test_database = @instance.database @database_id
  end

  @test_database
end

def create_spangres_singers_table
  capture do
    db_admin_client = Google::Cloud::Spanner::Admin::Database.database_admin project: @project_id

    db_path = db_admin_client.database_path project: @project_id,
                                            instance: @instance.instance_id,
                                            database: @database_id

    create_table_query = <<~QUERY
      CREATE TABLE Singers (
        SingerId bigint NOT NULL PRIMARY KEY,
        FirstName varchar(1024),
        LastName varchar(1024),
        Rating numeric,
        SingerInfo bytea,
        FullName character varying(2048) GENERATED ALWAYS AS (FirstName || ' ' || LastName) STORED
      );
    QUERY
  
    job = db_admin_client.update_database_ddl database: db_path,
                                              statements: [create_table_query]
  
    job.wait_until_done!
  
    if job.error?
      puts "Error while creating table. Code: #{job.error.code}. Message: #{job.error.message}"
      raise GRPC::BadStatus.new(job.error.code, job.error.message)
    end
  end
end

def create_spangres_albums_table
  capture do
    db_admin_client = Google::Cloud::Spanner::Admin::Database.database_admin project: @project_id

    db_path = db_admin_client.database_path project: @project_id,
                                            instance: @instance.instance_id,
                                            database: @database_id

    create_table_query = <<~QUERY
          CREATE TABLE Albums (
            SingerId     bigint NOT NULL,
            AlbumId      bigint NOT NULL,
            AlbumTitle   character varying(1024),
            MarketingBudget bigint,
            PRIMARY KEY (SingerId, AlbumId)
          ) INTERLEAVE IN PARENT Singers ON DELETE CASCADE;
        QUERY

    job = db_admin_client.update_database_ddl database: db_path,
                                              statements: [create_table_query]

    job.wait_until_done!

    if job.error?
      puts "Error while creating table. Code: #{job.error.code}. Message: #{job.error.message}"
      raise GRPC::BadStatus.new(job.error.code, job.error.message)
    end
  end
end

def create_spangres_venues_table
  capture do
    db_admin_client = Google::Cloud::Spanner::Admin::Database.database_admin project: @project_id

    db_path = db_admin_client.database_path project: @project_id,
                                            instance: @instance.instance_id,
                                            database: @database_id
  
    create_table_query = <<~QUERY
      CREATE TABLE Venues (
        VenueId bigint NOT NULL PRIMARY KEY,
        Name varchar(1024),
      );
    QUERY
  
    job = db_admin_client.update_database_ddl database: db_path,
                                              statements: [create_table_query]
  
    job.wait_until_done!
  
    if job.error?
      puts "Error while creating table. Code: #{job.error.code}. Message: #{job.error.message}"
      raise GRPC::BadStatus.new(job.error.code, job.error.message)
    end
  end
end

def add_data_to_spangres_singers_table
  spanner = Google::Cloud::Spanner.new project: @project_id
  client  = spanner.client @instance.instance_id, @database_id
  client.commit do |c|
    c.insert "Singers", [
      { SingerId: 1, FirstName: "Ann", LastName: "Louis", Rating: BigDecimal("3.6") },
      { SingerId: 2, FirstName: "Olivia", LastName: "Garcia", Rating: BigDecimal("2.1") },
      { SingerId: 3, FirstName: "Alice", LastName: "Trentor", Rating: BigDecimal("4.8") },
      { SingerId: 4, FirstName: "Bruce", LastName: "Allison", Rating: BigDecimal("2.7") }
    ]
  end
end

def add_data_to_spangres_albums_table
  spanner = Google::Cloud::Spanner.new project: @project_id
  client  = spanner.client @instance.instance_id, @database_id
  client.commit do |c|
      c.insert "Albums", [
        { SingerId: 1, AlbumId: 1, AlbumTitle: "Total Junk", MarketingBudget: 20_000 },
        { SingerId: 1, AlbumId: 2, AlbumTitle: "Go, Go, Go", MarketingBudget: 20_000 },
        { SingerId: 2, AlbumId: 1, AlbumTitle: "Green", MarketingBudget: 20_000 },
        { SingerId: 2, AlbumId: 2, AlbumTitle: "Forever Hold Your Peace", MarketingBudget: 20_000 },
        { SingerId: 2, AlbumId: 3, AlbumTitle: "Terrified", MarketingBudget: 20_000 }
      ]
    end
end
