require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
# require "action_mailer/railtie"
# require "action_mailbox/engine"
# require "action_text/engine"
require "action_view/railtie"
# require "action_cable/engine"
require "sprockets/railtie"
require "rails/test_unit/railtie"
# require "google/cloud/secret_manager"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

key_file = File.join("config", "master.key")
if File.exist?(key_file)
  ENV["RAILS_MASTER_KEY"] = File.read(key_file)
end

p ENV["RAILS_MASTER_KEY"]
# p Rails.application.credentials.gcp[:db_password]
# else
#   client = Google::Cloud::SecretManager.secret_manager_service

#   master_key = client.secret_version_path(
#     project:        'trambui-test-1',
#     secret:         'rails-master-key',
#     secret_version: 'latest'
#   )
#   version = client.access_secret_version name: master_key
#   payload = version.payload.data
#   ENV["RAILS_MASTER_KEY"] = payload
# end

# to get access to RAILS_MASTER_KEY during apply migrations build step
# if ENV["RAILS_MASTER_KEY_SECRET"].present?
#   require "google/cloud/secret_manager/v1"
#   client = ::Google::Cloud::SecretManager::V1::SecretManagerService::Client.new
#   value = client.access_secret_version(name: ENV["RAILS_MASTER_KEY_SECRET"]).payload.data
#   ENV["RAILS_MASTER_KEY"] ||= value # could also just "=" here
# end

module RailsCatAlbum
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.1

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
