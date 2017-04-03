# Copyright 2016 Google, Inc
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require_relative "../app.rb"
require "rspec"
require "rack/test"

describe "Cloud SQL sample", type: :feature do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  before do
    @database = Sequel.sqlite database: ":memory:"

    expect(Sequel).to receive(:postgres).and_return @database
  end

  it "can create database schema by running create_tables.rb" do
    expect(@database.tables).not_to include :visits

    load File.expand_path("../create_tables.rb", __dir__)

    expect(@database.tables).to include :visits
  end

  it "displays hashes of the IP addresses of the top 10 most recent visits" do
    load File.expand_path("../create_tables.rb", __dir__)
    expect(@database[:visits].count).to eq 0

    localhost_user_ip = Digest::SHA256.hexdigest "127.0.0.1"

    15.times { get "/" }

    expect(@database[:visits].count).to eq 15
    expect(@database[:visits].first[:user_ip]).to eq localhost_user_ip
    expect(last_response.body).to include "Last 10 visits"
    expect(last_response.body).to include "Addr: #{localhost_user_ip}"
    expect(last_response.body.scan("Addr:").count).to eq 10
  end
end
