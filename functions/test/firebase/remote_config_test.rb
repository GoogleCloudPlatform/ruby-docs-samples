# Copyright 2021 Google LLC
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

describe "functions_firebase_remote_config" do
  include FunctionsFramework::Testing

  it "responds to a change to a Firebase Remote Config value" do
    load_temporary "firebase/remote_config/app.rb" do
      payload = {
        "updateType"    => "FORCED_UPDATE",
        "updateOrigin"  => "CONSOLE",
        "versionNumber" => 1
      }
      event = make_cloud_event payload
      _out, err = capture_subprocess_io do
        # Call tested function
        call_event "hello_remote_config", event
      end

      assert_includes err, "Update type: FORCED_UPDATE"
      assert_includes err, "Origin: CONSOLE"
      assert_includes err, "Version: 1"
    end
  end
end
