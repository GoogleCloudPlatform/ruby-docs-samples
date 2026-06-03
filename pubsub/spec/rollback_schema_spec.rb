# Copyright 2026 Google LLC
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
require "google/cloud/pubsub"
require "securerandom"
require_relative "../rollback_schema"

RSpec.describe "Rollback Schema" do
  before :all do
    @project_id = ENV["GOOGLE_CLOUD_PROJECT"]
    if @project_id.nil?
      skip "GOOGLE_CLOUD_PROJECT not defined"
    end

    @pubsub = Google::Cloud::PubSub.new project_id: @project_id
    @schema_client = @pubsub.schema_service_client
    @schema_id = "test-schema-#{SecureRandom.hex(4)}"
    @schema_path = "projects/#{@project_id}/schemas/#{@schema_id}"

    # Create schema (Revision 1)
    @definition_1 = "syntax = 'proto3'; message Message { string data = 1; }"
    schema = {
      name: @schema_path,
      type: :PROTOCOL_BUFFER,
      definition: @definition_1
    }
    @initial_schema = @schema_client.create_schema(
      parent: "projects/#{@project_id}",
      schema: schema,
      schema_id: @schema_id
    )
    @revision_1_id = @initial_schema.revision_id

    # Commit revision (Revision 2)
    @definition_2 = "syntax = 'proto3'; message Message { string data = 1; string new_field = 2; }"
    @second_schema = @schema_client.commit_schema(
      name: @schema_path,
      schema: {
        name: @schema_path,
        type: :PROTOCOL_BUFFER,
        definition: @definition_2
      }
    )
    @revision_2_id = @second_schema.revision_id
  end

  after :all do
    if @schema_client && @schema_path
      begin
        @schema_client.delete_schema name: @schema_path
      rescue StandardError => e
        puts "Error cleaning up schema: #{e.message}"
      end
    end
  end

  it "rolls back the schema to a previous revision" do
    expect {
      rollback_schema(
        project_id: @project_id,
        schema_id: @schema_id,
        revision_id: @revision_1_id
      )
    }.to output(/Rolled back schema:.*#{@schema_id}/).to_stdout

    # Verify the current schema revision is indeed a copy of revision 1
    current_schema = @schema_client.get_schema name: @schema_path
    expect(current_schema.definition).to eq(@definition_1)
    expect(current_schema.revision_id).not_to eq(@revision_1_id)
    expect(current_schema.revision_id).not_to eq(@revision_2_id)
  end
end
