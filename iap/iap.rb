# Copyright 2020 Google, LLC.
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

require "uri"

def make_iap_request url:, client_id:
  # [START iap_make_request]
  # url = "The Identity-Aware Proxy-protected URL to fetch"
  # client_id = "The client ID used by Identity-Aware Proxy"
  require "googleauth"
  require "faraday"

  # The client ID as the target audience for IAP
  id_token_creds = Google::Auth::Credentials.default target_audience: client_id

  headers = {}
  id_token_creds.client.apply! headers

  resp = Faraday.get url, nil, headers

  if resp.status == 200
    puts "X-Goog-Iap-Jwt-Assertion:"
    puts resp.body
  else
    puts "Error requesting IAP"
    puts resp.status
    puts resp.headers
  end
  # [END iap_make_request]
  resp
end

def verify_iap_jwt iap_jwt:, project_number: nil, project_id: nil, backend_service_id: nil
  # [START iap_validate_jwt]
  # iap_jwt = "The contents of the X-Goog-Iap-Jwt-Assertion header"
  # project_number = "The project *number* for your Google Cloud project"
  # project_id = "Your Google Cloud project ID"
  # backend_service_id = "Your Compute Engine backend service ID"
  require "googleauth"

  audience = nil
  if project_number && project_id
    # Expected audience for App Engine
    audience = "/projects/#{project_number}/apps/#{project_id}"
  elsif project_number && backend_service_id
    # Expected audience for Compute Engine
    audience = "/projects/#{project_number}/global/backendServices/#{backend_service_id}"
  end

  # The client ID as the target audience for IAP
  payload = Google::Auth::IDTokens.verify_iap iap_jwt, aud: audience

  puts payload

  if audience.nil?
    puts "Audience not verified! Supply a project_number and project_id to verify"
  end
  # [END iap_validate_jwt]
end

if $PROGRAM_NAME == __FILE__
  case ARGV.shift
  when "request"
    make_iap_request url: ARGV.shift, client_id: ARGV.shift
  when "verify"
    verify_iap_jwt iap_jwt: ARGV.shift, project_number: ARGV.shift, project_id: ARGV.shift
  else
    puts <<~USAGE
      Usage: bundle exec ruby iap.rb [command] [arguments]

      Commands:

        request <url> <client_id>

          Example:

            bundle exec iap.rb request https://my-iap-url "iap-client-id"

        verify <url> <client_id>

          Example:

            bundle exec iap.rb verify IAP_JWT "project_number" "project_id"

            bundle exec iap.rb verify IAP_JWT "project_number" "" "backend_service_id"
    USAGE
  end
end
