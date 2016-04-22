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

RSpec.describe "Cloud SQL on Google App Engine", type: :feature do
  before :all do
    app_yaml = File.expand_path("../../app.yaml", __FILE__)

    configuration = File.read(app_yaml)
    configuration.sub! "<your-cloudsql-host>", ENV["MYSQL_HOST"]
    configuration.sub! "<your-cloudsql-user>", ENV["MYSQL_USER"]
    configuration.sub! "<your-cloudsql-password>", ENV["MYSQL_PASSWORD"]
    configuration.sub! "<your-cloudsql-database>", ENV["MYSQL_DATABASE"]

    File.write(app_yaml, configuration)

    @url = E2E.url
  end

  it "displays recent visits" do
    2.times { visit @url }

    expect(page).to have_content "Last 10 visits:"
    expect(page).to have_content "Time:"
    expect(page).to have_content "Addr:"
  end
end
