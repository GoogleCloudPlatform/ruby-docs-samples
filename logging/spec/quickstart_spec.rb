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

  before(:all) do
    @gcloud       = Google::Cloud.new ENV["GOOGLE_CLOUD_PROJECT"]
    @logging      = @gcloud.logging
    @entry        = @logging.entry

    timestamp = Time.now.to_f.to_s.sub(".", "_")
    @log_name = "quickstart_log_#{time_now}"
  end

  after(:all) do
    if @logging.entries(filter: "logName:\"#{@log_name}\"").any?
      @logging.delete_log @log_name
    end
  end

  it "logs a new entry" do
    entry_filter = "logName:\"#{@log_name}\" textPayload:\"Hello, world!\""

    expect(Google::Cloud).to receive(:new).with("YOUR_PROJECT_ID").
                                           and_return(@gcloud)
    expect(@gcloud).to receive(:logging).and_return(@logging)
    expect(@logging).to receive(:entry).and_return(@entry)
    # Set log_name to a unique log to this spec run
    allow(@entry).to receive(:log_name=).with("my-log").and_wrap_original do |m, *args|
      m.call @log_name
    end
    expect(@logging.entries(filter: entry_filter)).to be_empty

    expect {
      load File.expand_path("../quickstart.rb", __dir__)
    }.to output(
      "Logged Hello, world!\n"
    ).to_stdout

    expect(@entry.log_name).to eq @log_name

    puts "OK, entry should have been written to log: #{@log_name}"

    puts "Waiting for log to appear..."
    entries = @logging.entries filter: entry_filter

    wait_until(delay: 5) do
      if entries.any?
        puts "Found matching entry for filter #{entry_filter}"
        true
      else
        puts "Getting entries again..."
        entries = @logging.entries filter: entry_filter
        false
      end
    end

    puts "OK!  We should have matching entries!"
    puts "#{entries.length}"

    expect(entries).to_not be_empty

    puts "Payloads of entries:"
    entries.each { |e| puts e.payload }

    expect(entries.first.payload).to eq "Hello, world!"
  end

end

