require "google/cloud/security_center"

def create_notification_config org_id:, config_id:, pubsub_topic:
  # [START scc_create_notification_config]
  require "google/cloud/security_center"

  # org_id:       Your organization id. e.g. for organizations/123, this would
  #               be 123.
  # config_id:    Your notification config id. e.g. for config id
  #               "organizations/123/notificationConfigs/my-config",
  #               this would be "my-config".
  # pubsub_topic: Pubsub topic that Notifications will be published to.
  securitycenter = Google::Cloud::SecurityCenter.new

  formatted_parent = securitycenter.organization_path org_id

  notification_config = {
    description:      "Sample config for Ruby",
    pubsub_topic:     pubsub_topic,
    streaming_config: { filter: 'state = "ACTIVE"' }
  }

  response = securitycenter.create_notification_config formatted_parent, config_id, notification_config
  puts "Created notification config #{config_id}: #{response}. "
  # [END scc_create_notification_config]
end

def update_notification_config org_id:, config_id:, description: nil, pubsub_topic: nil
  # [START scc_update_notification_config]
  require "google/cloud/security_center"

  # org_id:       Your organization id. e.g. for organizations/123, this would
  #               be 123.
  # config_id:    Your notification config id. e.g. for config id
  #               "organizations/123/notificationConfigs/my-config",
  #               this would be "my-config".
  # description:  Updated description of the Notification config.
  # pubsub_topic: Updated pubsub topic for the Notification config.
  securitycenter = Google::Cloud::SecurityCenter.new

  formatted_config_id = securitycenter.notification_config_path org_id, config_id

  notification_config = {
    name: formatted_config_id
  }
  unless description.nil?
    notification_config[:description] = description
  end
  unless pubsub_topic.nil?
    notification_config[:pubsub_topic] = pubsub_topic
  end

  update_mask = {
    paths: []
  }
  unless description.nil?
    update_mask[:paths].push "description"
  end
  unless pubsub_topic.nil?
    update_mask[:paths].push "pubsub_topic"
  end

  response = securitycenter.update_notification_config notification_config, update_mask: update_mask
  puts response
  # [END scc_update_notification_config]
end

def delete_notification_config org_id:, config_id:
  # [START scc_delete_notification_config]
  require "google/cloud/security_center"

  # org_id:       Your organization id. e.g. for organizations/123, this would
  #               be 123.
  # config_id:    Your notification config id. e.g. for config id
  #               "organizations/123/notificationConfigs/my-config",
  #               this would be "my-config".
  securitycenter = Google::Cloud::SecurityCenter.new

  formatted_config_id = securitycenter.notification_config_path org_id, config_id

  response = securitycenter.delete_notification_config formatted_config_id
  puts "Deleted notification config: #{config_id}"
  # [END scc_delete_notification_config]
end

def get_notification_config org_id:, config_id:
  # [START scc_get_notification_config]
  require "google/cloud/security_center"

  # org_id:       Your organization id. e.g. for organizations/123, this would
  #               be 123.
  # config_id:    Your notification config id. e.g. for config id
  #               "organizations/123/notificationConfigs/my-config",
  #               this would be "my-config".
  securitycenter = Google::Cloud::SecurityCenter.new

  formatted_config_id = securitycenter.notification_config_path org_id, config_id

  response = securitycenter.get_notification_config formatted_config_id
  puts "Notification config fetched: #{response}"
  # [END scc_get_notification_config]
end

def list_notification_configs org_id:
  # [START scc_list_notification_configs]
  require "google/cloud/security_center"

  # org_id: Your organization id. e.g. for organizations/123, this would
  #         be 123.
  securitycenter = Google::Cloud::SecurityCenter.new

  formatted_parent = securitycenter.organization_path org_id

  securitycenter.list_notification_configs(formatted_parent).each_page do |page|
    page.each do |element|
      puts element
    end
  end
  # [END scc_list_notification_configs]
end

if $PROGRAM_NAME == __FILE__
  case ARGV.shift
  when "create_notification_config"
    create_notification_config org_id:       ARGV.shift,
                               config_id:    ARGV.shift,
                               pubsub_topic: ARGV.shift
  when "delete_notification_config"
    delete_notification_config org_id:    ARGV.shift,
                               config_id: ARGV.shift
  when "update_notification_config"
    update_notification_config org_id:       ARGV.shift,
                               config_id:    ARGV.shift,
                               description:  ARGV.shift,
                               pubsub_topic: ARGV.shift
  when "get_notification_config"
    get_notification_config org_id:    ARGV.shift,
                            config_id: ARGV.shift

  when "list_notification_configs"
    list_notification_configs org_id: ARGV.shift
  else
    puts <<~USAGE
      Usage: bundle exec ruby notification.rb [command] [arguments]

      Commands:
        create_notification_config  <org_id> <config_id> <pubsub_topic>                Creates a Notification config
        delete_notification_config  <org_id> <config_id>                               Deletes a Notification config
        get_notification_config     <org_id> <config_id>                               Fetches a Notification config
        update_notification_config  <org_id> <config_id> <description> <pubsub_topic>  Updates a Notification config
        list_notification_configs   <org_id>                                           Lists Notification configs in an organization
    USAGE
  end
end
