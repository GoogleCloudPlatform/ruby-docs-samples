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

require_relative "../database_leader_placement_samples"
require_relative "./spec_helper"

describe "Spanner database leader placement" do
  def find_or_create_multi_region_instance
    @multi_region_instance_id = "test-multi-region-#{@seed}"
    @multi_region_instance ||= find_instance(@multi_region_instance_id)

    return @multi_region_instance if @multi_region_instance

    request = {
      parent: project_path,
      instance_id: @multi_region_instance_id,
      instance: Google::Cloud::Spanner::Admin::Instance::V1::Instance.new({
        display_name: "Ruby test leader placement",
        config: instance_config_path("nam6"),
        node_count: 1
      })
    }
    job = instance_admin_client.create_instance request
    job.wait_until_done!

    raise job.error if job.error?

    @multi_region_instance = job.results
    @created_instance_ids << @multi_region_instance_id
    @multi_region_instance
  end

  before :each do
    find_or_create_multi_region_instance
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
    database_id = "test_db_#{SecureRandom.hex(8)}"

    capture do
      create_database_with_default_leader project_id: @project_id,
                                          instance_id: @multi_region_instance_id,
                                          database_id: database_id,
                                          default_leader: "us-central1"
    end

    expect(captured_output).to include(database_id)
    expect(captured_output).to include("default leader: us-central1")

    capture do
      update_database_with_default_leader project_id: @project_id,
                                          instance_id: @multi_region_instance_id,
                                          database_id: database_id,
                                          default_leader: "us-east1"
    end

    expect(captured_output).to include("Updated default leader")
  end

  example "list_databases" do
    database_id = "test_db_#{SecureRandom.hex(8)}"
    create_database_with_default_leader project_id: @project_id,
                                        instance_id: @multi_region_instance_id,
                                        database_id: database_id,
                                        default_leader: "us-central1"

    capture do
      list_databases project_id: @project_id, instance_id: @multi_region_instance_id
    end

    expect(captured_output).to include(database_id)
  end

  example "database_ddl" do
    database_id = "test_db_#{SecureRandom.hex(8)}"

    create_database_with_default_leader project_id: @project_id,
                                        instance_id: @multi_region_instance_id,
                                        database_id: database_id,
                                        default_leader: "us-central1"

    capture do
      database_ddl project_id: @project_id,
                   instance_id: @multi_region_instance_id,
                   database_id: database_id
    end

    expect(captured_output).to include(database_id)
  end

  example "query_information_schema_database_options" do
    database_id = "test_db_#{SecureRandom.hex(8)}"

    create_database_with_default_leader project_id: @project_id,
                                        instance_id: @multi_region_instance_id,
                                        database_id: database_id,
                                        default_leader: "us-central1"

    capture do
      query_information_schema_database_options project_id: @project_id,
                                                instance_id: @multi_region_instance_id,
                                                database_id: database_id
    end

    expect(captured_output).to include("us-central1")
  end
end
