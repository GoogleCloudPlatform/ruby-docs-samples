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

describe "functions_firebase_rtdb" do
  include FunctionsFramework::Testing

  let(:source) { "//firebase.googleapis.com/projects/_/instances/my-project-id/refs/gcf-test/xyz" }
  let(:type) { "google.firebase.database.document.v1.updated" }

  it "responds to firestore rtdb update event" do
    load_temporary "firebase/rtdb/app.rb" do
      payload = {
        "params" => { "child" => "abcde" },
        "delta"  => { "foo" => "bar" }
      }
      event = make_cloud_event payload, source: source, type: type
      _out, err = capture_subprocess_io do
        call_event "hello_rtdb", event
      end

      assert_includes err, "Function triggered by change to: #{source}"
      assert_includes err, "Admin?: false"
      assert_includes err, 'Delta: {"foo"=>"bar"}'
    end
  end
end
