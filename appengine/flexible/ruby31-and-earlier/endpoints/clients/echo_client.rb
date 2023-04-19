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

# Example of calling a simple Google Cloud Endpoint API.

require "json"
require "optparse"
require "rest-client"

options = {}

optparse = OptionParser.new do |opts|
  opts.on("-h", "--host HOST",
          "Your API host, e.g. https://your-project.appspot.com.") do |host|
    options[:host] = host
  end
  opts.on "-k", "--api_key KEY", "Your API key." do |api_key|
    options[:api_key] = api_key
  end
  opts.on "-m", "--message MESSAGE", "Message to echo." do |message|
    options[:message] = message
  end
end

optparse.parse!

unless options[:host]
  puts optparse
  puts "Missing argument: host"
  exit
end

unless options[:api_key]
  puts optparse
  puts "Missing argument: api_key"
  exit
end

options[:message] = "Hello echo message" unless options[:message]

url = "#{options[:host]}/echo?key=#{options[:api_key]}"
body = { message: options[:message] }.to_json

begin
  response = RestClient.post url, body
  puts response.code
  puts response.body
rescue StandardError => e
  if e.respond_to? :response
    puts e.response.code
    puts e.response.body
  else
    puts e
  end
end
