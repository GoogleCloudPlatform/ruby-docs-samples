# Copyright 2017 Google, Inc
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

require_relative "../spanner_samples"
require "rspec"
require "google/cloud/spanner"

describe "Google Cloud Spanner API samples" do

  before do
    @spanner    = Google::Cloud::Spanner.new
    @project_id = @spanner.project_id
    @instance   = @spanner.instance ENV["GOOGLE_CLOUD_SPANNER_TEST_INSTANCE"]
  end

  after do
    # delete the temporary database that was used for this example
    if @database_id && @instance.database(@database_id)
      @instance.database(@database_id).drop
    end
  end

  # Capture and return STDOUT output by block
  def capture &block
    real_stdout = $stdout
    $stdout = StringIO.new
    block.call
    @captured_output = $stdout.string
  ensure
    $stdout = real_stdout
  end
  attr_reader :captured_output

  example "create_database" do
    @database_id = "test_database_#{Time.now.to_i}"

    expect(@instance.databases.map(&:database_id)).not_to include @database_id

    capture do
      create_database project_id:  @project_id,
                      instance_id: @instance.instance_id,
                      database_id: @database_id
    end

    expect(captured_output).to include(
      "Waiting for create database operation to complete"
    )
    expect(captured_output).to include(
      "Created database #{@database_id} on instance #{@instance.instance_id}"
    )

    database = @instance.database @database_id
    expect(database).not_to be nil

    data_definition_statements = database.ddl
    expect(data_definition_statements.size).to eq 2
    expect(data_definition_statements.first).to include "CREATE TABLE Singers"
    expect(data_definition_statements.last).to  include "CREATE TABLE Albums"
  end

end
