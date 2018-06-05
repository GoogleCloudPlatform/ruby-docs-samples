require_relative "../query_data.rb"
require_relative "helpers.rb"
require "rspec"

describe "Google Cloud Firestore API samples - Query Data" do

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

  example "query_create_examples" do
    output = capture {
      query_create_examples project_id: @firestore_project
    }
    expect(output).to include "Added example cities data to the cities collection."
  end

  example "create_query_state" do
    query_create_examples project_id: @firestore_project
    output = capture {
      create_query_state project_id: @firestore_project
    }
    expect(output).to include "Document LA returned by query state=CA."
    expect(output).to include "Document SF returned by query state=CA."
    expect(output).not_to include "Document BJ returned by query state=CA."
    expect(output).not_to include "Document TOK returned by query state=CA."
    expect(output).not_to include "Document DC returned by query state=CA."
  end

  example "create_query_capital" do
    query_create_examples project_id: @firestore_project
    output = capture {
      create_query_capital project_id: @firestore_project
    }
    expect(output).to include "Document BJ returned by query capital=true."
    expect(output).to include "Document TOK returned by query capital=true."
    expect(output).to include "Document DC returned by query capital=true."
    expect(output).not_to include "Document LA returned by query capital=true."
    expect(output).not_to include "Document SF returned by query capital=true."
  end

  example "simple_queries" do
    query_create_examples project_id: @firestore_project
    output = capture {
      simple_queries project_id: @firestore_project
    }
    expect(output).to include "Document LA returned by query state=CA."
    expect(output).to include "Document SF returned by query state=CA."
    expect(output).not_to include "Document BJ returned by query state=CA."
    expect(output).not_to include "Document TOK returned by query state=CA."
    expect(output).not_to include "Document DC returned by query state=CA."
    expect(output).to include "Document LA returned by query population>1000000."
    expect(output).to include "Document TOK returned by query population>1000000."
    expect(output).to include "Document BJ returned by query population>1000000."
    expect(output).not_to include "Document SF returned by query population>1000000."
    expect(output).not_to include "Document DC returned by query population>1000000."
    expect(output).to include "Document SF returned by query name>=San Francisco."
    expect(output).to include "Document TOK returned by query name>=San Francisco."
    expect(output).to include "Document DC returned by query name>=San Francisco."
    expect(output).not_to include "Document BJ returned by query name>=San Francisco."
    expect(output).not_to include "Document LA returned by query name>=San Francisco."
  end

  example "chained_query" do
    query_create_examples project_id: @firestore_project
    output = capture {
      chained_query project_id: @firestore_project
    }
    expect(output).to include "Document SF returned by query state=CA and name=San Francisco."
    expect(output).not_to include "Document LA returned by query state=CA and name=San Francisco."
    expect(output).not_to include "Document DC returned by query state=CA and name=San Francisco."
    expect(output).not_to include "Document TOK returned by query state=CA and name=San Francisco."
    expect(output).not_to include "Document BJ returned by query state=CA and name=San Francisco."
  end

  example "composite_index_chained_query" do
    query_create_examples project_id: @firestore_project
    output = capture {
      composite_index_chained_query project_id: @firestore_project
    }
    expect(output).to include "Document SF returned by query state=CA and population<1000000."
    expect(output).not_to include "Document LA returned by query state=CA and population<1000000."
    expect(output).not_to include "Document DC returned by query state=CA and population<1000000."
    expect(output).not_to include "Document TOK returned by query state=CA and population<1000000."
    expect(output).not_to include "Document BJ returned by query state=CA and population<1000000."
  end

  example "range_query" do
    query_create_examples project_id: @firestore_project
    output = capture {
      range_query project_id: @firestore_project
    }
    expect(output).to include "Document SF returned by query CA<=state<=IN."
    expect(output).to include "Document LA returned by query CA<=state<=IN."
    expect(output).not_to include "Document DC returned by query CA<=state<=IN."
    expect(output).not_to include "Document TOK returned by query CA<=state<=IN."
    expect(output).not_to include "Document BJ returned by query CA<=state<=IN."
  end

  example "invalid_range_query" do
    query_create_examples project_id: @firestore_project
    invalid_range_query project_id: @firestore_project
  end
end
