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

describe "functions_firebase_auth" do
  include FunctionsFramework::Testing

  let(:source) { "//firebase.googleapis.com/projects/my-project-id" }
  let(:type) { "google.firebase.auth.user.v1.created" }

  it "responds to deletion of a Firebase Auth user object" do
    load_temporary "firebase/auth/app.rb" do
      payload = {
        "email"    => "test@nowhere.com",
        "metadata" => { "createdAt" => "2020-05-26T10:42:27Z" },
        "uid"      => "UUpby3s4spZre6kHsgVSPetzQ8l2"
      }
      event = make_cloud_event payload, source: source, type: type
      _out, err = capture_subprocess_io do
        # Call tested function
        call_event "hello_auth", event
      end

      assert_includes err, "Function triggered by creation/deletion of user: UUpby3s4spZre6kHsgVSPetzQ8l2"
      assert_includes err, "Created at: 2020-05-26T10:42:27Z"
      assert_includes err, "Email: test@nowhere.com"
    end
  end
end
