# Copyright 2021 Google, Inc
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

require_relative "../database_leader_placement_samples"
require_relative "./spec_helper"

describe "Spanner database leader placement" do
  before :each do
    cleanup_database_resources
  end

  after :each do
    cleanup_database_resources
  end

  example "instance_config" do
    capture do
      instance_config project_id: @project_id, instance_config_id: "nam6"
    end

    expect(captured_output).to include(
      "Available leader options for instance config"
    )
  end

  example "list_instance_configs" do
    capture do
      list_instance_configs project_id: @project_id
    end

    expect(captured_output).to include(
      "Available leader options for instance config projects/#{@project_id}/instanceConfigs"
    )
  end

  example "create_and_update_database_with_default_leader" do
    capture do
      create_database_with_default_leader project_id: @project_id,
                                          instance_id: @instance_id,
                                          database_id: @database_id,
                                          default_leader: "us-central1"
    end

    expect(captured_output).to include(@database_id)
    expect(captured_output).to include("default leader: us-central1")

    capture do
      update_database_with_default_leader project_id: @project_id,
                                          instance_id: @instance_id,
                                          database_id: @database_id,
                                          default_leader: "us-east4"
    end

    expect(captured_output).to include("Updated default leader")
  end

  example "list_databases" do
    create_database_with_default_leader project_id: @project_id,
                                        instance_id: @instance_id,
                                        database_id: @database_id,
                                        default_leader: "us-central1"

    capture do
      list_databases project_id: @project_id, instance_id: @instance_id
    end

    expect(captured_output).to include(@database_id)
  end

  example "database_ddl" do
    create_database_with_default_leader project_id: @project_id,
                                        instance_id: @instance_id,
                                        database_id: @database_id,
                                        default_leader: "us-central1"

    capture do
      database_ddl project_id: @project_id,
                   instance_id: @instance_id,
                   database_id: @database_id
    end

    expect(captured_output).to include(@database_id)
  end

  example "query_information_schema_database_options" do
    create_database_with_default_leader project_id: @project_id,
                                        instance_id: @instance_id,
                                        database_id: @database_id,
                                        default_leader: "us-central1"

    capture do
      query_information_schema_database_options project_id: @project_id,
                                                instance_id: @instance_id,
                                                database_id: @database_id
    end

    expect(captured_output).to include("us-central1")
  end
end
