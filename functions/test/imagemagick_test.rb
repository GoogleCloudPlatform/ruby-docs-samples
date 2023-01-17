# Copyright 2021 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "helper"
require "google/cloud/vision/v1"

describe "functions_imagemagick" do
  include FunctionsFramework::Testing

  let(:bucket_name) { "my-bucket" }
  let(:blur_bucket_name) { "blur-bucket" }
  let(:file_name) { "my-image.jpg" }
  let(:gs_url) { "gs://#{bucket_name}/#{file_name}" }
  let(:event_payload) { { "name" => file_name, "bucket" => bucket_name } }
  let(:cloud_event) { make_cloud_event event_payload }
  let(:mock_vision) { Minitest::Mock.new }
  let(:mock_storage) { Minitest::Mock.new }
  let(:vision_client) { FunctionsFramework::Function::LazyGlobal.new(proc { mock_vision }) }
  let(:storage_client) { FunctionsFramework::Function::LazyGlobal.new(proc { mock_storage }) }
  let(:mock_bucket) { Minitest::Mock.new }
  let(:mock_file) { Minitest::Mock.new }
  let(:mock_blur_bucket) { Minitest::Mock.new }

  it "detects already-blurred files" do
    load_temporary "imagemagick/app.rb" do
      payload = { "name" => "blurred-image.jpg", "bucket" => bucket_name }
      event = make_cloud_event payload
      _out, err = capture_subprocess_io do
        call_event "blur_offensive_images", event
      end
      assert_includes err, "The image blurred-image.jpg is already blurred"
    end
  end

  it "detects OK files" do
    load_temporary "imagemagick/app.rb" do
      result = Google::Cloud::Vision::V1::BatchAnnotateImagesResponse.new(
        responses: [
          {
            safe_search_annotation: {
              adult:    :POSSIBLE,
              violence: :UNLIKELY
            }
          }
        ]
      )
      mock_vision.expect :safe_search_detection, result, [], image: gs_url
      _out, err = capture_subprocess_io do
        call_event "blur_offensive_images", cloud_event, globals: { vision_client: vision_client }
      end
      mock_vision.verify
      assert_includes err, "The image #{file_name} was detected as OK"
    end
  end

  it "converts identified files" do
    ENV["BLURRED_BUCKET_NAME"] = blur_bucket_name
    load_temporary "imagemagick/app.rb" do
      result = Google::Cloud::Vision::V1::BatchAnnotateImagesResponse.new(
        responses: [
          {
            safe_search_annotation: {
              adult:    :LIKELY,
              violence: :VERY_LIKELY
            }
          }
        ]
      )
      tempfile_path = nil
      fake_blur_bucket = Object.new
      mock_vision.expect :safe_search_detection, result, [], image: gs_url
      mock_storage.expect :bucket, mock_bucket, [bucket_name]
      mock_bucket.expect :file, mock_file, [file_name]
      mock_file.expect :download, nil do |tempfile|
        image_data = File.read "#{__dir__}/data/face.jpg", mode: "rb"
        tempfile.write image_data
        tempfile_path = tempfile.path
      end
      mock_storage.expect :bucket, mock_blur_bucket, [blur_bucket_name]
      mock_blur_bucket.expect :create_file, nil do |source, name|
        assert_equal tempfile_path, source
        assert_equal file_name, name
        orig_data = File.read "#{__dir__}/data/face.jpg", mode: "rb"
        blur_data = File.read tempfile_path, mode: "rb"
        refute_equal orig_data, blur_data
      end
      _out, err = capture_subprocess_io do
        call_event "blur_offensive_images", cloud_event,
                   globals: { vision_client: vision_client, storage_client: storage_client }
      end
      mock_vision.verify
      mock_storage.verify
      mock_bucket.verify
      mock_file.verify
      mock_blur_bucket.verify
      assert_includes err, "The image #{file_name} was detected as inappropriate"
      assert_includes err, "Blurred image uploaded to gs://#{blur_bucket_name}/#{file_name}"
    end
  end
end
