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

require_relative "../set_endpoint"

describe "Set Endpoint" do
	before do
		@service_address = "eu-vision.googleapis.com"
		@image_path = "gs://cloud-samples-data/vision/text/screen.jpg"
	end
  example "detect text from image file in Google Cloud Storage" do
    expect {
      set_endpoint service_address: @service_address, image_path: @image_path
    }.to output(
      /System/
    ).to_stdout
  end
end
