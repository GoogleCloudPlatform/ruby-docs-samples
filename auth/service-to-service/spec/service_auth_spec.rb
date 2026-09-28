# Copyright 2026 Google, Inc
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

require_relative "../service_auth"
require "rspec"
require "googleauth"
require "open3"

describe "Service to service auth sample" do
  before :all do
    require "webrick"
    @port = 8080
    @server = WEBrick::HTTPServer.new(
      Port: @port,
      Logger: WEBrick::Log.new("/dev/null"),
      AccessLog: []
    )
    @server.mount_proc "/" do |_req, res|
      res.body = "Success!"
    end
    @server_thread = Thread.new { @server.start }
    
    # Wait for server to start
    sleep 1
  end

  after :all do
    @server.shutdown
    @server_thread.join
  end
  
  it "makes an authenticated get request to the target url" do
    url = "http://localhost:#{@port}/"

    max_attempts = 5
    attempts = 0
    success = false

    while attempts < max_attempts && !success
      attempts += 1
      buffer = StringIO.new

      begin
        make_get_request buffer, url, url
        
        # Verify the output matches expected
        expect(buffer.string).to eq("Success!")
        success = true
        
      rescue StandardError, RSpec::Expectations::ExpectationNotMetError => e
        if attempts >= max_attempts
          raise "Failed after #{max_attempts} attempts. Last error: #{e.message}"
        else
          puts "make_get_request attempt #{attempts} failed: #{e.message}. Retrying in 2s..."
          sleep 2
        end
      end
    end
  end
end
