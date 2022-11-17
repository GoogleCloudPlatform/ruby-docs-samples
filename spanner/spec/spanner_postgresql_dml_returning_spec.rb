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

require_relative "./spec_helper"
require_relative "./spanner_postgresql_helper"
require_relative "../spanner_postgresql_delete_dml_returning"
require_relative "../spanner_postgresql_update_dml_returning"
require_relative "../spanner_postgresql_insert_dml_returning"

describe "Google Cloud Spanner Postgres DML examples" do
  before :each do
    cleanup_database_resources
    create_spangres_singers_albums_database
    create_spangres_singers_table
    add_data_to_spangres_singers_table
  end

  after :each do
    cleanup_database_resources
  end

  example "spanner_postgresql_delete_dml_returning" do
    capture do
      spanner_postgresql_delete_dml_returning project_id: @project_id,
                                             instance_id: @instance_id,
                                             database_id: @database_id
    end

    expect(captured_output).to include("Deleted singer with id: 3, FirstName: Alice")
    expect(captured_output).to include("Deleted row(s) count: 1")
  end

  example "spanner_postgresql_update_dml_returning" do
    capture do
      spanner_postgresql_update_dml_returning project_id: @project_id,
                                              instance_id: @instance_id,
                                              database_id: @database_id
    end

    expect(captured_output).to include("Updated Singer with SingerId: 1, FirstName: Ann, LastName: Louis_update")
    expect(captured_output).to include("Updated row(s) count: 1")
  end

  example "spanner_postgresql_insert_dml_returning" do
    capture do
      spanner_postgresql_insert_dml_returning project_id: @project_id,
                                              instance_id: @instance_id,
                                              database_id: @database_id
    end

    expect(captured_output).to include("Inserted singers with id: 12, FirstName: Melissa, LastName: Garcia")
    expect(captured_output).to include("Inserted singers with id: 13, FirstName: Russell, LastName: Morales")
    expect(captured_output).to include("Inserted singers with id: 14, FirstName: Jacqueline, LastName: Long")
    expect(captured_output).to include("Inserted singers with id: 15, FirstName: Dylan, LastName: Shaw")
    expect(captured_output).to include("Inserted row(s) count: 4")
  end
end
