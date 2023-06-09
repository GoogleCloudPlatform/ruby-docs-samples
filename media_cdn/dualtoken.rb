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
  ##
  # Media CDN uses URL-safe base64 encoding and strips off the padding at the end.
  # Returns a base64-encoded string compatible with Media CDN.
  def base64_encoder value
    encoded_str = Base64.urlsafe_encode64(value).encode("utf-8").delete "="
  end

  ##
  # header names
  # Returns an array that aggregates all header names to be included in the signed token
  def header_names headers
    header_names = []
    headers.each do |header|
      header_names.append header[:name]
    end
    header_names.join ","
  end

  ##
  # header pairs
  # Returns an array that aggregates all header names and values, with each follows name=value format, to be included in the signed token
  def header_pairs headers
    header_pairs = []
    headers.each do |header|
      header_pairs.append "#{header[:name]}=#{header[:value]}"
    end
    header_pairs.join ","
  end

  ##
  # Gets the signed URL suffix string for the Media CDN short token URL requests.
  # One of (`url_prefix`, `full_path`, `path_globs`) must be included in each input.
  # Args:
  #     @param [String] base64_key: a secret key as a base64 encoded string.
  #     @param [Symbol] signature_algorithm: an algorithm as `:SHA1`, `:SHA256`, or `:Ed25519`.
  #     @param [Time object] start_time: the start time as a Time object.
  #     @param [Time object] expiration_time: the expiration time as a Time object. If a value is not specified, the expiration time will be set to 5 mins from now.
  #     @param [String] url_prefix: the URL prefix to sign, including protocol.
  #                     For example: http://example.com/path/ for URLs under /path or http://example.com/path?param=1
  #     @param [String] full_path:  a full path to sign, starting with the first '/'.
  #                     For example: /path/to/content.mp4
  #     @param [String] path_globs: a set of ','- or '!'-delimited path glob strings.
  #                     For example: /tv/*!/film/* to sign paths starting with /tv/ or /film/ in any URL.
  #     @param [String] session_id: a unique identifier for the session
  #     @param [String] data: an arbitrary data payload to include in the token
  #     @param [Array] headers: the header name and value to be included in the signed token should follow name=value format.  May be specified more than once.
  #                     For example: [{'name': 'foo', 'value': 'bar'}, {'name': 'baz', 'value': 'qux'}]
  #     @param [String] ip_ranges: a list of comma-separated IP ranges. Both IPv4 and IPv6 ranges are acceptable.
  #                     For example: '203.0.113.0/24,2001:db8:4a7f:a732/64'
  # Returns:
  #     @return [String] The Signed URL appended with the query parameters based on the specified URL prefix and configuration.
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

    decoded_key = Base64.urlsafe_decode64 base64_key
    algo = signature_algorithm.downcase

    # For most fields, the value we put in the token and the value we must sign
    # are the same.  The FullPath and Headers use a different string for the
    # value to be signed compared to the token.  To illustrate this difference,
    # we'll keep the token and the value to be signed separate.

    tokens = []
    to_sign = []

    # check for `full_path` or `path_globs` or `url_prefix`
    if !full_path.nil?
      tokens.append "FullPath"
      to_sign.append "FullPath=#{full_path}"
    elsif !path_globs.nil?
      path_globs = path_globs.strip
      field = "PathGlobs=#{path_globs}"
      tokens.append field
      to_sign.append field
    elsif !url_prefix.nil?
      encoded_url_prefix = base64_encoder(url_prefix).encode("utf-8")
      field = "URLPrefix=#{encoded_url_prefix}"
      tokens.append field
      to_sign.append field
    else
      raise ArgumentError, "User input missing: one of `url_prefix`, `full_path`, or `path_globs` must be specified."
    end

    # check & parse optional params
    # start_time
    unless start_time.nil?
      field = "Starts=#{start_time.utc.to_i}"
      tokens.append field
      to_sign.append field
    end

    # expiration_time
    expiration_time ||= Time.now.utc + 300
    field = "Expires=#{expiration_time.to_i}"
    tokens.append field
    to_sign.append field

    # session_id
    unless session_id.nil?
      field = "SessionID=#{session_id}"
      tokens.append field
      to_sign.append field
    end

    # data
    unless data.nil?
      field = "Data=#{data}"
      tokens.append field
      to_sign.append field
    end

    # headers
    unless headers.nil?
      tokens.append "Headers=#{header_names headers}"
      to_sign.append "Headers=#{header_pairs headers}"
    end

    # ip-range
    unless ip_ranges.nil?
      encoded_ip_ranges = base64_encoder(ip_ranges.encode("ascii"))
      field = "IPRanges=#{encoded_ip_ranges}"
      tokens.append field
      to_sign.append field
    end

    # generating token
    to_sign_bytes = to_sign.join "~".encode "utf-8"

    # Ed25519
    case algo
    when :ed25519
      digest = Ed25519::SigningKey.new(decoded_key).sign(to_sign_bytes)
      signature = base64_encoder digest
      tokens.append "Signature=#{signature}"
    # SHA256
    when :sha256
      digest = OpenSSL::HMAC.hexdigest "SHA256", decoded_key, to_sign_bytes
      signature = digest.encode "utf-8"
      tokens.append "hmac=#{signature}"
    # SHA1
    when :sha1
      digest = OpenSSL::HMAC.hexdigest "SHA1", decoded_key, to_sign_bytes
      signature = digest.encode "utf-8"
      tokens.append "hmac=#{signature}"
    else
      raise ArgumentError, "Input missing error: `signature_algorithm` can only be one of `:sha1`, `:sha256`, or `:ed25519`."
    end
    tokens.join "~"
  end
end
# [END mediacdn_dualtoken_sign_token]
