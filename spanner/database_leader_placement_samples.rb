# Copyright 2021 Google LLC
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

def instance_config project_id:, instance_config_id:
  # [START spanner_get_instance_config]
  # project_id  = "Your Google Cloud project ID"
  # instance_config_id = "Spanner instance config ID"

  require "google/cloud/spanner"
  require "google/cloud/spanner/admin/instance"

  instance_admin_client = Google::Cloud::Spanner::Admin::Instance.instance_admin

  instance_config_path = instance_admin_client.instance_config_path \
    project: project_id, instance_config: instance_config_id
  config = instance_admin_client.get_instance_config name: instance_config_path

  puts "Available leader options for instance config #{config.name} : #{config.leader_options}"
  # [END spanner_get_instance_config]
end

def list_instance_configs project_id:
  # [START spanner_list_instance_configs]
  # project_id  = "Your Google Cloud project ID"

  require "google/cloud/spanner"
  require "google/cloud/spanner/admin/instance"

  instance_admin_client = Google::Cloud::Spanner::Admin::Instance.instance_admin

  project_path = instance_admin_client.project_path project: project_id
  configs = instance_admin_client.list_instance_configs parent: project_path

  configs.each do |c|
    puts "Available leader options for instance config #{c.name} : #{c.leader_options}"
  end
  # [END spanner_list_instance_configs]
end

def list_databases project_id:, instance_id:
  # [START spanner_list_databases]
  # project_id  = "Your Google Cloud project ID"
  # instance_id = "Your Spanner instance ID"

  require "google/cloud/spanner"
  require "google/cloud/spanner/admin/database"

  db_admin_client = Google::Cloud::Spanner::Admin::Database.database_admin project_id: project_id

  instance_path = db_admin_client.instance_path project: project_id,
                                                instance: instance_id
  databases = db_admin_client.list_databases parent: instance_path

  databases.each do |db|
    puts "#{db.name} : default leader #{db.default_leader}"
  end
  # [END spanner_list_databases]
end

def create_database_with_default_leader \
  project_id:, instance_id:, database_id:, default_leader:
  # [START spanner_create_database_with_default_leader]
  # project_id  = "Your Google Cloud project ID"
  # instance_id = "Your Spanner instance ID"
  # database_id = "Your Spanner database ID"
  # default_leader = "Spanner database default leader"

  require "google/cloud/spanner"
  require "google/cloud/spanner/admin/database"

  db_admin_client = Google::Cloud::Spanner::Admin::Database.database_admin project_id: project_id

  instance_path = \
    db_admin_client.instance_path project: project_id, instance: instance_id
  statements = [
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
    INTERLEAVE IN PARENT Singers ON DELETE CASCADE",

    "ALTER DATABASE `#{database_id}` SET OPTIONS (
      default_leader = '#{default_leader}'
    )"
  ]

  job = db_admin_client.create_database \
    parent: instance_path,
    create_statement: "CREATE DATABASE `#{database_id}`",
    extra_statements: statements

  job.wait_until_done!
  database = job.results

  puts "Created database [#{database.name}] with default leader: #{database.default_leader}"
  # [END spanner_create_database_with_default_leader]
end

def update_database_with_default_leader \
  project_id:, instance_id:, database_id:, default_leader:
  # [START spanner_update_database_with_default_leader]
  # project_id  = "Your Google Cloud project ID"
  # instance_id = "Your Spanner instance ID"
  # database_id = "Your Spanner database ID"
  # default_leader = "Spanner database default leader"

  require "google/cloud/spanner"
  require "google/cloud/spanner/admin/database"

  db_admin_client = Google::Cloud::Spanner::Admin::Database.database_admin project_id: project_id

  db_path = db_admin_client.database_path project: project_id,
                                          instance: instance_id,
                                          database: database_id
  statements = [
    "ALTER DATABASE `#{database_id}` SET OPTIONS (
      default_leader = '#{default_leader}'
    )"
  ]

  job = db_admin_client.update_database_ddl database: db_path,
                                            statements: statements

  job.wait_until_done!
  database = job.results

  puts "Updated default leader"
  # [END spanner_update_database_with_default_leader]
end

def database_ddl project_id:, instance_id:, database_id:
  # [START spanner_get_database_ddl]
  # project_id  = "Your Google Cloud project ID"
  # instance_id = "Your Spanner instance ID"
  # database_id = "Your Spanner database ID"

  require "google/cloud/spanner"
  require "google/cloud/spanner/admin/database"

  db_admin_client = Google::Cloud::Spanner::Admin::Database.database_admin project_id: project_id

  db_path = db_admin_client.database_path project: project_id,
                                          instance: instance_id,
                                          database: database_id
  ddl = db_admin_client.get_database_ddl database: db_path

  puts ddl.statements
  # [END spanner_get_database_ddl]
end

def query_information_schema_database_options \
  project_id:, instance_id:, database_id:
  # [START spanner_query_information_schema_database_options]
  # project_id  = "Your Google Cloud project ID"
  # instance_id = "Your Spanner instance ID"
  # database_id = "Your Spanner database ID

  require "google/cloud/spanner"

  spanner = Google::Cloud::Spanner.new project: project_id
  client = spanner.client instance_id, database_id

  client.execute(
    "SELECT s.OPTION_NAME, s.OPTION_VALUE " \
    "FROM INFORMATION_SCHEMA.DATABASE_OPTIONS s " \
    "WHERE s.OPTION_NAME = 'default_leader'"
  ).rows.each do |row|
    puts row
  end
  # [END spanner_query_information_schema_database_options]
end

def usage
  puts <<~USAGE
    Usage: bundle exec ruby database_leader_placement_samples.rb [command] [arguments]

    Commands:
      instance_config                           <instance_config_id> Get instance config
      list_instance_configs                     List instance configs
      list_databases                            <instance_id> List databases
      create_database_with_default_leader       <instance_id> <database_id> <default_leader> Create database with default leader
      update_database_with_default_leader       <instance_id> <database_id> <default_leader> Update database default leader
      database_ddl                              <instance_id> <database_id> Get database DDL statements
      query_information_schema_database_options <instance_id> <database_id> Get database information schema using option name

    Environment variables:
      GOOGLE_CLOUD_PROJECT must be set to your Google Cloud project ID
  USAGE
end

def run_sample arguments
  commands = [
    "instance_config", "list_instance_configs", "list_databases",
    "create_database_with_default_leader",
    "update_database_with_default_leader", "database_ddl",
    "query_information_schema_database_options"
  ]

  command = arguments.shift
  project_id = ENV["GOOGLE_CLOUD_PROJECT"]

  return usage unless commands.include? command

  sample_method = method command
  parameters = { project_id: project_id }

  sample_method.parameters.each do |paramater|
    next if paramater.last == :project_id
    parameters[paramater.last] = arguments.shift
  end

  sample_method.call(**parameters)
end

run_sample ARGV if $PROGRAM_NAME == __FILE__
