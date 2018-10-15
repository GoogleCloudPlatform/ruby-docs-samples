# Copyright 2018 Google, Inc
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

describe "DLP inspect text file sample" do

  it "can inspect name and email address in a text file" do
    project_id = ENV["GOOGLE_CLOUD_PROJECT"]
    current_directory = File.expand_path(File.dirname(__FILE__))
    resource_filepath = File.join current_directory, "data", "test.txt"
    snippet_filepath  = File.join current_directory, "..",
                                  "dlp_inspect_text_file.rb"

    output = `ruby #{snippet_filepath} #{project_id} #{resource_filepath}`

    expect(output).to include "EMAIL_ADDRESS"
    expect(output).to include "gary@somedomain.com"
  end

end
