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
require "google/cloud/language"

describe "Language Quickstart" do

  it "detect sentiment" do
    language = Google::Cloud::Language.new
    expect(Google::Cloud::Language).to receive(:new).
                                         with(project: "YOUR_PROJECT_ID").
                                         and_return(language)

    expect {
      load File.expand_path("../quickstart.rb", __dir__)
    }.to output(
      /Text: Hello, world!\nScore: \d\.\d+, \d\.\d+/
    ).to_stdout
  end

end

