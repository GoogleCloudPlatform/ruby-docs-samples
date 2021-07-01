require File.expand_path "test_helper.rb", __dir__

include Rack::Test::Methods # rubocop:disable Style/MixinUsage

def app
  Sinatra::Application
end

class FirestoreSessionMock < Rack::Session::Abstract::Persisted
  def initialize app, options = {}
    super
    @data = {}
  end

  def find_session _req, session_id
    return [generate_sid, {}] if session_id.nil?
    [session_id, @data[session_id]]
  end

  def write_session _req, session_id, new_session, _opts
    @data[session_id] = new_session
    session_id
  end

  def delete_session _req, session_id, _opts
    @data.delete[session_id]
    generate_sid
  end
end

describe "app" do
  before do
    @mock_session = lambda do |app, _options = {}|
      FirestoreSessionMock.new app, {}
    end
  end

  it "should display a greeting" do
    Rack::Session::FirestoreSession.stub :new, @mock_session do
      get "/"
      greetings = /"Hello World"|"Hallo Welt"|"Ciao Mondo"|"Salut le Monde"|"Hola Mundo"/
      assert_match greetings, last_response.body
    end
  end

  it "should display the number of views" do
    Rack::Session::FirestoreSession.stub :new, @mock_session do
      get "/"
      assert_match(/\d+ views for /, last_response.body)
    end
  end

  it "should increment the number of views on successive views" do
    Rack::Session::FirestoreSession.stub :new, @mock_session do
      get "/"
      view_count = last_response.body.match(/(\d+)\s/)[1].to_i
      get "/"
      updated_view_count = last_response.body.match(/(\d+)\s/)[1].to_i
      assert_equal view_count + 1, updated_view_count
    end
  end

  it "should not change the greeting on successive views" do
    Rack::Session::FirestoreSession.stub :new, @mock_session do
      get "/"
      greeting = last_response.body.match(/(\d|\s|\w)*(".*")/)[2]
      4.times do
        get "/"
        updated_greeting = last_response.body.match(/(\d|\s|\w)*(".*")/)[2]
        assert_equal greeting, updated_greeting
      end
    end
  end
end
