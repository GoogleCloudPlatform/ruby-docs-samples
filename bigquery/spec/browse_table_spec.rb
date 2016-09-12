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

require_relative "spec_helper"
require_relative "../browse_table"

RSpec.describe "Browses the table data" do
  it "returns the expected data" do
    allow($stdin).to receive(:gets).and_return("n")
    expect { browse_table PROJECT_ID, "test_dataset", "test_table", 1 }.to(
      output(/Alice/).to_stdout)
  end
end
