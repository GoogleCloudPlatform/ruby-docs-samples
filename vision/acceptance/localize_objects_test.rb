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

require "minitest/autorun"
require "google/cloud/storage"

require_relative "../localize_objects"

describe "Localize Objects" do
  before do
    @storage    = Google::Cloud::Storage.new
    @bucket     = @storage.bucket ENV["GOOGLE_CLOUD_STORAGE_BUCKET"]
  end

  # Returns full path to sample image included in repository for testing
  def image_path filename
    File.expand_path "../resources/#{filename}", __dir__
  end

  it "localize objects from local image file" do
    assert_output(/Dog/) {
      localize_objects image_path: image_path("puppies.jpg")
    }
  end

  it "localize objects from image file in Google Cloud Storage" do
    storage_file = @bucket.upload_file image_path("puppies.jpg"),
                                       "puppies.jpg"

    assert_output(/Dog/) {
      localize_objects_gs image_path: storage_file.to_gs_url
    }
  end
end
