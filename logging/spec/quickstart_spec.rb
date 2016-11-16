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
require "google/cloud/logging"

describe "Logging Quickstart" do

  # Simple wait method. Test for condition 5 times, delaying 1 second each time
  def wait_until times: 5, delay: 1, &condition
    times.times do
      return if condition.call
      sleep delay
    end
    raise "Condition not met. Waited #{times} times with #{delay} sec delay"
  end

  before do
    @logging  = Google::Cloud::Logging.new
    @entry    = @logging.entry
    @log_name = "projects/#{ENV["GOOGLE_CLOUD_PROJECT"]}/logs/" +
                "quickstart_log_#{Time.now.to_i}"

    @entry.log_name = @log_name
  end

  after do
    begin
      @logging.delete_log @log_name
    rescue Google::Cloud::NotFoundError
    end
  end

  def test_log_entries
    @logging.entries filter: %Q{logName="#{@log_name}"}
  end

  it "logs a new entry" do
    expect(Google::Cloud::Logging).to receive(:new).
                                      with(project: "YOUR_PROJECT_ID").
                                      and_return(@logging)
    expect(@logging).to receive(:entry).and_return(@entry)
    allow(@entry).to receive(:log_name=).with("my-log")

    expect(test_log_entries).to be_empty

    expect {
      load File.expand_path("../quickstart.rb", __dir__)
    }.to output(
      "Logged Hello, world!\n"
    ).to_stdout

    entries = []

    wait_until { entries = test_log_entries; entries.any? }

    expect(entries).not_to be_empty
    expect(entries.length).to eq 1

    entry = entries.first
    expect(entry.payload).to eq "Hello, world!"
  end
end

