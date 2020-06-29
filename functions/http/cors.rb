# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "functions_framework"

# [START functions_http_cors]
FunctionsFramework.http "cors_enabled_function" do |request|
  # For more information about CORS and CORS preflight requests, see
  # https://developer.mozilla.org/en-US/docs/Glossary/Preflight_request
  # for more information.

  # Set CORS headers for the preflight request
  if request.options?
    # Allows GET requests from any origin with the Content-Type
    # header and caches preflight response for an 3600s
    headers = {
      "Access-Control-Allow-Origin"  => "*",
      "Access-Control-Allow-Methods" => "GET",
      "Access-Control-Allow-Headers" => "Content-Type",
      "Access-Control-Max-Age"       => "3600"
    }
    [204, headers, []]
  else
    # Set CORS headers for the main request
    headers = {
      "Access-Control-Allow-Origin" => "*"
    }

    [200, headers, ["Hello World!"]]
  end
end
# [END functions_http_cors]

# [START functions_http_cors_auth]
FunctionsFramework.http "cors_enabled_function_auth" do |request|
  # For more information about CORS and CORS preflight requests, see
  # https://developer.mozilla.org/en-US/docs/Glossary/Preflight_request
  # for more information.

  # Set CORS headers for preflight requests
  if request.options?
    # Allows GET requests from origin https://mydomain.com with
    # Authorization header
    headers = {
      "Access-Control-Allow-Origin"      => "https://mydomain.com",
      "Access-Control-Allow-Methods"     => "GET",
      "Access-Control-Allow-Headers"     => "Authorization",
      "Access-Control-Max-Age"           => "3600",
      "Access-Control-Allow-Credentials" => "true"
    }
    [204, headers, []]
  else
    # Set CORS headers for main requests
    headers = {
      "Access-Control-Allow-Origin"      => "https://mydomain.com",
      "Access-Control-Allow-Credentials" => "true"
    }

    [200, headers, ["Hello World!"]]
  end
end
# [END functions_http_cors_auth]
