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
require_relative "../spanner_list_database_roles"
require_relative "../spanner_add_and_drop_database_role"

describe "Google Cloud Spanner Database roles" do
  before :each do
    cleanup_database_resources
  end

  after :each do
    cleanup_database_resources
    cleanup_instance_resources
  end

  example "List database roles" do
    create_singers_albums_database
    spanner_add_and_drop_database_role project_id: @project_id,
                                        instance_id: @instance_id,
                                        database_id: @database_id

    capture do
      spanner_list_database_roles project_id: @project_id,
                                  instance_id: @instance_id,
                                  database_id: @database_id
    end

    expect(captured_output).to include "new_parent"

  end
end
