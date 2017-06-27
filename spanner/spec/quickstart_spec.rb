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
require "google/cloud/spanner"

describe "Spanner Quickstart" do

  it "outputs a 1" do
    spanner         = Google::Cloud::Spanner.new
    instance_id     = ENV["GOOGLE_CLOUD_SPANNER_TEST_INSTANCE"]
    database_id     = ENV["GOOGLE_CLOUD_SPANNER_TEST_DATABASE"]
    database_client = spanner.client instance_id, database_id

    expect(Google::Cloud::Spanner).to receive(:new).
                                      with(project: "YOUR_PROJECT_ID").
                                      and_return(spanner)

    expect(spanner).to receive(:client).
                       with("my-instance", "my-databaes").
                       and_return(database_client)

    expect {
      load File.expand_path("../quickstart.rb", __dir__)
    }.to output("1").to_stdout
  end

end
