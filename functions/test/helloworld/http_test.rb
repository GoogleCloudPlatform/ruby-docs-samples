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

# [START functions_http_unit_test]
require "minitest/autorun"
require "functions_framework/testing"

describe "functions_helloworld_http" do
  include FunctionsFramework::Testing

  it "prints a name" do
    load_temporary "helloworld/http/app.rb" do
      request = make_post_request "http://example.com:8080/", '{"name": "Ruby"}'
      response = call_http "hello_http", request
      assert_equal 200, response.status
      assert_equal "Hello Ruby!", response.body.join
    end
  end

  it "prints hello world" do
    load_temporary "helloworld/http/app.rb" do
      request = make_post_request "http://example.com:8080/", ""
      response = call_http "hello_http", request
      assert_equal 200, response.status
      assert_equal "Hello World!", response.body.join
    end
  end
end
# [END functions_http_unit_test]

describe "functions_helloworld_http" do
  include FunctionsFramework::Testing

  it "prints a name in a query parameter" do
    load_temporary "helloworld/http/app.rb" do
      request = make_post_request "http://example.com:8080/?name=Ruby", ""
      response = call_http "hello_http", request
      assert_equal 200, response.status
      assert_equal "Hello Ruby!", response.body.join
    end
  end
end
