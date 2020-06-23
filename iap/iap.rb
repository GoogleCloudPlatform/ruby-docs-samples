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

def request url:, client_id:
  # [START iap_make_request]
  # url = "The Identity-Aware Proxy-protected URL to fetch"
  # client_id = "The client ID used by Identity-Aware Proxy"
  require "googleauth"
  require "faraday"

  # The client ID as the target audience for IAP
  id_token_creds = Google::Auth::Credentials.default \
    target_audience: client_id

  headers = {}
  id_token_creds.client.apply! headers

  resp = Faraday.get(url) do |req|
    req.headers = headers
  end

  if resp.status == 200
    puts resp.body
  else
    puts resp.status
    puts resp.headers
    puts "Error requesting IAP"
  end
  # [END iap_make_request]
end

if $PROGRAM_NAME == __FILE__
  case ARGV.shift
  when "request"
    request url: ARGV.shift, client_id: ARGV.shift
  else
    puts <<~USAGE
      Usage: bundle exec ruby iap.rb [command] [arguments]

      Commands:
        fetch_id_token <url> <client_id>
          Example:
            bundle exec iap.rb fetch_id_token https://my-iap-url "iap-client-id"
        verify_id_token <url> <client_id>
          Example:
            bundle exec iap.rb verify_id_token https://my-iap-url "iap-client-id"
    USAGE
  end
end
