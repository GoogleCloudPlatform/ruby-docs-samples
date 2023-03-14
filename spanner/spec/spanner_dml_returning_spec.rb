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
require_relative "../spanner_delete_dml_returning"
require_relative "../spanner_update_dml_returning"
require_relative "../spanner_insert_dml_returning"

describe "Google Cloud Spanner DML examples" do
  before :each do
    cleanup_database_resources
    create_dml_singers_albums_database
    insert_dml_data project_id: @project_id,
                instance_id: @instance_id,
                database_id: @database_id
  end

  after :each do
    cleanup_database_resources
  end

  example "spanner_delete_dml_returning" do
    capture do
      spanner_delete_dml_returning project_id: @project_id,
                                   instance_id: @instance_id,
                                   database_id: @database_id
    end

    expect(captured_output).to include("Alice Trentor")
    expect(captured_output).to include("Deleted row(s) count: 1")
  end

  example "spanner_update_dml_returning" do
    capture do
      spanner_update_dml_returning project_id: @project_id,
                                   instance_id: @instance_id,
                                   database_id: @database_id
    end

    expect(captured_output).to include("40000")
    expect(captured_output).to include("Updated row(s) count: 1")
  end

  example "spanner_insert_dml_returning" do
    capture do
      spanner_insert_dml_returning project_id: @project_id,
                                   instance_id: @instance_id,
                                   database_id: @database_id
    end

    expect(captured_output).to include("Melissa Garcia")
    expect(captured_output).to include("Russell Morales")
    expect(captured_output).to include("Jacqueline Long")
    expect(captured_output).to include("Dylan Shaw")
    expect(captured_output).to include("Inserted row(s) count: 4")
  end
end
