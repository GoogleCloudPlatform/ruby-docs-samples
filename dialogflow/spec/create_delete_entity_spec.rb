# Copyright 2016 Google, Inc
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
require "google/cloud/dialogflow"

require_relative "../entity_type_management"
require_relative "../entity_management"

describe "Entity Type and Entity Management" do

  before do
    @project_id               = ENV["GOOGLE_CLOUD_PROJECT"]
    @entity_type_display_name = "fake_entity_type_for_testing"
    @kind                     = :KIND_MAP
    @entity_value_1           = "fake_entity_for_testing_1"
    @entity_value_2           = "fake_entity_for_testing_2"
    @synonyms                 = ["fake_synonym_for_testing_1", 
                                 "fake_synonym_for_testing_2"]
  end

  example "create entity type" do
    expect(
      (get_entity_type_ids project_id: @project_id,
                           display_name: @entity_type_display_name).size
    ).to eq(0)

    expect {
      create_entity_type project_id: @project_id,
                         display_name: @entity_type_display_name,
                         kind: @kind
    }.to output(
      /#{@entity_type_display_name}/
    ).to_stdout

    expect(
      (get_entity_type_ids project_id: @project_id,
                           display_name: @entity_type_display_name).size
    ).to eq(1)
  end

  example "create entities" do
    @entity_type_id = (get_entity_type_ids project_id: @project_id,
                                           display_name: @entity_type_display_name).first

    create_entity project_id: @project_id, entity_type_id: @entity_type_id,
                  entity_value: @entity_value_1, synonyms: [""]
    create_entity project_id: @project_id, entity_type_id: @entity_type_id,
                  entity_value: @entity_value_2, synonyms: @synonyms

    expectation = expect {
      list_entities project_id: @project_id, entity_type_id: @entity_type_id
    }

    expectation.to output(/#{@entity_value_1}/).to_stdout
    expectation.to output(/#{@entity_value_2}/).to_stdout
    expectation.to output(/#{@synonyms[0]}/).to_stdout
    expectation.to output(/#{@synonyms[1]}/).to_stdout
  end

  example "delete entities" do
    @entity_type_id = (get_entity_type_ids project_id: @project_id,
                                           display_name: @entity_type_display_name).first

    delete_entity project_id: @project_id, entity_type_id: @entity_type_id,
                  entity_value: @entity_value_1
    delete_entity project_id: @project_id, entity_type_id: @entity_type_id,
                  entity_value: @entity_value_2

    expect {
      list_entities project_id: @project_id, entity_type_id: @entity_type_id
    }.to output(
      ""
    ).to_stdout
  end

  example "delete entity type" do
    entity_type_ids = get_entity_type_ids project_id: @project_id,
                                          display_name: @entity_type_display_name
    entity_type_ids.each do |entity_type_id|
      delete_entity_type project_id: @project_id,
                         entity_type_id: entity_type_id
    end

    expect(
      (get_entity_type_ids project_id: @project_id,
                           display_name: @entity_type_display_name).size
    ).to eq(0)
  end
end
