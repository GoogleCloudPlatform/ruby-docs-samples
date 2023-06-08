# Copyright 2023 Google, Inc.
#
# Licensed under the Apache License, Version 2.0 (the 'License');
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an 'AS IS' BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# [START mediacdn_dualtoken_sign_token]
require "base64"
require "time"
require "openssl"
require "ed25519"

class Dualtoken
  def base64_encoder value
    #
    #   Returns a base64-encoded string compatible with Media CDN.
    #
    #   Media CDN uses URL-safe base64 encoding and strips off the padding at the end.
    #
    encoded_str = Base64.urlsafe_encode64(value).encode("utf-8")
    encoded_str.delete "="
  end

  def sign_token(
    base64_key:,
    signature_algorithm:,
    start_time: nil,
    expiration_time: nil,
    full_path: nil,
    path_globs: nil,
    url_prefix: nil,
    session_id: nil,
    data: nil,
    headers: nil,
    ip_ranges: nil
  )

    # Gets the signed URL suffix string for the Media CDN short token URL requests.
    # One of (`url_prefix`, `full_path`, `path_globs`) must be included in each input.
    # Args:
    #     base64_key: a secret key as a base64 encoded string.
    #     signature_algorithm: an algorithm as `SHA1`, `SHA256`, or `Ed25519`.
    #     start_time: the start time as a UTC datetime object.
    #     expiration_time: the expiration time as a UTC datetime object. If a value is not specified, the expiration time will be set to 5 mins from now.
    #     url_prefix: the URL prefix to sign, including protocol.
    #                 For example: http://example.com/path/ for URLs under /path or http://example.com/path?param=1
    #     full_path:  a full path to sign, starting with the first '/'.
    #                 For example: /path/to/content.mp4
    #     path_globs: a set of ','- or '!'-delimited path glob strings.
    #                 For example: /tv/*!/film/* to sign paths starting with /tv/ or /film/ in any URL.
    #     session_id: a unique identifier for the session
    #     data: an arbitrary data payload to include in the token
    #     headers: the header name and value to be included in the signed token should follow name=value format.  May be specified more than once.
    #                 For example: [{'name': 'foo', 'value': 'bar'}, {'name': 'baz', 'value': 'qux'}]
    #     ip_ranges: a list of comma-separated IP ranges. Both IPv4 and IPv6 ranges are acceptable.
    #                 For example: '203.0.113.0/24,2001:db8:4a7f:a732/64'
    # Returns:
    #     The Signed URL appended with the query parameters based on the
    #     specified URL prefix and configuration.

    decoded_key = Base64.urlsafe_decode64 base64_key
    algo = signature_algorithm.downcase

    # For most fields, the value we put in the token and the value we must sign
    # are the same.  The FullPath and Headers use a different string for the
    # value to be signed compared to the token.  To illustrate this difference,
    # we'll keep the token and the value to be signed separate.
    tokens = []
    to_sign = []

    # check for `full_path` or `path_globs` or `url_prefix`
    if full_path
      tokens.append "FullPath"
      to_sign.append "FullPath=#{full_path}"
    elsif path_globs
      path_globs = path_globs.strip
      field = "PathGlobs=#{path_globs}"
      tokens.append field
      to_sign.append field
    elsif url_prefix
      encoded_url_prefix = base64_encoder(url_prefix).encode("utf-8")
      field = "URLPrefix=#{encoded_url_prefix}"
      tokens.append field
      to_sign.append field
    else
      raise "User input missing: One of `url_prefix`, `full_path`, or `path_globs` must be specified."
    end

    # check & parse optional params
    # start_time
    if start_time
      start_time_utc = start_time.utc.to_i

      field = "Starts=#{start_time_utc}"
      tokens.append field
      to_sign.append field
    end

    # expiration_time
    expiration_utc = if expiration_time
                       expiration_time.utc.to_i
                     else
                       Time.now.to_i + 300
                     end
    field = "Expires=#{expiration_utc}"
    tokens.append field
    to_sign.append field

    # session_id
    if session_id
      field = "SessionID=#{session_id}"
      tokens.append field
      to_sign.append field
    end

    # data
    if data
      field = "Data=#{data}"
      tokens.append field
      to_sign.append field
    end

    # headers
    if headers
      header_names = []
      header_pairs = []
      # for each in headers
      headers.each do |header|
        header_names.append header[:name]
        header_pairs.append "#{header[:name]}=#{header[:value]}"
      end
      header_names = header_names.join ","
      header_pairs = header_pairs.join ","
      tokens.append "Headers=#{header_names}"
      to_sign.append "Headers=#{header_pairs}"
    end

    # ip-range
    if ip_ranges
      encoded_ip_ranges = base64_encoder(ip_ranges.encode("ascii"))
      field = "IPRanges=#{encoded_ip_ranges}"
      tokens.append field
      to_sign.append field
    end

    # generating token
    to_sign = to_sign.join "~"
    to_sign_bytes = to_sign.encode "utf-8"

    # Ed25519
    case algo
    when "ed25519"
      digest = Ed25519::SigningKey.new(decoded_key).sign(to_sign_bytes)
      signature = base64_encoder digest
      tokens.append "Signature=#{signature}"
    # SHA256
    when "sha256"
      digest = OpenSSL::HMAC.hexdigest "SHA256", decoded_key, to_sign_bytes
      signature = digest.encode "utf-8"
      tokens.append "hmac=#{signature}"
    # SHA1
    when "sha1"
      digest = OpenSSL::HMAC.hexdigest "SHA1", decoded_key, to_sign_bytes
      signature = digest.encode "utf-8"
      tokens.append "hmac=#{signature}"
    else
      raise "Input missing error: `signature_algorithm` can only be one of `sha1`, `sha256`, or `ed25519`."
    end
    tokens.join "~"
  end
end
# [END mediacdn_dualtoken_sign_token]
