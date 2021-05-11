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

# rubocop:disable Lint/DuplicateBranch
# [START functions_http_content]
require "functions_framework"
require "json"

FunctionsFramework.http "http_content" do |request|
  # The request parameter is a Rack::Request object.
  # See https://www.rubydoc.info/gems/rack/Rack/Request
  content_type = request.content_type
  case content_type
  # '{"name":"John"}'
  when "application/json"
    name = (JSON.parse(request.body.read.to_s)["name"] rescue nil)
  # "John", stored in a Buffer
  when "application/octet-stream"
    name = request.body.read.to_s # Convert buffer to a string
  # "John"
  when "text/plain"
    name = request.body.read.to_s
  # "name=John" in the body of a POST request (not the URL)
  when "application/x-www-form-urlencoded"
    name = (request.params["name"] rescue nil)
  end

  name ||= "World"

  # Return the response body as a string.
  # You can also return a Rack::Response object, a Rack response array, or
  # a hash which will be JSON-encoded into a response.
  "Hello #{name}!"
end
# [END functions_http_content]
# rubocop:enable Lint/DuplicateBranch
