require_relative "../get_data.rb"
require_relative "helpers.rb"
require "rspec"

describe "Google Cloud Firestore API samples - Get Data" do

  before do
    @firestore_project = ENV["FIRESTORE_PROJECT_ID"]
    retrieve_create_examples project_id: @firestore_project
    sleep(1)
  end

  after do
    delete_collection_test collection_name: "cities/SF/neighborhoods", project_id: ENV["FIRESTORE_PROJECT_ID"]
    delete_collection_test collection_name: "cities", project_id: ENV["FIRESTORE_PROJECT_ID"]
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

  example "retrieve_create_examples" do
    output = capture {
      retrieve_create_examples project_id: @firestore_project
    }
    expect(output).to include "Added example cities data to the cities collection."
  end

  example "get_document" do
    output = capture {
      get_document project_id: @firestore_project
    }
    expect(output).to include "SF data:"
    expect(output).to include ':name=>"San Francisco"'
    expect(output).to include ':state=>"CA"'
    expect(output).to include ':country=>"USA"'
    expect(output).to include ':capital=>false'
    expect(output).to include ':population=>860000'
  end

  example "get_multiple_docs" do
    output = capture {
      get_multiple_docs project_id: @firestore_project
    }
    expect(output).to include "DC data:"
    expect(output).to include "TOK data:"
    expect(output).to include "BJ data:"
    expect(output).not_to include "SF data:"
    expect(output).not_to include "LA data:"
    expect(output).to include ':name=>"Tokyo"'
    expect(output).to include ':state=>nil'
    expect(output).to include ':country=>"Japan"'
    expect(output).to include ':capital=>true'
    expect(output).to include ':population=>9000000'
  end

  example "get_all_docs" do
    output = capture {
      get_all_docs project_id: @firestore_project
    }
    expect(output).to include "DC data:"
    expect(output).to include "TOK data:"
    expect(output).to include "BJ data:"
    expect(output).to include "SF data:"
    expect(output).to include "LA data:"
    expect(output).to include ':name=>"Los Angeles"'
    expect(output).to include ':state=>"CA"'
    expect(output).to include ':country=>"USA"'
    expect(output).to include ':capital=>false'
    expect(output).to include ':population=>3900000'
  end

  example "add_subcollection" do
    output = capture {
      add_subcollection project_id: @firestore_project
    }
    expect(output).to include "Added document with ID:"
  end

  example "list_subcollections" do
    add_subcollection project_id: @firestore_project
    output = capture {
      list_subcollections project_id: @firestore_project
    }
    expect(output).to include "neighborhoods"
  end
end
