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

describe "Google Cloud IAP Sample" do
  it "fetches an ID token" do
    expect {
      fetch_id_token url: "https://print-iap-jwt-assertion-dot-cloud-iap-for-testing.uc.r.appspot.com",
              client_id: "1031437410300-ki5srmdg37qc6cl521dlqcmt4gbjufn5.apps.googleusercontent.com"
    }.to output(/x-goog-authenticated-user-jwt:/).to_stdout
  end
end
