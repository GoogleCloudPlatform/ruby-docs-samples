# Copyright 2020 Google, LLC.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# [START eventarc_generic_server]
require "sinatra"
require "json"
require "base64"

set :bind, "0.0.0.0"
port = ENV["PORT"] || "8080"
set :port, port
# [END eventarc_generic_server]

# [START eventarc_generic_handler]
post "/" do
  request.body.rewind # in case someone already read it

  puts "Event received!"

  puts "\nHEADERS:"
  headers = request.env.select { |k, _v| k.start_with? "HTTP_" }
                   .collect { |key, val| [key.sub(/^HTTP_/, ""), val] }
                   .collect { |key, val| "#{key}: #{val}" }
                   .sort
  headers.each do |key, value|
    if key != "Authorization"
      puts "#{key}: #{value}<br>"
    end
  end
  headers_json = headers

  puts "\nBODY:"
  body_json = JSON.parse request.body.read
  puts body_json

  result = {
    "headers" => headers_json,
    "body"    => body_json
  }
  result.to_json
end
# [END eventarc_generic_handler]
