# Copyright 2019 Google LLC All Rights Reserved.
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

# [START getting_started_auth_all]
require "base64"
require "json"
require "jwt"
require "net/http"
require "openssl"
require "sinatra"
require "uri"

# [START getting_started_auth_certs]
def certificates
  uri = URI.parse "https://www.gstatic.com/iap/verify/public_key"
  response = Net::HTTP.get_response uri
  JSON.parse response.body
end

set :certificates, certificates
# [END getting_started_auth_certs]

# [START getting_started_auth_metadata]
def get_metadata item_name
  endpoint = "http://metadata.google.internal"
  path = "/computeMetadata/v1/project/#{item_name}"
  uri = URI.parse endpoint + path

  http = Net::HTTP.new uri.host, uri.port
  request = Net::HTTP::Get.new uri.request_uri
  request["Metadata-Flavor"] = "Google"
  response = http.request request
  response.body
end
# [END getting_started_auth_metadata]

# [START getting_started_auth_audience]
def audience
  project_number = get_metadata "numeric-project-id"
  project_id = get_metadata "project-id"
  "/projects/#{project_number}/apps/#{project_id}"
end

set :audience, audience
# [END getting_started_auth_audience]

# [START getting_started_auth_validate_assertion]
def validate_assertion assertion
  a_header = Base64.decode64 assertion.split(".")[0]
  key_id = JSON.parse(a_header)["kid"]
  cert = OpenSSL::PKey::EC.new settings.certificates[key_id]
  info = JWT.decode assertion, cert, true, algorithm: "ES256", aud: settings.audience
  [info[0]["email"], info[0]["sub"]]
rescue StandardError => e
  puts "Failed to validate assertion: #{e}"
  [nil, nil]
end
# [END getting_started_auth_validate_assertion]

# [START getting_started_auth_front_controller]
get "/" do
  assertion = request.env["HTTP_X_GOOG_IAP_JWT_ASSERTION"]
  email, _user_id = validate_assertion assertion
  "<h1>Hello #{email}</h1>"
end
# [END getting_started_auth_front_controller]
# [END getting_started_auth_all]
