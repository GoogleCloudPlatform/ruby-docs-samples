# Copyright 2015 Google, Inc
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

require File.expand_path("../../../../spec/e2e", __FILE__)
require "rspec"
require "net/http"

describe "Datastore E2E test" do
  before do
    skip "End-to-end tests skipped" unless E2E.run?

    @url = E2E.url
  end

  it "returns what we expect" do
    uri = URI.parse(@url)
    response = Net::HTTP.get(uri)
    expect(response).to include("Last 10 visits:")
    expect(response).to include("Time:")
    expect(response).to include("Addr:")
  end
end
