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
    @restored_database_id = "restored_db_#{seed}"
    @spanner              = Google::Cloud::Spanner.new project: @project_id
    @instance             = @spanner.instance @instance_id
    @created_instance_ids = []
  end

  config.after :all do
    cleanup_backup_resources
  end

  def seed
    $spanner_example_seed ||= SecureRandom.hex 8
  end

  def cleanup_instance_resources
    @created_instance_ids.each do |instance_id|
      instance = @spanner.instance instance_id
      instance.delete if instance
    end

    @created_instance_ids.clear
  end

  def cleanup_database_resources
    return unless @instance

    @test_database = @instance.database @database_id
    @test_database&.drop
    @test_database = @instance.database @restored_database_id
    @test_database&.drop
  end

  def cleanup_backup_resources
    return unless @instance

    @test_backup = @instance.backup @backup_id
    @test_backup&.delete
  end
end
