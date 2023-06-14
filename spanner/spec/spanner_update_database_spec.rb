# Copyright 2023 Google, Inc
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
require_relative "../spanner_update_database"

describe "Google Cloud Spanner Admin Database" do
  before :each do
    cleanup_database_resources
    create_test_database @database_id
  end

  after :each do
    cleanup_database_resources
  end

  example "spanner_update_database" do
    client = Google::Cloud::Spanner::Admin::Database.database_admin project_id: @project_id
    db_path = client.database_path project: @project_id,
                                   instance: @instance_id,
                                   database: @database_id
    database = client.get_database name: db_path
    expect(database.enable_drop_protection).to be false

    spanner_update_database project_id: @project_id,
                            instance_id: @instance_id,
                            database_id: @database_id

    database = client.get_database name: db_path
    expect(database.enable_drop_protection).to be true

    # For cleanup purpose
    database.enable_drop_protection = false
    job = client.update_database database: database, update_mask: { paths: ["enable_drop_protection"] }
    job.wait_until_done!
  end
end
