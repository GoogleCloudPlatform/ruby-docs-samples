# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# [START functions_http_method]
require "functions_framework"
require "json"

FunctionsFramework.http "http_method" do |request|
  # The request parameter is a Rack::Request object.
  # See https://www.rubydoc.info/gems/rack/Rack/Request
  case request.request_method
  when "GET"
    status = 200
    body = "Hello World!"
  when "PUT"
    status = 403
    body = "Forbidden!"
  else
    status = 405
    body = '{"error":"Something blew up!"}'
  end

  # Return the response body as a Rack::Response object.
  ::Rack::Response.new body, status
end
# [END functions_http_method]
