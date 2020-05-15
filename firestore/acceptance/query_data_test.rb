# Copyright 2020 Google LLC
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

require_relative "../query_data.rb"
require_relative "helpers.rb"
require "rspec"
require "rspec/retry"

RSpec.configure do |config|
  # show retry status in spec process
  config.verbose_retry = true
  # show exception that triggers a retry if verbose_retry is set to true
  config.display_try_failure_messages = true

  # set retry count and retry sleep interval to 5 seconds
  config.default_retry_count = 5
  config.default_sleep_interval = 5
end

describe "Google Cloud Firestore API samples - Query Data" do
  before do
    @firestore_project = ENV["FIRESTORE_PROJECT_ID"]
    query_create_examples project_id: @firestore_project
  end

  after do
    delete_collection_test collection_name: "cities", project_id: ENV["FIRESTORE_PROJECT_ID"]
  end

  # Capture and return STDOUT output by block
  def capture
    real_stdout = $stdout
    $stdout = StringIO.new
    yield
    $stdout.string
  ensure
    $stdout = real_stdout
  end

  example "query_create_examples" do
    output = capture do
      query_create_examples project_id: @firestore_project
    end
    expect(output).to include "Added example cities data to the cities collection."
  end

  example "create_query_state" do
    output = capture do
      create_query_state project_id: @firestore_project
    end
    expect(output).to include "Document LA returned by query state=CA."
    expect(output).to include "Document SF returned by query state=CA."
    expect(output).not_to include "Document BJ returned by query state=CA."
    expect(output).not_to include "Document TOK returned by query state=CA."
    expect(output).not_to include "Document DC returned by query state=CA."
  end

  example "create_query_capital" do
    output = capture do
      create_query_capital project_id: @firestore_project
    end
    expect(output).to include "Document BJ returned by query capital=true."
    expect(output).to include "Document TOK returned by query capital=true."
    expect(output).to include "Document DC returned by query capital=true."
    expect(output).not_to include "Document LA returned by query capital=true."
    expect(output).not_to include "Document SF returned by query capital=true."
  end

  example "simple_queries" do
    output = capture do
      simple_queries project_id: @firestore_project
    end
    expect(output).to include "Document LA returned by query state=CA."
    expect(output).to include "Document SF returned by query state=CA."
    expect(output).not_to include "Document BJ returned by query state=CA."
    expect(output).not_to include "Document TOK returned by query state=CA."
    expect(output).not_to include "Document DC returned by query state=CA."
    expect(output).to include "Document LA returned by query population>1000000."
    expect(output).to include "Document TOK returned by query population>1000000."
    expect(output).to include "Document BJ returned by query population>1000000."
    expect(output).not_to include "Document SF returned by query population>1000000."
    expect(output).not_to include "Document DC returned by query population>1000000."
    expect(output).to include "Document SF returned by query name>=San Francisco."
    expect(output).to include "Document TOK returned by query name>=San Francisco."
    expect(output).to include "Document DC returned by query name>=San Francisco."
    expect(output).not_to include "Document BJ returned by query name>=San Francisco."
    expect(output).not_to include "Document LA returned by query name>=San Francisco."
  end

  example "chained_query" do
    output = capture do
      chained_query project_id: @firestore_project
    end
    expect(output).to include "Document SF returned by query state=CA and name=San Francisco."
    expect(output).not_to include "Document LA returned by query state=CA and name=San Francisco."
    expect(output).not_to include "Document DC returned by query state=CA and name=San Francisco."
    expect(output).not_to include "Document TOK returned by query state=CA and name=San Francisco."
    expect(output).not_to include "Document BJ returned by query state=CA and name=San Francisco."
  end

  example "composite_index_chained_query" do
    output = capture do
      composite_index_chained_query project_id: @firestore_project
    end
    expect(output).to include "Document SF returned by query state=CA and population<1000000."
    expect(output).not_to include "Document LA returned by query state=CA and population<1000000."
    expect(output).not_to include "Document DC returned by query state=CA and population<1000000."
    expect(output).not_to include "Document TOK returned by query state=CA and population<1000000."
    expect(output).not_to include "Document BJ returned by query state=CA and population<1000000."
  end

  example "range_query" do
    output = capture do
      range_query project_id: @firestore_project
    end
    expect(output).to include "Document SF returned by query CA<=state<=IN."
    expect(output).to include "Document LA returned by query CA<=state<=IN."
    expect(output).not_to include "Document DC returned by query CA<=state<=IN."
    expect(output).not_to include "Document TOK returned by query CA<=state<=IN."
    expect(output).not_to include "Document BJ returned by query CA<=state<=IN."
  end

  example "invalid_range_query" do
    invalid_range_query project_id: @firestore_project
  end

  example "in_query_without_array" do
    output = capture do
      in_query_without_array project_id: @firestore_project
    end

    expect(output).to include "Document SF returned by query in ['USA','Japan']."
    expect(output).to include "Document LA returned by query in ['USA','Japan']."
    expect(output).to include "Document DC returned by query in ['USA','Japan']."
    expect(output).to include "Document TOK returned by query in ['USA','Japan']."
    expect(output).not_to include "Document BJ returned by query in ['USA','Japan']."
  end

  example "in_query_with_array" do
    output = capture do
      in_query_with_array project_id: @firestore_project
    end

    expect(output).to include "Document DC returned by query in [['west_coast'], ['east_coast']]."
    expect(output).not_to include "Document SF returned by query in [['west_coast'], ['east_coast']]."
    expect(output).not_to include "Document LA returned by query in [['west_coast'], ['east_coast']]."
    expect(output).not_to include "Document TOK returned by query in [['west_coast'], ['east_coast']]."
    expect(output).not_to include "Document BJ returned by query in [['west_coast'], ['east_coast']]."
  end

  example "array_contains_any_queries" do
    output = capture do
      array_contains_any_queries project_id: @firestore_project
    end
    expect(output).to include "Document SF returned by query array-contains-any ['west_coast', 'east_coast']."
    expect(output).to include "Document LA returned by query array-contains-any ['west_coast', 'east_coast']."
    expect(output).to include "Document DC returned by query array-contains-any ['west_coast', 'east_coast']."
    expect(output).not_to include "Document TOK returned by query array-contains-any ['west_coast', 'east_coast']."
    expect(output).not_to include "Document BJ returned by query array-contains-any ['west_coast', 'east_coast']."
  end

  example "array_contains_filter" do
    output = capture do
      array_contains_filter project_id: @firestore_project
    end
    expect(output).to include "Document SF returned by query array-contains 'west_coast'."
    expect(output).to include "Document LA returned by query array-contains 'west_coast'."
    expect(output).not_to include "Document DC returned by query array-contains 'west_coast'."
    expect(output).not_to include "Document TOK returned by query array-contains 'west_coast'."
    expect(output).not_to include "Document BJ returned by query array-contains 'west_coast'."
  end

  example "collection_group_query" do
    output = capture do
      collection_group_query project_id: @firestore_project
    end
    expect(output).to include "museum name is The Getty."
    expect(output).to include "museum name is Legion of Honor."
    expect(output).to include "museum name is National Museum of Nature and Science."
    expect(output).to include "museum name is National Air and Space Museum."
    expect(output).to include "museum name is Beijing Ancient Observatory."
    expect(output).not_to include "park name is Griffith Park."
    expect(output).not_to include "memorial name is Lincoln Memorial."
    expect(output).not_to include "bridge name is Golden Gate Bridge."
  end
end
