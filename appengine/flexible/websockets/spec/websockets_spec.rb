# Copyright 2023 Google LLC
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
require "capybara/rspec"
require "capybara/cuprite"

Capybara.javascript_driver = :cuprite

Capybara.app = Sinatra::Application

Capybara.register_server :thin do |app, port, host|
  require "rack/handler/thin"
  Rack::Handler::Thin.run(app, :Port => port, :Host => host)
end

Capybara.server = :thin

describe "Websockets Sample", type: :feature, js: true do

  it "returns HTML" do
    visit "/"

    expect(page).to have_content 'Chat'
  end

  it "responds to chat" do
    visit "/"
    fill_in "chat-text", with: "test chat text"
    click_button "Send"

    expect(page).to have_content "test chat text"
  end
end
