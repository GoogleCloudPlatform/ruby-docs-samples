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

require "helper"

##
# Make a simple OPTIONS request, for passing to a function test.
#
# @param url [URI,String] The URL to get.
# @return [Rack::Request]
#
def make_options_request url, headers = []
  env = ::FunctionsFramework::Testing.build_standard_env URI(url), headers
  env[::Rack::REQUEST_METHOD] = ::Rack::OPTIONS
  ::Rack::Request.new env
end

describe "functions_http_cors" do
  include FunctionsFramework::Testing

  it "handles CORS enabled preflight requests" do
    load_temporary "http/cors/app.rb" do
      request = make_options_request "http://example.com:8080/"
      response = call_http "cors_enabled_function", request
      assert_equal 204, response.status
      assert_equal "*", response.get_header("Access-Control-Allow-Origin")
      assert_equal "GET", response.get_header("Access-Control-Allow-Methods")
      assert_equal "Content-Type", response.get_header("Access-Control-Allow-Headers")
      assert_equal "3600", response.get_header("Access-Control-Max-Age")
    end
  end

  it "handles CORS enabled GET requests" do
    load_temporary "http/cors/app.rb" do
      request = make_get_request "http://example.com:8080/"
      response = call_http "cors_enabled_function", request
      assert_equal 200, response.status
      assert_equal "*", response.get_header("Access-Control-Allow-Origin")
    end
  end

  it "handles CORS enabled preflight requests with auth enforced" do
    load_temporary "http/cors/app.rb" do
      request = make_options_request "http://example.com:8080/"
      response = call_http "cors_enabled_function_auth", request
      assert_equal 204, response.status
      assert_equal "https://mydomain.com", response.get_header("Access-Control-Allow-Origin")
      assert_equal "GET", response.get_header("Access-Control-Allow-Methods")
      assert_equal "Authorization", response.get_header("Access-Control-Allow-Headers")
      assert_equal "3600", response.get_header("Access-Control-Max-Age")
      assert_equal "true", response.get_header("Access-Control-Allow-Credentials")
    end
  end

  it "handles CORS enabled GET requests with auth enforced" do
    load_temporary "http/cors/app.rb" do
      request = make_get_request "http://example.com:8080/"
      response = call_http "cors_enabled_function_auth", request
      assert_equal 200, response.status
      assert_equal "https://mydomain.com", response.get_header("Access-Control-Allow-Origin")
      assert_equal "true", response.get_header("Access-Control-Allow-Credentials")
    end
  end
end
