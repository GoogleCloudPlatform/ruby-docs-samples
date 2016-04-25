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

require File.expand_path("../../../../spec/e2e", __FILE__)
require "rspec"
require "capybara/rspec"
require "capybara/poltergeist"

Capybara.current_driver = :poltergeist

RSpec.describe "Memcached on Google App Engine", type: :feature do
  before :all do
    @url = E2E.url
  end

  it "visits increment counter" do
    visit @url
    expect(page).to have_content "Counter value is"
    initial_value = page.body.match(/Counter value is (\d+)/)[1].to_i

    visit @url
    second_value = page.body.match(/Counter value is (\d+)/)[1].to_i
    expect(second_value).to be > initial_value
  end
end
