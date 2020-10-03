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

# [START functions_http_form_data]
require "functions_framework"

FunctionsFramework.http "http_form_data" do |request|
  # The request parameter is a Rack::Request object.
  # See https://www.rubydoc.info/gems/rack/Rack/Request

  # This Rack call parses multipart form data, returning the params as a hash.
  # The returned params hash includes an entry for each field. File uploads
  # are written to Tempfiles and represented by hashes, while plain fields are
  # represented by strings.
  params = request.POST

  begin
    params.each do |name, part|
      if part.is_a? Hash
        # Handle a file upload part by logging the md5 hash.
        md5 = Digest::MD5.hexdigest part[:tempfile].read
        file_name = part[:filename]
        logger.info "Processed file=#{file_name} md5=#{md5}"
      else
        # Handle a non-file part by logging the value.
        logger.info "Processed field=#{name} value=#{part}"
      end
    end
  ensure
    # Ensure that all Tempfile objects are closed and deleted. The Cloud
    # Functions runtime keeps temporary files in an in-memory file system,
    # so to lower memory usage it is good practice to clean up Tempfiles
    # explicitly rather than wait for object finalization.
    params.each_value do |part|
      part[:tempfile].close! if part.is_a? Hash
    end
  end

  # The HTTP response body.
  "OK"
end
# [END functions_http_form_data]
