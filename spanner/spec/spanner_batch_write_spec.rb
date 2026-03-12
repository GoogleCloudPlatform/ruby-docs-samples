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

require "spec_helper"
require_relative "../spanner_batch_write"

describe "spanner_batch_write" do
  before :all do
    create_singers_albums_database
  end

  after :all do
    cleanup_database_resources
  end

  it "applies mutation groups" do
    expect {
      spanner_batch_write project_id: @project_id,
                          instance_id: @instance_id,
                          database_id: @database_id
    }.to output(/Mutation group indexes applied: (\[0, 1\]|\[0\].*\[1\])/m).to_stdout

    # Verify that the records were inserted
    client = @spanner.client @instance_id, @database_id
    results = client.execute "SELECT COUNT(*) FROM Singers"
    expect(results.rows.first[0]).to eq 3 # 16, 17, 18
  end
end
