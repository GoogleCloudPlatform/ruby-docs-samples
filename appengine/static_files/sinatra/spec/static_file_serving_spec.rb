# Copyright 2016, Google, Inc.
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
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

Capybara.default_driver = :cuprite
Capybara.server = :puma, { Silent: true }

feature "Serving static files" do
  Capybara.app = Sinatra::Application

  scenario "compiling stylesheets" do
    visit "/"

    expect(page).to have_selector "#hide_me", visible: false
  end

  scenario "compiling javascript" do
    visit "/"

    expect(page).not_to have_content "Hello from JavaScript"

    click_button "Test JavaScript"

    expect(page).to have_content "Hello from JavaScript"
  end

  scenario "serving static html" do
    visit "/static_page.html"

    expect(page).to have_content "This is a static file serving example."
  end
end
