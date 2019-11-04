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

# Example of calling a Google Cloud Endpoint API with an ID token obtained
# using the Google OAuth2 flow.

require "optparse"
require "rest-client"
require "json"
require "signet/oauth_2/client"
require "openssl"

options = {}

optparse = OptionParser.new do |opts|
  opts.on("-h", "--host HOST",
          "Your API host, e.g. https://your-project.appspot.com.") do |host|
    options[:host] = host
  end
  opts.on "-k", "--api_key KEY", "Your API key." do |api_key|
    options[:api_key] = api_key
  end
  opts.on("-s", "--client_secrets_file FILE",
          "The path to your service account json file.") do |file_path|
    options[:client_secrets_file] = file_path
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

unless options[:client_secrets_file]
  puts optparse
  puts "Missing argument: client_secrets_file"
  exit
end

client_secrets = JSON.parse File.read(options[:client_secrets_file])

oauth = Signet::OAuth2::Client.new(
  issuer:               "jwt-client.endpoints.sample.google.com",
  audience:             "echo.endpoints.sample.google.com",
  scope:                "email",
  authorization_uri:    "https://accounts.google.com/o/oauth2/auth",
  token_credential_uri: "https://www.googleapis.com/oauth2/v4/token",
  client_id:            client_secrets["installed"]["client_id"],
  client_secret:        client_secrets["installed"]["client_secret"],
  redirect_uri:         "urn:ietf:wg:oauth:2.0:oob"
)

puts "Open the following URI in your browser to get the authorization code:"
puts oauth.authorization_uri

print "Enter authorization code: "

oauth.code = gets.chomp

puts oauth.code

oauth.fetch_access_token!

puts oauth.id_token

# Makes a request to the auth info endpoint for Google ID tokens.

url = "#{options[:host]}/auth/info/googleidtoken?key=#{options[:api_key]}"

begin
  response = RestClient.get url, Authorization: "Bearer #{oauth.id_token}"
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
