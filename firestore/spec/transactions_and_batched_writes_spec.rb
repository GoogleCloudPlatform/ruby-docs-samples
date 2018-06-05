require_relative "../query_data.rb"
require_relative "../transactions_and_batched_writes.rb"
require_relative "helpers.rb"
require "rspec"

describe "Google Cloud Firestore API samples - Transactions and Batched Writes" do

  before do
    @firestore_project = ENV["FIRESTORE_PROJECT_ID"]
  end

  after do
    delete_collection collection_name: "cities"
  end

  # Capture and return STDOUT output by block
  def capture &block
    real_stdout = $stdout
    $stdout = StringIO.new
    block.call
    $stdout.string
  ensure
    $stdout = real_stdout
  end

  example "run_simple_transaction" do
    query_create_examples project_id: @firestore_project
    output = capture {
      run_simple_transaction project_id: @firestore_project
    }
    expect(output).to include "New population is 860001."
    expect(output).to include "Ran a simple transaction to update the population field in the SF document in the cities collection."
  end

  example "return_info_transaction" do
    query_create_examples project_id: @firestore_project
    output = capture {
      return_info_transaction project_id: @firestore_project
    }
    expect(output).to include "Population updated!"
  end

  example "batch_write" do
    query_create_examples project_id: @firestore_project
    output = capture {
      batch_write project_id: @firestore_project
    }
    expect(output).to include "Batch write successfully completed."
  end
end
