require_relative "../data_model.rb"
require "rspec"
require "google/cloud/firestore"

describe "Google Cloud Firestore API samples - Data Model" do

  before do
    @firestore_project = ENV["GOOGLE_CLOUD_PROJECT"]
    @firestore = Google::Cloud::Firestore.new
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

  example "document_ref" do
    document_ref project_id: @firestore_project
  end

  example "collection_ref" do
    collection_ref project_id: @firestore_project
  end

  example "document_path_ref" do
    document_path_ref project_id: @firestore_project
  end

  example "subcollection_ref" do
    subcollection_ref project_id: @firestore_project
  end
end
