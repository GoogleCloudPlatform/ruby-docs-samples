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

require_relative "../spanner_samples"
require "rspec"
require "google/cloud/spanner"

describe "Spanner Quickstart" do
  it "outputs a 1" do
    if ENV["GOOGLE_CLOUD_SPANNER_TEST_INSTANCE"].nil? || ENV["GOOGLE_CLOUD_SPANNER_PROJECT"].nil?
      skip "GOOGLE_CLOUD_SPANNER_TEST_INSTANCE and/or GOOGLE_CLOUD_SPANNER_PROJECT not defined"
    end

    @project_id  = ENV["GOOGLE_CLOUD_SPANNER_PROJECT"]
    @instance_id = ENV["GOOGLE_CLOUD_SPANNER_TEST_INSTANCE"]
    @seed        = SecureRandom.hex 8
    @database_id = "test_db_#{@seed}"
    @spanner     = Google::Cloud::Spanner.new project: @project_id
    @instance    = @spanner.instance @instance_id

    unless @instance.database @database_id
      real_stdout = $stdout
      $stdout = StringIO.new
      create_database project_id:  @project_id,
                      instance_id: @instance_id,
                      database_id: @database_id
      $stdout = real_stdout
    end

    @database_client = @spanner.client @instance_id, @database_id

    expect(Google::Cloud::Spanner).to receive(:new)
      .with(project: "YOUR_PROJECT_ID")
      .and_return(@spanner)

    expect(@spanner).to receive(:client)
      .with("my-instance", "my-database")
      .and_return(@database_client)

    expect {
      load File.expand_path("../quickstart.rb", __dir__)
    }.to output(/1/).to_stdout

    @instance.database(@database_id).drop
  end
end
