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

require_relative "../get_data.rb"
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

describe "Google Cloud Firestore API samples - Get Data" do
  before do
    @firestore_project = ENV["FIRESTORE_TEST_PROJECT"]
    retrieve_create_examples project_id: @firestore_project
  end

  after do
    delete_collection_test collection_name: "cities/SF/neighborhoods", project_id: ENV["FIRESTORE_TEST_PROJECT"]
    delete_collection_test collection_name: "cities", project_id: ENV["FIRESTORE_TEST_PROJECT"]
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

  example "retrieve_create_examples" do
    output = capture do
      retrieve_create_examples project_id: @firestore_project
    end
    expect(output).to include "Added example cities data to the cities collection."
  end

  example "get_document" do
    output = capture do
      get_document project_id: @firestore_project
    end
    expect(output).to include "SF data:"
    expect(output).to include ':name=>"San Francisco"'
    expect(output).to include ':state=>"CA"'
    expect(output).to include ':country=>"USA"'
    expect(output).to include ":capital=>false"
    expect(output).to include ":population=>860000"
  end

  example "get_multiple_docs" do
    output = capture do
      get_multiple_docs project_id: @firestore_project
    end
    expect(output).to include "DC data:"
    expect(output).to include "TOK data:"
    expect(output).to include "BJ data:"
    expect(output).not_to include "SF data:"
    expect(output).not_to include "LA data:"
    expect(output).to include ':name=>"Tokyo"'
    expect(output).to include ":state=>nil"
    expect(output).to include ':country=>"Japan"'
    expect(output).to include ":capital=>true"
    expect(output).to include ":population=>9000000"
  end

  example "get_all_docs" do
    output = capture do
      get_all_docs project_id: @firestore_project
    end
    expect(output).to include "DC data:"
    expect(output).to include "TOK data:"
    expect(output).to include "BJ data:"
    expect(output).to include "SF data:"
    expect(output).to include "LA data:"
    expect(output).to include ':name=>"Los Angeles"'
    expect(output).to include ':state=>"CA"'
    expect(output).to include ':country=>"USA"'
    expect(output).to include ":capital=>false"
    expect(output).to include ":population=>3900000"
  end

  example "add_subcollection" do
    output = capture do
      add_subcollection project_id: @firestore_project
    end
    expect(output).to include "Added document with ID:"
  end

  example "list_subcollections" do
    add_subcollection project_id: @firestore_project
    output = capture do
      list_subcollections project_id: @firestore_project
    end
    expect(output).to include "neighborhoods"
  end
end
