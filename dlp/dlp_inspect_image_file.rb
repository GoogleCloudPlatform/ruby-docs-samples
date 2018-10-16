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
# [START dlp_inspect_image_file]
require "google/cloud/dlp"

def inspect_image_file (
    project_id = "YOUR_PROJECT_ID",
    filepath   = "path/to/image.png"
  )

  # Instantiate a client
  dlp = Google::Cloud::Dlp.new

  # Get the bytes of the file
  file_bytes = File.binread filepath

  # Construct request
  parent         = "projects/#{project_id}"
  item           = { byte_item: { type: :IMAGE_PNG, data: file_bytes } }
  inspect_config = {
    # The infoTypes of information to match
    info_types: [
      { name: "PHONE_NUMBER" },
      { name: "EMAIL_ADDRESS" },
      { name: "CREDIT_CARD_NUMBER" },
    ],
    # Whether to include the matching string
    include_quote: true
  }

  # Run request
  response = dlp.inspect_content(
    parent,
    inspect_config: inspect_config,
    item:           item
  )

  # Print the results
  if response.result.findings.empty?
    puts "No findings"
  else
    response.result.findings.each do |finding|
      puts "Quote:      #{finding.quote}"
      puts "Info type:  #{finding.info_type.name}"
      puts "Likelihood: #{finding.likelihood}"
    end
  end
end
# [END dlp_inspect_image_file]

inspect_image_file *ARGV if $0 == __FILE__
