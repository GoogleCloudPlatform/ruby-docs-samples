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
# Imports the Google Cloud Data Loss Prevention library
require "google/cloud/dlp"

# Inspects the provided text for sensitive data.
#
# @param [String] project_id Your Google Cloud Project ID.
# @param [String] text_to_inspect The text to inspect.
def inspect_string(
    project_id      = "YOUR_PROJECT_ID",
    text_to_inspect = "My name is Gary and my email is gary@example.com"
  )

  # Instantiates a client
  dlp = Google::Cloud::Dlp.new

  # Construct request
  parent = "projects/#{project_id}"
  item = {
    value: text_to_inspect
  }
  inspect_config = {
    # The types of information to match
    info_types: [
      { name: "PHONE_NUMBER" },
      { name: "EMAIL_ADDRESS" },
      { name: "CREDIT_CARD_NUMBER" }
    ],
    # Only return results above a likelihood threshold (0 for all)
    min_likelihood: :LIKELIHOOD_UNSPECIFIED,
    # Limit the number of findings (0 for no limit)
    limits: { max_findings_per_request: 0 },
    # Whether to include the matching string in the response
    include_quote: true
  }

  # Execute request
  response = dlp.inspect_content(
    parent,
    inspect_config: inspect_config,
    item: item
  )

  # Inspect response
  findings = response.result.findings
  if findings
    puts "No findings"
  else
    findings.each do |finding|
      puts "Quote:      #{finding.quote}"
      puts "Info type:  #{finding.info_type.name}"
      puts "Likelihood: #{finding.likelihood}"
    end
  end

  # Return findings
  findings
  # [END dlp_inspect_string]
end
