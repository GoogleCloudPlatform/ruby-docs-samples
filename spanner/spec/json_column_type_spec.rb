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

require_relative "../json_column_type_samples"
require_relative "./spec_helper"

describe "Spanner database JSON datatype" do
  def create_test_database
    statements = [
      "CREATE TABLE Venues (
        VenueId INT64 NOT NULL,
      ) PRIMARY KEY(VenueId)"
    ]

    job = db_admin_client.create_database \
      parent: instance_path(@instance_id),
      create_statement: "CREATE DATABASE `#{@database_id}`",
      extra_statements: statements

    job.wait_until_done!
    job.results
  end

  before :each do
    cleanup_database_resources
    create_test_database
  end

  after :each do
    cleanup_database_resources
  end

  example "add_json_column_update_and_query_data" do
    capture do
      add_json_column project_id: @project_id,
                      instance_id: @instance_id,
                      database_id: @database_id
    end

    expect(captured_output).to include(
      "Added VenueDetails column to Venues table in database #{@database_id}"
    )

    client = @spanner.client @instance_id, @database_id
    client.insert "Venues", [{ VenueId: 1 }, { VenueId: 2 }]

    capture do
      update_data_with_json_column project_id: @project_id,
                                   instance_id: @instance_id,
                                   database_id: @database_id
    end

    expect(captured_output).to include("Rows are updated")

    capture do
      query_with_json_params project_id: @project_id,
                             instance_id: @instance_id,
                             database_id: @database_id
    end

    expect(captured_output).to include("VenueId: 1")
  end
end
