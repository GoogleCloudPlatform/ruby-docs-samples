require_relative "../distributed_counters.rb"
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

describe "Google Cloud Firestore API samples - Distributed Counter" do
  before do
    @firestore_project = ENV["FIRESTORE_PROJECT_ID"]
    create_counter project_id: @firestore_project, num_shards: 5
  end

  after do
    delete_collection_test collection_name: "shards", project_id: ENV["FIRESTORE_PROJECT_ID"]
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

  example "create_counter" do
    output = capture do
      create_counter project_id: @firestore_project, num_shards: 5
    end
    expect(output).to include "Distributed counter shards collection created."
  end

  example "get_document" do
    output = capture do
      increment_counter project_id: @firestore_project, num_shards: 5
    end
    expect(output).to include "Counter incremented."
  end

  example "get_count" do
    increment_counter project_id: @firestore_project, num_shards: 5
    increment_counter project_id: @firestore_project, num_shards: 5

    output = capture do
      get_count project_id: @firestore_project
    end
    expect(output).to include "Count value is 2."
  end
end
