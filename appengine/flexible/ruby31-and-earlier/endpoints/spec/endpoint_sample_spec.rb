require_relative "../app"

require "rspec"
require "rack/test"

describe "Ruby Endpoints Sample" do
  include Rack::Test::Methods

  attr_reader :app

  before :all do
    @app = Sinatra::Application
    @app.set :environment, :production
  end

  it "POST /echo renders message from request body" do
    post "/echo", '{"message":"hello from test"}'

    expect(last_response.status).to eq 200
    expect(last_response.content_type).to eq "application/json"
    expect(last_response.body).to eq '{"message":"hello from test"}'
  end

  it "GET /auth/info/googlejwt renders user info" do
    get "/auth/info/googlejwt"

    expect(last_response.status).to eq 200
    expect(last_response.content_type).to eq "application/json"
    expect(last_response.body).to eq '{"id":"anonymous"}'

    user_info = Base64.encode64 '{"id":"the user info"}'

    header "X-Endpoint-API-UserInfo", user_info

    get "/auth/info/googlejwt"

    expect(last_response.status).to eq 200
    expect(last_response.content_type).to eq "application/json"
    expect(last_response.body).to eq '{"id":"the user info"}'
  end

  it "GET /auth/info/googleidtoken renders user info" do
    get "/auth/info/googleidtoken"

    expect(last_response.status).to eq 200
    expect(last_response.content_type).to eq "application/json"
    expect(last_response.body).to eq '{"id":"anonymous"}'

    user_info = Base64.encode64 '{"id":"the user info"}'

    header "X-Endpoint-API-UserInfo", user_info

    get "/auth/info/googleidtoken"

    expect(last_response.status).to eq 200
    expect(last_response.content_type).to eq "application/json"
    expect(last_response.body).to eq '{"id":"the user info"}'
  end

  it "handles exceptions by returning Swagger-compliant JSON" do
    post "/echo", '{"...invalid JSON'

    expect(last_response.status).to eq 500
    expect(last_response.content_type).to eq "application/json"

    error = JSON.parse last_response.body

    expect(error["error"]).to eq 500
    expect(error["message"]).to include "unexpected token"
  end

  it "handles Firebase Auth" do
    get "/auth/info/firebase"

    expect(last_response.status).to eq 200
    expect(last_response.content_type).to eq "application/json"
    expect(last_response.body).to eq '{"id":"anonymous"}'

    user_info = Base64.encode64 '{"id":"the user info"}'

    header "X-Endpoint-API-UserInfo", user_info

    get "/auth/info/firebase"

    expect(last_response.status).to eq 200
    expect(last_response.content_type).to eq "application/json"
    expect(last_response.body).to eq '{"id":"the user info"}'


    header "Origin", "example.com"
    options "/auth/info/firebase"
    expect(last_response.status).to eq 200
    expect(last_response.headers["Access-Control-Allow-Origin"]).to eq "*"
    expect(last_response.headers["Access-Control-Allow-Methods"]).to eq "GET, POST, OPTIONS"
  end

  it "GET /auth/info/auth0 renders user info" do
    get "/auth/info/auth0"

    expect(last_response.status).to eq 200
    expect(last_response.content_type).to eq "application/json"
    expect(last_response.body).to eq '{"id":"anonymous"}'

    user_info = Base64.encode64 '{"id":"the user info"}'

    header "X-Endpoint-API-UserInfo", user_info

    get "/auth/info/auth0"

    expect(last_response.status).to eq 200
    expect(last_response.content_type).to eq "application/json"
    expect(last_response.body).to eq '{"id":"the user info"}'
  end
end
