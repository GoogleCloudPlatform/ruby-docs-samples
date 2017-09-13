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
require "google/cloud/vision"

describe "Vision Quickstart" do

  it "performs label detection on a sample image file" do
    vision = Google::Cloud::Vision.new
    expect(Google::Cloud::Vision).to receive(:new).
                                     and_return(vision)

    expect {
      load File.expand_path("../quickstart.rb", __dir__)
    }.to output(
      /Labels:.*cat.*/m
    ).to_stdout
  end

end
