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

require "functions_framework"
require "functions_framework/testing"
require "functions_framework/server"
require "json"
require "minitest/autorun"

describe "function_greeting" do
  include FunctionsFramework::Testing

  it "correctly responds to greeting requests" do
    load_temporary "typed/greeting/app.rb" do
      expected = {
        message: "Hello Jane Doe!"
      }

      payload = {
        first_name: "Jane",
        last_name: "Doe"
      }

      request = make_post_request "http://example.com:8080/", JSON.generate(payload)
      response = call_typed "greeting", request
      assert_equal 200, response.status
      assert_equal JSON.generate(expected), response.body.join
    end
  end
end
