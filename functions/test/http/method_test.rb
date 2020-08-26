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

require "helper"
require "json"

describe "functions_http_method" do
  include FunctionsFramework::Testing

  it "handles GET requests" do
    load_temporary "http/method/app.rb" do
      request = make_get_request "http://example.com:8080/"
      response = call_http "http_method", request
      assert_equal 200, response.status
      assert_equal "Hello World!", response.body.join
    end
  end

  it "handles PUT requests" do
    load_temporary "http/method/app.rb" do
      request = make_post_request "http://example.com:8080/", "Ruby", ["content-type:text/plain"]
      request.env[::Rack::REQUEST_METHOD] = ::Rack::PUT

      response = call_http "http_method", request
      assert_equal 403, response.status
      assert_equal "Forbidden!", response.body.join
    end
  end

  it "handles POST requests" do
    load_temporary "http/method/app.rb" do
      request = make_post_request "http://example.com:8080/", "Ruby", ["content-type:text/plain"]
      response = call_http "http_method", request
      assert_equal 405, response.status
      assert_equal "Something blew up!", JSON.parse(response.body.join)["error"]
    end
  end
end
