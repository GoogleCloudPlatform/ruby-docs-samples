# Copyright 2016 Google Inc. All Rights Reserved.
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

# Google Cloud Endpoints sample application.
#
# Demonstrates how to create a simple echo API as well as how to deal with
# various authentication methods.

require "base64"
require "json"
require "sinatra"
require "rack/cors"

before do
  content_type :json
end

use Rack::Cors do
  allow do
    origins "*"
    resource "/auth/info/firebase",
             headers: :any,
             methods: [:get, :post, :options]
  end
end

# Simple echo service.
post "/echo" do
  message = JSON.parse(request.body.read)["message"]

  { message: message }.to_json
end

# Retrieves the authenication information from Google Cloud Endpoints.
def auth_info
  encoded_info = request.env["HTTP_X_ENDPOINT_API_USERINFO"]

  if encoded_info
    info_json = Base64.decode64 encoded_info
    user_info = JSON.parse info_json
  else
    user_info = { id: "anonymous" }
  end

  user_info.to_json
end

# Auth info with Google signed JWT.
get "/auth/info/googlejwt" do
  auth_info
end

# Auth info with Google ID token.
get "/auth/info/googleidtoken" do
  auth_info
end

# Auth info with Firebase Auth.
get "/auth/info/firebase" do
  auth_info
end

options "/auth/info/firebase" do
  200
end

# Auth info with Auth0.
get "/auth/info/auth0" do
  auth_info
end

# Handle exceptions by returning swagger-compliant json.
error do
  status 500
  { error: 500, message: env["sinatra.error"].message }.to_json
end
