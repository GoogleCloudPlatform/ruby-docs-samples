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

describe "functions_firebase_analytics" do
  include FunctionsFramework::Testing

  let(:source) { "//firebase.googleapis.com/projects/_/instances/my-project-id/refs/gcf-test/xyz" }
  let(:type) { "google.firebase.analytics.log.v1.written" }

  it "responds to Google Analytics for Firebase log event" do
    load_temporary "firebase/analytics/app.rb" do
      payload = {
        "eventDim" => [
          {
            "name"            => "hello",
            "timestampMicros" => "1234567890123456"
          }
        ],
        "userDim" => {
          "deviceInfo" => {
            "deviceModel" => "Federation Tricorder"
          },
          "geoInfo" => {
            "city"    => "Auckland",
            "country" => "New Zealand"
          }
        }
      }
      event = make_cloud_event payload, source: source, type: type
      _out, err = capture_subprocess_io do
        # Call tested function
        call_event "hello_analytics", event
      end

      assert_includes err, "Function triggered by the following event: #{source}"
      assert_includes err, "Name: hello"
      assert_includes err, "Timestamp: 2009-02-13T23:31:30Z"
      assert_includes err, "Device Model: Federation Tricorder"
      assert_includes err, "Location: Auckland, New Zealand"
    end
  end
end
