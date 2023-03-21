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

# [START cloudcdn_sign_url]
def signed_url url:, key_name:, key:, expiration:
  # url        = "URL of the endpoint served by Cloud CDN"
  # key_name   = "Name of the signing key added to the Google Cloud Storage bucket or service"
  # key        = "Signing key as urlsafe base64 encoded string"
  # expiration = Ruby Time object with expiration time

  require "base64"
  require "openssl"
  require "time"

  # Decode the URL safe base64 encode key
  decoded_key = Base64.urlsafe_decode64 key

  # Get UTC time in seconds
  expiration_utc = expiration.utc.to_i

  # Determine which separator makes sense given a URL
  separator = "?"
  separator = "&" if url.include? "?"

  # Concatenate url with expected query parameters Expires and KeyName
  url = "#{url}#{separator}Expires=#{expiration_utc}&KeyName=#{key_name}"

  # Sign the url using the key and url safe base64 encode the signature
  signature         = OpenSSL::HMAC.digest "SHA1", decoded_key, url
  encoded_signature = Base64.urlsafe_encode64 signature

  # Concatenate the URL and encoded signature
  signed_url = "#{url}&Signature=#{encoded_signature}"
end
# [END cloudcdn_sign_url]

if $PROGRAM_NAME == __FILE__
  if ARGV.count == 4
    puts signed_url url:        ARGV.shift,
                    key_name:   ARGV.shift,
                    key:        ARGV.shift,
                    expiration: Time.now + ARGV.shift.to_i
  else
    puts <<~USAGE
      Usage: bundle exec ruby sign_url.rb <url> <key_name> <key> <expires_in>

      Arguments:
        url        - URL of the endpoint served by Cloud CDN
        key_name   - Name of the signing key added to the Google Cloud Storage bucket or service
        key        - Signing key as a urlsafe base64 encoded string
        expires_in - Expire signed URL in number of seconds from current time
    USAGE
  end
end
