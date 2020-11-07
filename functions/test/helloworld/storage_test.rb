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

# [START functions_storage_unit_test]
require "minitest/autorun"
require "functions_framework/testing"
require "date"

describe "functions_helloworld_storage" do
  include FunctionsFramework::Testing

  let(:source) { "//storage.googleapis.com/projects/sample-project/buckets/sample-bucket/objects/ruby-rocks.rb" }
  let(:type) { "google.cloud.storage.object.v1.finalized" }

  it "responds to generic event" do
    load_temporary "helloworld/storage/app.rb" do
      timestamp = DateTime.new(2020, 2, 3, 4, 5, 6).rfc3339
      payload = {
        "bucket"         => "sample-bucket",
        "name"           => "ruby-rocks.rb",
        "metageneration" => "1",
        "timeCreated"    => timestamp,
        "updated"        => timestamp
      }
      event = make_cloud_event payload, source: source, type: type
      _out, err = capture_subprocess_io do
        call_event "hello_gcs", event
      end

      assert_match(/Event: /, err)
      assert_match(/Event Type: google.cloud.storage.object.v1.finalized/, err)
      assert_match(/Bucket: sample-bucket/, err)
      assert_match(/File: ruby-rocks.rb/, err)
      assert_match(/Metageneration: 1/, err)
      assert_match(/Created: 2020-02-03T04:05:06\+00:00/, err)
      assert_match(/Updated: 2020-02-03T04:05:06\+00:00/, err)
    end
  end
end
# [END functions_storage_unit_test]
