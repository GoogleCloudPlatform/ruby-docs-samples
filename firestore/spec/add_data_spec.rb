require_relative "../add_data.rb"
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

describe "Google Cloud Firestore API samples - Add Data" do
  before do
    @firestore_project = ENV["FIRESTORE_PROJECT_ID"]
  end

  after do
    delete_collection_test collection_name: "cities", project_id: ENV["FIRESTORE_PROJECT_ID"]
    delete_collection_test collection_name: "data", project_id: ENV["FIRESTORE_PROJECT_ID"]
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

  example "set_document" do
    output = capture do
      set_document project_id: @firestore_project
    end
    expect(output).to include "Set data for the LA document in the cities collection."
  end

  example "update_create_if_missing" do
    output = capture do
      update_create_if_missing project_id: @firestore_project
    end
    expect(output).to include "Merged data into the LA document in the cities collection."
  end

  example "set_document_data_types" do
    output = capture do
      set_document_data_types project_id: @firestore_project
    end
    expect(output).to include "Set multiple data-type data for the one document in the data collection."
  end

  example "set_requires_id" do
    output = capture do
      set_requires_id project_id: @firestore_project
    end
    expect(output).to include "Added document with ID: new-city-id."
  end

  example "add_doc_data_with_auto_id" do
    output = capture do
      add_doc_data_with_auto_id project_id: @firestore_project
    end
    expect(output).to include "Added document with ID:"
  end

  example "add_doc_data_after_auto_id" do
    output = capture do
      add_doc_data_after_auto_id project_id: @firestore_project
    end
    expect(output).to include "Added document with ID:"
    expect(output).to include "Added data to the"
    expect(output).to include "document in the cities collection."
  end

  example "update_doc" do
    output = capture do
      update_doc project_id: @firestore_project
    end
    expect(output).to include "Updated the capital field of the DC document in the cities collection."
  end

  example "update_nested_fields" do
    output = capture do
      update_nested_fields project_id: @firestore_project
    end
    expect(output).to include "Updated the age and favorite color fields of the frank document in the users collection."
  end

  example "update_server_timestamp" do
    output = capture do
      set_requires_id project_id: @firestore_project
      update_server_timestamp project_id: @firestore_project
    end
    expect(output).to include "Updated the timestamp field of the new-city-id document in the cities collection."
  end
end
