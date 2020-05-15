require_relative "../quickstart.rb"
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

describe "Google Cloud Firestore API samples - Quickstart" do
  before do
    @firestore_project = ENV["FIRESTORE_PROJECT_ID"]
  end

  after do
    delete_collection_test collection_name: "users", project_id: ENV["FIRESTORE_PROJECT_ID"]
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

  example "initialize_firestore_client" do
    output = capture do
      initialize_firestore_client project_id: @firestore_project
    end
    expect(output).to include "Created Cloud Firestore client with given project ID."
  end

  example "add_data_1" do
    output = capture do
      add_data_1 project_id: @firestore_project
    end
    expect(output).to include "Added data to the alovelace document in the users collection."
  end

  example "add_data_2" do
    output = capture do
      add_data_2 project_id: @firestore_project
    end
    expect(output).to include "Added data to the aturing document in the users collection."
  end

  example "get_all" do
    add_data_1 project_id: @firestore_project
    add_data_2 project_id: @firestore_project
    output = capture do
      get_all project_id: @firestore_project
    end
    expect(output).to include "alovelace data:"
    expect(output).to include ':first=>"Ada"'
    expect(output).to include ':last=>"Lovelace"'
    expect(output).to include ":born=>1815"
    expect(output).to include "aturing data:"
    expect(output).to include ':first=>"Alan"'
    expect(output).to include ':middle=>"Mathison"'
    expect(output).to include ':last=>"Turing"'
    expect(output).to include ":born=>1912"
  end
end
