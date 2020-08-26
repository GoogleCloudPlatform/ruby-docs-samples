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

describe "functions_concepts_requests" do
  include FunctionsFramework::Testing

  it "generates the correct response body" do
    load_temporary "concepts/requests/app.rb" do
      request = make_get_request "http://example.com:8080/"
      response = call_http "concepts_requests", request
      assert_equal 200, response.status
      assert_match(/Received code:/, response.body.join)
    end
  end
end
