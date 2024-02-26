# Copyright 2020 Google, LLC
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

require "rspec"
require "google/cloud/spanner"
require "google/cloud/spanner/admin/instance"
require "google/cloud/spanner/admin/database"
require_relative "../spanner_samples"

RSpec.configure do |config|
  config.before :all do
    if ENV["GOOGLE_CLOUD_SPANNER_TEST_INSTANCE"].nil? || ENV["GOOGLE_CLOUD_SPANNER_PROJECT"].nil?
      skip "GOOGLE_CLOUD_SPANNER_TEST_INSTANCE and/or GOOGLE_CLOUD_SPANNER_PROJECT not defined"
    end

    @project_id           = ENV["GOOGLE_CLOUD_SPANNER_PROJECT"]
    @instance_id          = ENV["GOOGLE_CLOUD_SPANNER_TEST_INSTANCE"]
    @seed                 = SecureRandom.hex 8
    @database_id          = "test_db_#{seed}"
    @backup_id            = "test_bu_#{seed}"
    @copied_backup_id     = "test_cbu_#{seed}"
    @restored_database_id = "restored_db_#{seed}"
    @spanner              = Google::Cloud::Spanner.new project: @project_id
    @instance             = @spanner.instance @instance_id
    @created_instance_ids = []
    @created_instance_config_ids = []
  end

  config.after :all do
    # cleanup_backup_resources
    cleanup_instance_resources
  end

  def seed
    $spanner_example_seed ||= SecureRandom.hex 8
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

  def captured_output
    @captured_output
  end

  def cleanup_instance_resources
    return unless @created_instance_ids

    @created_instance_ids.each do |instance_id|
      instance = @spanner.instance instance_id
      instance.delete if instance
    end

    @created_instance_ids.clear
  end

  def cleanup_database_resources
    return unless @instance

    with_retry do 
      @test_database = @instance.database @database_id
      @test_database&.drop
      @test_database = @instance.database @restored_database_id
      @test_database&.drop
    end
  end

  def cleanup_backup_resources
    return unless @instance

    @test_backup = @instance.backup @backup_id
    @test_backup&.delete
  end

  def instance_admin_client
    @instance_admin_client ||= Google::Cloud::Spanner::Admin::Instance.instance_admin
  end

  def db_admin_client
    @db_admin_client ||= Google::Cloud::Spanner::Admin::Database.database_admin
  end

  def project_path
    instance_admin_client.project_path project: @project_id
  end

  def instance_config_path instance_config_id
    instance_admin_client.instance_config_path \
      project: @project_id, instance_config: instance_config_id
  end

  def instance_path instance_id
    instance_admin_client.instance_path \
      project: @project_id, instance: instance_id
  end

  def find_instance instance_id
    instance_admin_client.get_instance name: instance_path(instance_id)
  rescue Google::Cloud::NotFoundError
    nil
  end

  def create_test_database database_id, statements: []
    db_admin_client = Google::Cloud::Spanner::Admin::Database.database_admin

    instance_path = db_admin_client.instance_path project: @project_id,
                                                  instance: @instance_id

    job = db_admin_client.create_database \
      parent: instance_path,
      create_statement: "CREATE DATABASE `#{database_id}`",
      extra_statements: Array(statements)

    job.wait_until_done!
    database = job.results
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

  def create_dml_singers_albums_database
    capture do
      create_dml_database project_id:  @project_id,
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

  def create_venues_table
    capture do
      create_table_with_datatypes project_id:  @project_id,
                                  instance_id: @instance.instance_id,
                                  database_id: @database_id
    end
  end

  def create_boxes_database
    job = @instance.create_database @database_id
    job.wait_until_done!
    @test_database = job.database
  end

  def create_database_with_data
    database = create_singers_albums_database

    capture do
      write_using_dml project_id:  @project_id,
                      instance_id: @instance.instance_id,
                      database_id: database.database_id

      @test_database = @instance.database @database_id
    end

    @test_database
  end

  # Creates or return existing temporary backup with random ID (will be dropped
  # after test)
  def create_backup_with_data
    @test_backup = @instance.backup @backup_id

    return @test_backup if @test_backup

    database = create_singers_albums_database

    capture do
      write_using_dml project_id:  @project_id,
                      instance_id: @instance.instance_id,
                      database_id: database.database_id
    end

    client = @spanner.client @instance.instance_id, database.database_id
    version_time = client.execute("SELECT CURRENT_TIMESTAMP() as timestamp").rows.first[:timestamp]

    capture do
      create_backup project_id:   @project_id,
                    instance_id:  @instance.instance_id,
                    database_id:  database.database_id,
                    backup_id:    @backup_id,
                    version_time: version_time

      @test_backup = @instance.backup @backup_id
    end

    @test_backup
  end

  def create_copy_backup
    capture do
      copy_backup project_id: @project_id,
                  instance_id: @instance.instance_id,
                  backup_id: @copied_backup_id,
                  source_backup_id: @backup_id
    end
    @instance.backup @copied_backup_id
  end

  def restore_database_from_backup
    backup = create_backup_with_data

    capture do
      restore_backup project_id:  @project_id,
                     instance_id: @instance.instance_id,
                     database_id: @restored_database_id,
                     backup_id:   backup.backup_id

      @test_database = @instance.database @restored_database_id
    end

    @test_database
  end

  def with_retry retries: 5
    max_retries = 10
    Retriable.retriable(
      on: Google::Cloud::DeadlineExceededError,
      base_interval: 1,
      multiplier: 2,
      tries: [retries, max_retries].min
    ) do
      return yield
    end
    raise
  end
end
