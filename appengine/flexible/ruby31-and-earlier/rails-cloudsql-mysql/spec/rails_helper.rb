# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= "test"
require File.expand_path "../config/environment", __dir__
# Prevent database truncation if the environment is production
abort "The Rails environment is running in production mode!" if Rails.env.production?
require "spec_helper"
require "rspec/rails"
require "capybara/rspec"
require "capybara/cuprite"

require File.expand_path "../../../spec/e2e", __dir__

# Checks for pending migration and applies them before tests are run.
ActiveRecord::Migration.maintain_test_schema!

Capybara.current_driver = :cuprite

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
