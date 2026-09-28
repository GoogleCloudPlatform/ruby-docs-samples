# Copyright 2026 Google LLC
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

require "net/http"
require "uri"
require "googleauth"

def make_get_request writer, target_url, audience
  credentials = Google::Auth.get_application_default target_audience: audience
  token_info = credentials.fetch_access_token!

  uri = URI target_url
  request = Net::HTTP::Get.new uri

  request["Authorization"] = "Bearer #{token_info['id_token']}"

  response = Net::HTTP.start uri.hostname, uri.port, use_ssl: uri.scheme == "https" do |http|
    http.request request
  end

  response.value

  writer.write response.body
rescue StandardError => e
  raise "Failed to make get request: #{e.message}"
end
