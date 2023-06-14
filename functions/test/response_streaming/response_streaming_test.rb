# Copyright 2023 Google LLC
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

require "minitest/autorun"
require "functions_framework/testing"

describe "functions_response_streaming" do
  include FunctionsFramework::Testing

  it "response streamed successfully" do
    load_temporary "response_streaming/app.rb" do
      request = make_post_request "http://example.com:8080/?name=Ruby", ""
      response = call_http "stream_big_query", request
      assert_equal 200, response.status
      assert_equal 1000, response.body.count
    end
  end
end
