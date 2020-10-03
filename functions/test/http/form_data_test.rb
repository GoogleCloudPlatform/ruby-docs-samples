# Copyright 2020 Google LLC
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
require "rack/multipart"

describe "functions_http_form_data" do
  include FunctionsFramework::Testing

  it "handles POST requests" do
    load_temporary "http/form_data/app.rb" do
      file1 = Rack::Multipart::UploadedFile.new io: StringIO.new("I am file1"), filename: "file1.txt"
      file2 = Rack::Multipart::UploadedFile.new io: StringIO.new("I am Groot"), filename: "file2.txt"
      params = { "file1.txt" => file1, "file2.txt" => file2, "foo" => "bar" }
      body = Rack::Multipart.build_multipart params
      content_type = "multipart/form-data; boundary=#{Rack::Multipart::MULTIPART_BOUNDARY}"
      request = make_post_request "http://example.com:8080/", body, ["content-type: #{content_type}"]

      _out, err = capture_subprocess_io do
        call_http "http_form_data", request
      end
      assert_includes err, "Processed file=file1.txt md5=3410581f4b6302949f80af8a1e38d16e"
      assert_includes err, "Processed file=file2.txt md5=bd6c30f97edca9998059354d3329cf38"
    end
  end
end
