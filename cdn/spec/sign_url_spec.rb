# Copyright 2018 Google, Inc
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

require_relative "../sign_url"
require "rspec"

describe "Google Cloud CDN signed url" do
  it "Signs a test URL" do
    example_signed_url = "Signed URL: http://cloud.google.com/?Expires=1518135720&KeyName=my-key&Signature=wiaxR2ySCzFNFZbswBhkTKr6Cdw=\n"
    example_url        = "http://cloud.google.com/"
    example_expiration = "1518135720"
    example_key_file   = File.expand_path "resources/key.txt", __dir__
    example_key_name   = "my-key"

    expect {
      signed_url url:        example_url,
                 key_name:   example_key_name,
                 key_file:   example_key_file,
                 expiration: example_expiration
    }.to output(
      example_signed_url
    ).to_stdout
  end
end
