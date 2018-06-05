require_relative "../quickstart.rb"
require_relative "helpers.rb"
require "rspec"

describe "Google Cloud Firestore API samples - Quickstart" do

  before do
    @firestore_project = ENV["FIRESTORE_PROJECT_ID"]
  end

  after do
    delete_collection collection_name: "users"
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

  example "initialize_firestore_client" do
    output = capture {
      initialize_firestore_client
    }
    expect(output).to include "Created Cloud Firestore client with default project ID."
  end

  example "add_data_1" do
    output = capture {
      add_data_1 project_id: @firestore_project
    }
    expect(output).to include "Added data to the alovelace document in the users collection."
  end

  example "add_data_2" do
    output = capture {
      add_data_2 project_id: @firestore_project
    }
    expect(output).to include "Added data to the aturing document in the users collection."
  end

  example "get_all" do
    add_data_1 project_id: @firestore_project
    add_data_2 project_id: @firestore_project
    output = capture {
      get_all project_id: @firestore_project
    }
    expect(output).to include "alovelace data:"
    expect(output).to include ':first=>"Ada"'
    expect(output).to include ':last=>"Lovelace"'
    expect(output).to include ':born=>1815'
    expect(output).to include "aturing data:"
    expect(output).to include ':first=>"Alan"'
    expect(output).to include ':middle=>"Mathison"'
    expect(output).to include ':last=>"Turing"'
    expect(output).to include ':born=>1912'
  end
end
