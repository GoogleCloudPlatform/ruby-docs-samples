# Copyright 2016 Google, Inc
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "rspec"
require "google/cloud"

describe "Logging Quickstart" do

  # Simple wait method. Test for condition 5 times, delaying 1 second each time
  def wait_until times: 5, delay: 1, &condition
    times.times do
      return if condition.call
      sleep delay
    end
    raise "Condition not met. Waited #{times} times with #{delay} sec delay"
  end

  it "logs a new entry" do
    entry_filter = 'logName:"my-log" textPayload:"Hello, world!"'
    gcloud       = Google::Cloud.new ENV["GOOGLE_CLOUD_PROJECT"]
    logging      = gcloud.logging

    expect(Google::Cloud).to receive(:new).with("YOUR_PROJECT_ID").
                                           and_return(gcloud)

    entries = logging.entries filter: entry_filter
    unless entries.empty?
      logging.delete_log "my-log"
    end

    expect(logging.entries(filter: entry_filter)).to be_empty

    expect {
      load File.expand_path("../quickstart.rb", __dir__)
    }.to output(
      "Logged Hello, world!\n"
    ).to_stdout

    wait_until(delay: 2) do
      logging.entries(filter: entry_filter).any?
    end

    entries = logging.entries filter: entry_filter
    expect(entries).to_not be_empty
  end

end

