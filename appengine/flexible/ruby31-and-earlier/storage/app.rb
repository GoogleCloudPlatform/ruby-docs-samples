# Copyright 2015 Google, Inc
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

# [START gae_flex_storage_app]
require "sinatra"
require "google/cloud/storage"

storage = Google::Cloud::Storage.new
bucket  = storage.bucket ENV["GOOGLE_CLOUD_STORAGE_BUCKET"]

get "/" do
  # Present the user with an upload form
  '
    <form method="POST" action="/upload" enctype="multipart/form-data">
      <input type="file" name="file">
      <input type="submit" value="Upload">
    </form>
  '
end

post "/upload" do
  file_path = params[:file][:tempfile].path
  file_name = params[:file][:filename]

  # Upload file to Google Cloud Storage bucket
  file = bucket.create_file file_path, file_name, acl: "public"

  # The public URL can be used to directly access the uploaded file via HTTP
  file.public_url
end
# [END gae_flex_storage_app]
