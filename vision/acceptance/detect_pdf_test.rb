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

require_relative "../detect_pdf"

describe "Detect Document Text from PDF" do
  before do
    @storage    = Google::Cloud::Storage.new
    @bucket     = @storage.bucket ENV["GOOGLE_CLOUD_STORAGE_BUCKET"]
  end

  # Returns full path to sample pdf included in repository for testing
  def document_path filename
    File.expand_path "../resources/#{filename}", __dir__
  end

  it "detect document text from pdf file in Google Cloud Storage" do
    storage_file = @bucket.upload_file document_path("pdf_ocr.pdf"),
                                       "pdf_ocr.pdf"

    assert_output(/A Simple PDF File/) {
      detect_pdf_gcs gcs_source_uri:      storage_file.to_gs_url,
                     gcs_destination_uri: "gs://#{@bucket.name}/prefix_"
    }
  end
end
