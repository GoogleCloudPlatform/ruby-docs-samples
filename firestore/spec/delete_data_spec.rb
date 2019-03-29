require_relative "helpers.rb"
require_relative "../delete_data.rb"
require_relative "../get_data.rb"
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

describe "Google Cloud Firestore API samples - Delete Data" do
  before do
    @firestore_project = ENV["FIRESTORE_PROJECT_ID"]
    retrieve_create_examples project_id: @firestore_project
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

  example "delete_doc" do
    output = capture do
      delete_doc project_id: @firestore_project
    end
    expect(output).to include "Deleted the DC document in the cities collection."
  end

  example "delete_field" do
    output = capture do
      delete_field project_id: @firestore_project
    end
    expect(output).to include "Deleted the capital field from the BJ document in the cities collection."
  end

  example "delete_collection" do
    output = capture do
      delete_collection project_id: @firestore_project
    end
    expect(output).to include "Deleting document SF"
    expect(output).to include "Deleting document LA"
    expect(output).to include "Deleting document TOK"
    expect(output).to include "Deleting document BJ"
    expect(output).to include "Finished deleting all documents from the collection."
  end
end
