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
# [START dlp_inspect_string]
require "google/cloud/dlp"

# Inspects the provided text.
#
# @param [String] project_id Your Google Cloud Project ID.
# @param [String] text_to_inspect The text to inspect.
def inspect_string project_id, text_to_inspect
  # Instantiate a client
  dlp = Google::Cloud::Dlp.new

  # Construct request
  parent         = "projects/#{project_id}"
  item           = {value: text_to_inspect}
  inspect_config = {
    # The infoTypes of information to match
    info_types: [
      { name: "PHONE_NUMBER" },
      { name: "EMAIL_ADDRESS" },
      { name: "CREDIT_CARD_NUMBER" }
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
# [END dlp_inspect_string]

inspect_string *ARGV if $0 == __FILE__
