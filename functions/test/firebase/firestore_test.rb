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

describe "functions_firebase_firestore" do
  include FunctionsFramework::Testing

  let(:source) { "//firestore.googleapis.com/projects/project-id/databases/(default)/documents/gcf-test/12345678" }
  let(:type) { "google.cloud.firestore.document.v1.written" }

  it "responds to firestore document change event" do
    load_temporary "firebase/firestore/app.rb" do
      payload = {
        "oldValue" => { "a" => 1 },
        "value"    => { "b" => 2 }
      }
      event = make_cloud_event payload, source: source, type: type
      _out, err = capture_subprocess_io do
        # Call tested function
        call_event "hello_firestore", event
      end

      assert_includes err, "Function triggered by change to: #{source}"
      assert_match(/Old value: {"a"=>1}/, err)
      assert_match(/New value: {"b"=>2}/, err)
    end
  end
end
