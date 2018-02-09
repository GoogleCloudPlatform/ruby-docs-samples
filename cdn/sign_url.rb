# Copyright 2018 Google, Inc
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

def signed_url url:, key_name:, key_file:, expiration:
  # [START signed_url]
  # url        = "URL to content served by Google Cloud CDN"
  # key_name   = "Signing key name"
  # key_file   = "Signing key file name with a urlsafe base64 encoded key"
  # expiration = "Expiration time for signed URL formatted as a Unix Timestamp"

  require "base64"
  require "cgi"
  require "openssl"
  require "uri"

  # Read in url safe base64 encoded file
  key         = File.binread(key_file).chomp
  decoded_key = Base64.urlsafe_decode64 key

  # Determine which seperator makes sense given a URL
  seperator = "?"
  seperator = "&" if url.include? '?'

  # Concatenate url with expected query parameters Expires and KeyName
  url = "#{url}#{seperator}Expires=#{expiration}&KeyName=#{key_name}"

  # Sign the url using the key and url safe base64 encode the signature
  signature         = OpenSSL::HMAC.digest "SHA1", decoded_key, url
  encoded_signature = Base64.urlsafe_encode64 signature

  puts "Signed URL: #{url}&Signature=#{encoded_signature}"
  # [END signed_url]
end

if __FILE__ == $PROGRAM_NAME
  if ARGV.count == 4
    signed_url url:        ARGV.shift,
               key_name:   ARGV.shift,
               key_file:   ARGV.shift,
               expiration: ARGV.shift
  else
    puts <<-usage
Usage: bundle exec ruby sign_url.rb <url> <key_name> <key_file> <expiration>

Arguments:
  url        - URL to content served by Google Cloud CDN
  key_name   - Signing key name
  key_file   - Signing key file name with a urlsafe base64 encoded key
  expiration - Expiration time for signed URL formatted as a Unix Timestamp
    usage
  end
end
