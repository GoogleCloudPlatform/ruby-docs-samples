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
require "google/cloud"

describe "Translate Quickstart" do

  it "translates Hello, world! to Russian" do
    # Initialize and setup test objects
    gcloud = Google::Cloud.new
    translate = gcloud.translate ENV["TRANSLATE_KEY"]
    expect(Google::Cloud).to receive(:new).and_return(gcloud)
    expect(gcloud).to receive(:translate).with("YOUR_API_KEY").
                                           and_return(translate)

    # Translate
    expect {
      load File.expand_path("../quickstart.rb", __dir__)
    }.to output(
      "Text: Hello, world!\n"+
      "Translation: Привет мир!\n"
    ).to_stdout
  end

end

