# Copyright 2020 Google, Inc
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

require_relative "helper"

require "google/cloud/storage"

require_relative "../detect_web"

describe "Detect Web Entities and Pages" do
  before do
    @storage    = Google::Cloud::Storage.new
    @bucket     = @storage.bucket ENV["GOOGLE_CLOUD_STORAGE_BUCKET"]
  end

  # Returns full path to sample image included in repository for testing
  def image_path filename
    File.expand_path "../resources/#{filename}", __dir__
  end

  it "detect web entities and pages from local image file" do
    assert_output(/http.*otter/) {
      detect_web image_path: image_path("otter_crossing.jpg")
    }
  end

  it "detect web entities and pages from image in Google Cloud Storage" do
    storage_file = @bucket.upload_file image_path("otter_crossing.jpg"),
                                       "otter_crossing.jpg"

    assert_output(/http.*otter/) {
      detect_web_gcs image_path: storage_file.to_gs_url
    }
  end
end
