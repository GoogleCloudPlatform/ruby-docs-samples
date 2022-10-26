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

require "helper"
require "openssl"

describe "functions_slack" do
  include FunctionsFramework::Testing

  let(:kg_api_key) { "12345" }
  let(:signing_secret) { "67890" }
  let(:kg_search) { KGSearch.new kg_api_key: kg_api_key, signing_secret: signing_secret }
  let(:timestamp) { "2020-01-01" }
  let(:body) { "text=Ruby" }
  let(:url) { "http://example.com:8080" }
  let :signature do
    digest = OpenSSL::Digest.new "SHA256"
    hex_hash = OpenSSL::HMAC.hexdigest digest, signing_secret, "v0:#{timestamp}:#{body}"
    "v0=#{hex_hash}"
  end
  let(:headers) { ["X-Slack-Request-Timestamp: #{timestamp}", "X-Slack-Signature: #{signature}"] }
  let(:wrong_headers) { ["X-Slack-Request-Timestamp: #{timestamp}", "X-Slack-Signature: #{signature}x"] }
  let(:request) { make_post_request url, body, headers }
  let(:invalid_request) { make_post_request url, body, wrong_headers }
  let(:query) { "Ruby" }
  let :kg_response do
    OpenStruct.new item_list_element: [ # rubocop:disable Style/OpenStructUse
      {
        "result" => {
          "name"                => query,
          "description"         => "Programming language",
          "image"               => {
            "contentUrl" => "https://example.com/ruby-image.png"
          },
          "detailedDescription" => {
            "articleBody" => "Ruby is the most awesome progrmaming language.",
            "url"         => "https://www.ruby-lang.org/en/"
          }
        }
      }
    ]
  end
  let(:empty_kg_response) { OpenStruct.new item_list_element: [] } # rubocop:disable Style/OpenStructUse
  let :slack_response do
    {
      "response_type" => "in_channel",
      "text"          => "Query: #{query}",
      "attachments"   => [
        {
          "title"      => "Ruby: Programming language",
          "title_link" => "https://www.ruby-lang.org/en/",
          "text"       => "Ruby is the most awesome progrmaming language.",
          "image_url"  => "https://example.com/ruby-image.png"
        }
      ]
    }
  end
  let :empty_slack_response do
    {
      "response_type" => "in_channel",
      "text"          => "Query: #{query}",
      "attachments"   => [{ "text" => "No results match your query." }]
    }
  end

  it "returns an error on a GET request" do
    load_temporary "slack/app.rb" do
      request = make_get_request url
      response = call_http "kg_search", request
      assert_equal 405, response.status
      assert_equal "Only POST requests are accepted.", response.body.join
    end
  end

  it "returns an error on an invalid signature" do
    load_temporary "slack/app.rb" do
      ENV["SLACK_SECRET"] = signing_secret
      request = make_post_request url, body, wrong_headers
      response = call_http "kg_search", request
      assert_equal 401, response.status
      assert_equal "Signature validation failed.", response.body.join
    end
  end

  it "returns a response" do
    load_temporary "slack/app.rb" do
      ENV["SLACK_SECRET"] = signing_secret

      globals = run_startup_tasks "kg_search"
      mock_client = ::Minitest::Mock.new
      mock_client.expect :search_entities, kg_response, [], query: query, limit: 1
      globals[:kg_search].client = mock_client

      request = make_post_request url, body, headers
      response = call_http "kg_search", request
      mock_client.verify

      assert_equal 200, response.status
      assert_equal ::JSON.dump(slack_response), response.body.join
    end
  end

  describe "KGSearch" do
    it "validates a signature" do
      load_temporary "slack/app.rb" do
        assert kg_search.signature_valid? request
      end
    end

    it "detects an invalid signature" do
      load_temporary "slack/app.rb" do
        refute kg_search.signature_valid? invalid_request
      end
    end

    it "formats a slack message with no results in the response" do
      load_temporary "slack/app.rb" do
        assert_equal empty_slack_response, kg_search.format_slack_message(query, empty_kg_response)
      end
    end

    it "formats a slack message with a full response" do
      load_temporary "slack/app.rb" do
        assert_equal slack_response, kg_search.format_slack_message(query, kg_response)
      end
    end
  end
end
