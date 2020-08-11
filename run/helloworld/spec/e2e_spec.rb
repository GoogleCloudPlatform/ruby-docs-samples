# Copyright 2020 Google, LLC
#
# Licensed under the Apache License, Version 2.0 (the 'License');
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an 'AS IS' BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "open3"
require "rspec"
require "rest-client"
require "securerandom"

describe "E2E tests" do
  before :all do
    suffix = SecureRandom.hex(15)
    system("gcloud", "builds", "submit", "--project=#{ENV["GOOGLE_CLOUD_PROJECT"]}", "--config=e2e_test_setup.yaml", "--substitutions=_SUFFIX=#{suffix}", "--quiet")
    @service = "helloworld-#{suffix}"
    stdout, stderr, status = Open3.capture3("gcloud run services describe --project=#{ENV["GOOGLE_CLOUD_PROJECT"]} #{@service} --format=value'('status.url')'")
    @url = stdout[0..-2] # Strip newline character

    if @url.empty?
      throw Error "No service url found. For example: https://service-x8xabcdefg-uc.a.run.app"
    end

    stdout, stderr, status = Open3.capture3("gcloud auth print-identity-token")
    @token = stdout[0..-2]
  end

  after (:all) do
    system("gcloud", "run", "services", "delete", @service, "--project=#{ENV["GOOGLE_CLOUD_PROJECT"]}", "--platform=managed", "--region=us-central1", "--quiet")
  end

  it "Can make request to service" do
    puts @url
    puts @token
    response = RestClient.get @url, Authorization: "Bearer #{@token}"
    expect(response.body).to eq("Hello Test!")
    expect(response.code).to eq(200)
  end

end
