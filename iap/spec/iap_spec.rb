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

require_relative "../iap"
require "rspec"
require "stringio"

def fetch_iap_jwt
  url = "https://print-iap-jwt-assertion-dot-cloud-iap-for-testing.uc.r.appspot.com"
  client_id = "1031437410300-ki5srmdg37qc6cl521dlqcmt4gbjufn5.apps.googleusercontent.com"
  tries = 3
  status = 400
  while status != 200 && tries > 0
    begin
      resp = make_iap_request url: url, client_id: client_id
      status = resp.status
    ensure
      tries -= 1
      sleep 5
    end
  end
  resp.body
end

describe "Google Cloud IAP Sample" do
  it "makes an IAP request" do
    expect {
      fetch_iap_jwt
    }.to output(/X-Goog-Iap-Jwt-Assertion:/).to_stdout
  end

  it "verifies an IAP JWT" do
    # test with audience
    expect {
      verify_iap_jwt iap_jwt: fetch_iap_jwt,
        project_number: "1031437410300",
        project_id: "cloud-iap-for-testing"
    }.to output(/\/projects\/1031437410300\/apps\/cloud-iap-for-testing/).to_stdout
  end

  it "verifies an IAP JWT without an audience" do
    # test without audience
    expect {
      verify_iap_jwt iap_jwt: fetch_iap_jwt
    }.to output(/Audience not verified/).to_stdout
  end
end
