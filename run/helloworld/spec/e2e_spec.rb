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

require "rspec"
require "rspec/retry"
require "rest-client"
require "securerandom"

describe "E2E tests" do
  before (:all) do
    if !ENV["GOOGLE_CLOUD_PROJECT"]
      raise "GOOGLE_CLOUD_PROJECT env var not found."
    end
    suffix = SecureRandom.hex(15)
    system("gcloud",
      "builds",
      "submit",
      "--project=#{ENV["GOOGLE_CLOUD_PROJECT"]}",
      "--config=e2e_test_setup.yaml",
      "--substitutions=_SUFFIX=#{suffix}"
    )

    sleep 20 # Wait for serivce to be available for describe
    @service = "helloworld-#{suffix}"

    io = IO.popen(
      "gcloud run services describe #{@service} "\
      "--project=#{ENV["GOOGLE_CLOUD_PROJECT"]} "\
      "--platform=managed "\
      "--region=us-central1 "\
      "--format=value'('status.url')'"
    )
    url = io.read

    if url.downcase.include? "error"
      raise "Error: Can not retrieve Cloud Run service URL: #{url}"
    end
    @url = url.chomp

    if @url.empty?
      raise "Error: No service url found. For example: https://service-x8xabcdefg-uc.a.run.app"
    end

    io = IO.popen("gcloud auth print-identity-token")
    token = io.read
    @token = token.chomp
  end

  after (:all) do
    system("gcloud",
      "run",
      "services",
      "delete",
      @service,
      "--project=#{ENV["GOOGLE_CLOUD_PROJECT"]}",
      "--platform=managed",
      "--region=us-central1",
      "--quiet"
    )
  end

  it "Can make request to service", :retry => 3 do
    begin
      response = RestClient.get @url, Authorization: "Bearer #{@token}"
      expect(response.body).to eq("Hello Test!")
      expect(response.code).to eq(200)
    rescue RestClient::InternalServerError => error
      log.error error.message
      raise
    end
  end
end
