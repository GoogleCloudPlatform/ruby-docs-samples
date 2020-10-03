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

# [START functions_slack_setup]
require "functions_framework"
require "slack-ruby-client"
require "google/apis/kgsearch_v1"

# This block is executed during cold start, before the function begins
# handling requests. This is the recommended way to create shared resources
# and objects.
FunctionsFramework.on_startup do
  # Create a global handler object, configured with the environment-provided
  # API key and signing secret.
  kg_search = KGSearch.new kg_api_key:     ENV["KG_API_KEY"],
                           signing_secret: ENV["SLACK_SECRET"]
  set_global :kg_search, kg_search
end

# The KGSearch class implements the logic of validating and responding
# to requests. More methods of this class are shown below.
class KGSearch
  def initialize kg_api_key:, signing_secret:
    # Create the global client for the Knowledge Graph Search Service,
    # configuring it with your API key.
    @client = Google::Apis::KgsearchV1::KgsearchService.new
    @client.key = kg_api_key

    # Save signing secret for use by the signature validation method.
    @signing_secret = signing_secret
  end
  # [END functions_slack_setup]

  # [START functions_verify_webhook]
  # slack-ruby-client expects a Rails-style request object with a "headers"
  # method, but the Functions Framework provides only a Rack request.
  # To avoid bringing in Rails as a dependency, we'll create a simple class
  # that implements the "headers" method and delegates everything else back to
  # the Rack request object.
  require "delegate"
  class RequestWithHeaders < SimpleDelegator
    def headers
      env.each_with_object({}) do |(key, val), result|
        if /^HTTP_(\w+)$/ =~ key
          header = Regexp.last_match(1).split("_").map(&:capitalize).join("-")
          result[header] = val
        end
      end
    end
  end

  # This is a method of the KGSearch class.
  # It determines whether the given request's signature is valid.
  def signature_valid? request
    # Wrap the request with our class that provides the "headers" method.
    request = RequestWithHeaders.new request

    # Validate the request signature.
    slack_request = Slack::Events::Request.new request,
                                               signing_secret: @signing_secret
    slack_request.valid?
  end
  # [END functions_verify_webhook]

  # [START functions_slack_request]
  # This is a method of the KGSearch class.
  # It makes an API call to the Knowledge Graph Search Service, and formats
  # a Slack message as a nested Hash object.
  def make_search_request query
    response = @client.search_entities query: query, limit: 1
    format_slack_message query, response
  end
  # [END functions_slack_request]

  # [START functions_slack_format]
  # This is a method of the KGSearch class.
  # It takes a raw SearchResponse from the Knowledge Graph Search Service,
  # and formats a Slack message.
  def format_slack_message query, response
    result = response.item_list_element&.first&.fetch "result", nil
    attachment =
      if result
        name = result.fetch "name", nil
        description = result.fetch "description", nil
        details = result.fetch "detailedDescription", {}
        { "title"      => name && description ? "#{name}: #{description}" : name,
          "title_link" => details.fetch("url", nil),
          "text"       => details.fetch("articleBody", nil),
          "image_url"  => result.fetch("image", nil)&.fetch("contentUrl", nil) }
      else
        { "text" => "No results match your query." }
      end
    { "response_type" => "in_channel",
      "text"          => "Query: #{query}",
      "attachments"   => [attachment.compact] }
  end
  # [END functions_slack_format]

  attr_accessor :client
end

# [START functions_slack_search]
# Handler for the function endpoint.
FunctionsFramework.http "kg_search" do |request|
  # Return early if the request is not a POST.
  unless request.post?
    return [405, {}, ["Only POST requests are accepted."]]
  end

  # Access the global Knowledge Graph Search client
  kg_search = global :kg_search

  # Verify the request signature and return early if it failed.
  unless kg_search.signature_valid? request
    return [401, {}, ["Signature validation failed."]]
  end

  # Query the Knowledge Graph and format a Slack message with the response.
  # This method returns a nested hash, which the Functions Framework will
  # convert to JSON automatically.
  kg_search.make_search_request request.params["text"]
end
# [END functions_slack_search]
