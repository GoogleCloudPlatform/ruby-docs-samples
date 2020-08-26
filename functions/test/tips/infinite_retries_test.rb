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

describe "functions_tips_infinite_retries" do
  include FunctionsFramework::Testing

  it "stops processing on an old event" do
    load_temporary "tips/infinite_retries/app.rb" do
      event_time = Time.now - 11
      event = make_cloud_event "", time: event_time
      _out, err = capture_subprocess_io do
        call_event "avoid_infinite_retries", event
      end
      assert_match(/Dropped/, err)
    end
  end

  it "continues processing on a recent event" do
    load_temporary "tips/infinite_retries/app.rb" do
      event_time = Time.now
      event = make_cloud_event "", time: event_time
      assert_raises "I failed!" do
        capture_subprocess_io do
          call_event "avoid_infinite_retries", event
        end
      end
    end
  end
end
