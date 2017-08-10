# Copyright 2017, Google, Inc.
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

require "rails_helper"


RSpec.feature "Cat Friends E2E" do
  before :all do
    skip "End-to-end test skipped" unless E2E.run?
    Capybara.run_server = false

    sql_connection_name = ENV["CLOUD_SQL_MYSQL_CONNECTION_NAME"]
    sql_instance_name   = sql_connection_name.split(":").last

    # Apply configuration to app.yaml for tests
    app_yaml_path = File.expand_path "../../../app.yaml", __FILE__
    app_yaml = File.read app_yaml_path

    app_yaml.sub! "[SECRET_KEY]",                    ENV["RAILS_SECRET_KEY_BASE"]
    app_yaml.sub! "[YOUR_INSTANCE_CONNECTION_NAME]", sql_connection_name

    File.write app_yaml_path, app_yaml

    # Apply configuration to database.yml for tests
    database_yml_path  = File.expand_path "../../../config/database.yml", __FILE__
    database_yml = File.read database_yml_path

    database_yml.gsub! "[YOUR_MYSQL_USERNAME]",           ENV["CLOUD_SQL_MYSQL_USERNAME"]
    database_yml.gsub! "[YOUR_MYSQL_PASSWORD]",           ENV["CLOUD_SQL_MYSQL_PASSWORD"]
    database_yml.gsub! "[YOUR_INSTANCE_CONNECTION_NAME]", sql_connection_name

    File.write database_yml_path, database_yml

    puts `gcloud sql databases delete "catfriends_production" --instance=#{sql_instance_name} -q || true`
    puts `gcloud sql databases create "catfriends_production" --instance=#{sql_instance_name} -q`
    @url = E2E.url

    puts `bundle exec rake appengine:exec -- bundle exec rake db:migrate`
  end

  after :all do
    Capybara.run_server = true
  end

  scenario "should display a list of cats" do
    visit @url + new_cat_path
    fill_in "Name", with: "Ms. Paws"
    fill_in "Age", with: 2
    click_button "Create Cat"

    visit @url + root_path
    expect(page).to have_content "Ms. Paws"
  end
end
