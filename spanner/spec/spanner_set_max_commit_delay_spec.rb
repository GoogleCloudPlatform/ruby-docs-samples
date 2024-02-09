# Copyright 2024 Google, Inc
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
require_relative "../spanner_set_max_commit_delay"

describe "Google Cloud Spanner max_commit_delay examples" do
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

  example "spanner_directed_read" do
    capture do
        spanner_set_max_commit_delay project_id: @project_id,
                                     instance_id: @instance_id,
                                     database_id: @database_id
    end

    expect(captured_output).to include "Updated data with 6 mutations"
  end
end
