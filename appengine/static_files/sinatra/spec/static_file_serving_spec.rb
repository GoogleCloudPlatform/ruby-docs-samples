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

require File.expand_path("../../../../../spec/e2e", __FILE__)
require "rspec"
require "capybara/rspec"
require "capybara/poltergeist"

Capybara.default_driver = :poltergeist

feature "Serving static files" do
  before :all do
    skip "End-to-end tests skipped" unless E2E.run?

    @url = E2E.url
  end

  scenario "compiling stylesheets" do
    visit "#{@url}/"

    expect(page).to have_selector "#hide_me", visible: false
  end

  scenario "compiling javascript" do
    visit "#{@url}/"

    expect(page).not_to have_content "Hello from JavaScript"

    click_button "Test JavaScript"

    expect(page).to have_content "Hello from JavaScript"
  end

  scenario "serving static html" do
    visit "#{@url}/static_page.html"

    expect(page).to have_content "This is a static file serving example."
  end
end
