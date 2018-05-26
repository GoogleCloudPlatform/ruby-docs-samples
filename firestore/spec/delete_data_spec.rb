require_relative "../delete_data.rb"
require_relative "../get_data.rb"
require "rspec"
require "google/cloud/firestore"

def delete_collection_test collection_name:
  firestore = Google::Cloud::Firestore.new(project_id: ENV["GOOGLE_CLOUD_PROJECT"])
  cities_ref = firestore.col collection_name
  query = cities_ref
  query.get do |document_snapshot|
    document_ref = document_snapshot.ref
    document_ref.delete
  end
end

describe "Google Cloud Firestore API samples - Delete Data" do

  before do
    @firestore_project = ENV["GOOGLE_CLOUD_PROJECT"]
  end

  after do
    delete_collection_test collection_name: "cities"
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

  example "delete_doc" do
    retrieve_create_examples project_id: @firestore_project
    output = capture {
      delete_doc project_id: @firestore_project
    }
    expect(output).to include "Deleted the DC document in the cities collection."
  end

  example "delete_field" do
    retrieve_create_examples project_id: @firestore_project
    output = capture {
      delete_field project_id: @firestore_project
    }
    expect(output).to include "Deleted the capital field from the BJ document in the cities collection."
  end

  example "delete_collection" do
    retrieve_create_examples project_id: @firestore_project
    output = capture {
      delete_collection project_id: @firestore_project
    }
    expect(output).to include "Deleting document SF"
    expect(output).to include "Deleting document LA"
    expect(output).to include "Deleting document TOK"
    expect(output).to include "Deleting document BJ"
    expect(output).to include "Finished deleting all documents from the collection."
  end
end
