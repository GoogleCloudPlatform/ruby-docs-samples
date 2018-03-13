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

def inspect_string string: nil, project_id: nil, max_findings: 0
  # [START dlp_inspect_string]
  # string       = "the text to inspect"
  # project_id   = "Your Google Cloud project ID"
  # max_findings = "maximum number of findings to report per request (0 = server maximum)"

  require "google/cloud/dlp"

  dlp = Google::Cloud::Dlp.new
  inspect_config = {
    # The types of information to match
    info_types: [{name: "PERSON_NAME"}, {name: "US_STATE"}],

    # Only return results above a likelihood threshold (0 for all)
    min_likelihood: :POSSIBLE,

    # Limit the number of findings (0 for no limit)
    limits: { max_findings_per_request: max_findings },

    # Whether to include the matching string in the response
    include_quote: true
  }

  # The item to inspect
  item_to_inspect = { value: string }

  # Run request
  parent = dlp.class.project_path project_id
  response = dlp.inspect_content parent,
    inspect_config: inspect_config,
    item: item_to_inspect

  # Print the results
  response.result.findings.each do |finding|
    puts "Quote:      #{finding.quote}"
    puts "Info type:  #{finding.info_type.name}"
    puts "Likelihood: #{finding.likelihood}"
  end.empty? and begin
    puts "No findings"
  end
  # [END dlp_inspect_string]
end

def inspect_file filename: nil, project_id: nil, max_findings: 0
  # [START dlp_inspect_file]
  # string       = "the text to inspect"
  # project_id   = "Your Google Cloud project ID"
  # max_findings = "maximum number of findings to report per request (0 = server maximum)"

  require "google/cloud/dlp"

  dlp = Google::Cloud::Dlp.new
  inspect_config = {
    # The types of information to match
    info_types: [{name: "PERSON_NAME"}, {name: "PHONE_NUMBER"}],

    # Only return results above a likelihood threshold (0 for all)
    min_likelihood: :POSSIBLE,

    # Limit the number of findings (0 for no limit)
    limits: { max_findings_per_request: max_findings },

    # Whether to include the matching string in the response
    include_quote: true
  }

  # The item to inspect
  file = File.open filename, "rb"
  item = { byte_item: { type: :BYTES_TYPE_UNSPECIFIED, data: file.read } }

  # Run request
  parent = dlp.class.project_path project_id
  response = dlp.inspect_content parent,
    inspect_config: inspect_config,
    item: item

  # Print the results
  response.result.findings.each do |finding|
    puts "Quote:      #{finding.quote}"
    puts "Info type:  #{finding.info_type.name}"
    puts "Likelihood: #{finding.likelihood}"
  end.empty? and begin
    puts "No findings"
  end
  # [END dlp_inspect_file]
end

require "google/cloud/dlp"

if __FILE__ == $PROGRAM_NAME
  project_id = ENV["GCLOUD_PROJECT"]
  command    = ARGV.shift

  case command
  when "inspect_string"
    inspect_string project_id: project_id, string: ARGV.first
  when "inspect_file"
    inspect_file project_id: project_id, filename: ARGV.first
  else
    puts <<-usage
Usage: ruby sample.rb <command> [arguments]

Commands:
  inspect_string                 <filename> Inspect a string.
  inspect_file                   <filename> Inspect a local file.
    usage
  end
end
