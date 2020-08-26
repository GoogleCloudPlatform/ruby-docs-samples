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

describe "functions_http_content" do
  include FunctionsFramework::Testing

  it "handles name in the JSON body" do
    load_temporary "http/content/app.rb" do
      request = make_post_request "http://example.com:8080/", '{"name": "Ruby"}', ["content-type:application/json"]
      response = call_http "http_content", request
      assert_equal 200, response.status
      assert_equal "Hello Ruby!", response.body.join
    end
  end

  it "handles name in the octet-stream" do
    load_temporary "http/content/app.rb" do
      request = make_post_request "http://example.com:8080/", "Ruby", ["content-type:application/octet-stream"]
      response = call_http "http_content", request
      assert_equal 200, response.status
      assert_equal "Hello Ruby!", response.body.join
    end
  end

  it "handles name in the plaintext body" do
    load_temporary "http/content/app.rb" do
      request = make_post_request "http://example.com:8080/", "Ruby", ["content-type:text/plain"]
      response = call_http "http_content", request
      assert_equal 200, response.status
      assert_equal "Hello Ruby!", response.body.join
    end
  end

  it "handles name in the form-urlencoded body" do
    load_temporary "http/content/app.rb" do
      request = make_post_request "http://example.com:8080/", "name=Ruby", ["content-type:application/x-www-form-urlencoded"]
      response = call_http "http_content", request
      assert_equal 200, response.status
      assert_equal "Hello Ruby!", response.body.join
    end
  end
end
