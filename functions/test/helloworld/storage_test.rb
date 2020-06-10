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
require "base64"

describe "functions_helloworld_storage" do
  include FunctionsFramework::Testing

  let(:source) { "//storage.googleapis.com/projects/sample-project/buckets/sample-bucket/objects/ruby-rocks.rb" }
  let(:type) { "google.storage.object.change.v1" }

  it "responds to deleted event" do
    load_temporary "helloworld/storage.rb" do
      payload = {
        "name"           => "ruby-rocks.rb",
        "resourceState"  => "not_exists",
        "metageneration" => "1"
      }
      event = make_cloud_event payload, source: source, type: type
      _out, err = capture_subprocess_io do
        call_event "hello-gcs", event
      end
      assert_match(/File ruby-rocks\.rb deleted\./, err)
    end
  end

  it "responds to uploaded event" do
    load_temporary "helloworld/storage.rb" do
      payload = {
        "name"           => "ruby-rocks.rb",
        "metageneration" => "1"
      }
      event = make_cloud_event payload, source: source, type: type
      _out, err = capture_subprocess_io do
        call_event "hello-gcs", event
      end
      assert_match(/File ruby-rocks\.rb uploaded\./, err)
    end
  end

  it "responds to updated event" do
    load_temporary "helloworld/storage.rb" do
      payload = {
        "name"           => "ruby-rocks.rb",
        "metageneration" => "2"
      }
      event = make_cloud_event payload, source: source, type: type
      _out, err = capture_subprocess_io do
        call_event "hello-gcs", event
      end
      assert_match(/File ruby-rocks\.rb metadata updated\./, err)
    end
  end
end
