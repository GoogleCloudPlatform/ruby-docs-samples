require_relative "../app"

require "rspec"
require "rack/test"

RSpec.describe "Ruby Endpoints Sample" do
  include Rack::Test::Methods

  attr_reader :app

  before :all do
    @app = Sinatra::Application
    @app.set :environment, :production
  end

  it "GET / renders home page" do
    get "/"

    expect(last_response.status).to eq 200
    expect(last_response.content_type).to eq "text/html;charset=utf-8"
    expect(last_response.body).to include "Endpoints Sample"
  end

  it "GET /api-docs renders Swagger specification" do
    get "/api-docs"

    expect(last_response.status).to eq 200
    expect(last_response.content_type).to eq "application/json"
    expect(last_response.body).to include '"title":"Endpoints Example"'
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
end
