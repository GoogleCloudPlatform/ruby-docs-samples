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
require "rspec/retry"
require "google/cloud/logging"

describe "Logging Quickstart" do

  def wait_until &condition
    1.upto(7) do |n|
      return if condition.call
      sleep 2**n
    end
    raise "Attempted to wait but Condition not met."
  end

  def delete_log_entries
    begin
      @logging.delete_log @log_name
    rescue Google::Cloud::NotFoundError
    end
  end

  before do
    @logging  = Google::Cloud::Logging.new
    @entry    = @logging.entry
    @log_name = "projects/#{@logging.project}/logs/quickstart_log"

    @entry.log_name = @log_name

    delete_log_entries
  end

  after do
    delete_log_entries
  end

  def test_log_entries
    @logging.entries filter: %Q{logName = "#{@log_name}"}
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

    entries = test_log_entries;

    wait_until { entries = test_log_entries; entries.any? }

    expect(entries).not_to be_empty
    expect(entries.length).to eq 1

    entry = entries.first
    expect(entry.payload).to eq "Hello, world!"
  end
end

