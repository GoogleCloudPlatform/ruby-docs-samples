require File.expand_path "../test/test_helper.rb", __dir__

include Rack::Test::Methods # rubocop:disable Style/MixinUsage

def app
  Sinatra::Application
end

def firestore
  firestore = Google::Cloud::Firestore.new
end

def col
  col = firestore.col "sessions"
end

def docs
  docs = col.list_documents
end

def delete_all_sessions
  docs.each do |doc|
    firestore.batch do |b|
      b.delete doc.document_path
    end
  end
end

describe "app" do
  before do
    delete_all_sessions
  end

  after do
    delete_all_sessions
  end

  it "should display the number of views" do
    get "/"
    assert_match(/\d+ views for /, last_response.body)
  end

  it "should increment the number of views on successive views" do
    get "/"
    view_count = last_response.body.match(/(\d+)\s/)[1].to_i
    get "/"
    updated_view_count = last_response.body.match(/(\d+)\s/)[1].to_i
    assert_equal view_count + 1, updated_view_count
  end

  it "should not change the greeting on successive views" do
    get "/"
    greeting = last_response.body.match(/(\d|\s|\w)*(".*")/)[2]
    get "/"
    updated_greeting = last_response.body.match(/(\d|\s|\w)*(".*")/)[2]
    assert_equal greeting, updated_greeting
  end

  it "should store the data in firestore" do
    3.times do
      get "/"
      view_count = last_response.body.match(/(\d+)\s/)[1].to_i
      greeting = last_response.body.match(/(\d|\s|\w)*"(.*)"/)[2]
      doc = col.doc(docs.first.document_id).get
      assert_equal doc.fields[:greeting], greeting
      assert_equal doc.fields[:views], view_count
    end
  end
end
