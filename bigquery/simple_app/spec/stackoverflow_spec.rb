# Copyright 2017 Google LCC
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

describe "BigQuery Stack Overflow" do
  it "queries stackoverflow dataset" do
    expect {
      load File.expand_path("../stackoverflow.rb", __dir__)
    }.to output(
      /stackoverflow\.com.*views/
    ).to_stdout
  end
end
