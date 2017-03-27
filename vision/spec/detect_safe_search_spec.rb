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
require "google/cloud/storage"

require_relative "../detect_safe_search"

describe "Detect Safe Search Properties" do

  before do
    @storage    = Google::Cloud::Storage.new
    @bucket     = @storage.bucket ENV["GOOGLE_CLOUD_STORAGE_BUCKET"]
    @project_id = ENV["GOOGLE_CLOUD_PROJECT"]
  end

  # Returns full path to sample image included in repository for testing
  def image_path filename
    File.expand_path "../images/#{filename}", __dir__
  end

  example "detect safe search properties from local image file" do
    expect {
      detect_safe_search project_id: @project_id,
                         image_path: image_path("otter_crossing.jpg")
    }.to output(
      /Violence: false/
    ).to_stdout
  end

  example "detect safe search properties from image file in Google Cloud Storage" do
    storage_file = @bucket.upload_file image_path("otter_crossing.jpg"),
                                       "otter_crossing.jpg"

    expect {
      detect_safe_search_gcs project_id: @project_id,
                             image_path: storage_file.to_gs_url
    }.to output(
      /Violence: false/
    ).to_stdout
  end
end
