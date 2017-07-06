# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= "test"
require File.expand_path "../../config/environment", __FILE__
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
require "spec_helper"
require "rspec/rails"
require "capybara/rspec"
require File.expand_path "../../../../spec/e2e", __FILE__

# Apply configuration to database.yml for tests
File.open File.expand_path("../../config/database.yml", __FILE__) do |file|
  configuration = file.read
  configuration.sub! "[YOUR_MYSQL_USERNAME]",           ENV["CLOUD_SQL_MYSQL_USERNAME"]
  configuration.sub! "[YOUR_MYSQL_PASSWORD]",           ENV["CLOUD_SQL_MYSQL_PASSWORD"]
  configuration.sub! "[YOUR_INSTANCE_CONNECTION_NAME]", ENV["CLOUD_SQL_MYSQL_CONNECTION_NAME"]

  file.write configuration
end



# Checks for pending migration and applies them before tests are run.
ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
end
