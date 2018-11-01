require "json"
require "google/cloud/monitoring"
require "google/cloud/monitoring/v3/alert_policy_service_client"
require "google/cloud/monitoring/v3/notification_channel_service_client"

def list_alert_policies project_id:
  # [START monitoring_alert_list_policies]
  client = Google::Cloud::Monitoring::AlertPolicy.new
  project_name = Google::Cloud::Monitoring::V3::AlertPolicyServiceClient.project_path project_id
  policies = client.list_alert_policies project_name
  policies.each do |policy|
    p policy
  end
  # [END monitoring_alert_list_policies]
end

# Enable or disable alert policies in a project.
# @param project_id [String]
# @param enable [Boolean]
# @param filter [String] Optional.
#   Only enable/disable alert policies that match this filter.
#   https://cloud.google.com/monitoring/api/v3/sorting-and-filtering
#
def enable_alert_policies project_id:, enable:, filter: nil
  # [START monitoring_alert_enable_policies]
  client = Google::Cloud::Monitoring::AlertPolicy.new
  project_name = Google::Cloud::Monitoring::V3::AlertPolicyServiceClient.project_path project_id
  policies = client.list_alert_policies project_name, filter: filter

  policies.each do |policy|
    if policy.enabled.value == enable
      p "Policy #{policy.name} is already #{policy.enabled.value ? "enabled" : "disabled"}"
    else
      policy.enabled.value = enable
      update_mask = Google::Protobuf::FieldMask.new paths: ["enabled"]
      # client.update_alert_policy policy, update_mask
      p "#{enable ? "Enabled" : "Disabled"} #{policy.name}"
    end
  end
  # [END monitoring_alert_enable_policies]
end

def list_notification_channels project_id:
  # [START monitoring_alert_list_channels]
  client = Google::Cloud::Monitoring::NotificationChannel.new
  project_name = Google::Cloud::Monitoring::V3::NotificationChannelServiceClient.project_path project_id
  channels = client.list_notification_channels project_name
  channels.each do |channel|
    p channel
  end
  # [END monitoring_alert_list_channels]
end

def replace_notification_channels project_id:, alert_policy_id:, channel_ids: []
  # [START monitoring_alert_replace_channels]
  alert_client = Google::Cloud::Monitoring::AlertPolicy.new
  channel_client = Google::Cloud::Monitoring::NotificationChannel.new
  project_name = Google::Cloud::Monitoring::V3::AlertPolicyServiceClient.project_path project_id

  policy = Google::Monitoring::V3::AlertPolicy.new(
    name: Google::Cloud::Monitoring::V3::AlertPolicyServiceClient.alert_policy_path(project_id, alert_policy_id)
  )

  channel_ids.each do |channel_id|
    policy.notification_channels <<
      Google::Cloud::Monitoring::V3::NotificationChannelServiceClient.notification_channel_path(
        project_id,
        channel_id
      )
  end

  update_mask = Google::Protobuf::FieldMask.new paths: ["notification_channels"]
  updated_policy = alert_client.update_alert_policy policy, update_mask
  p "Updated #{updated_policy.name}"
  # [END monitoring_alert_replace_channels]
end

def backup project_id:
  # [START monitoring_alert_backup_policies]
  alert_client = Google::Cloud::Monitoring::AlertPolicy.new
  channel_client = Google::Cloud::Monitoring::NotificationChannel.new
  project_name = Google::Cloud::Monitoring::V3::AlertPolicyServiceClient.project_path project_id

  policies = alert_client.list_alert_policies(project_name).map(&:to_h)
  channels = channel_client.list_notification_channels(project_name).map(&:to_h)
  record = {
    project_id: project_id,
    policies: policies,
    channels: channels
  }

  File.write("backup.json", JSON.pretty_generate(record))
  puts "Backed up alert policies and notification channels to 'backup.json'."
  # [END monitoring_alert_backup_policies]
end

def restore project_id:
  # [START monitoring_alert_restore_policies]
  # [START monitoring_alert_create_policy]
  # [START monitoring_alert_create_channel]
  # [START monitoring_alert_update_channel]
  project_name = Google::Cloud::Monitoring::V3::AlertPolicyServiceClient.project_path project_id

  p "Loading alert policies and notification channels from backup.json."
  backup_data = JSON.parse(File.read("backup.json"))

  # Convert json policies data to AlertPolicies.
  policies = backup_data["policies"].map do |policy|
    Google::Monitoring::V3::AlertPolicy.new policy
  end

  # Convert json channel data to NotificationChannels
  channels = backup_data["channels"].map do |channel|
    Google::Monitoring::V3::NotificationChannel.new channel
  end

  # Restore the channels.
  channel_client = Google::Cloud::Monitoring::NotificationChannel.new
  channel_name_map = {}

  channels.each do |channel|
    p "Updating channel #{channel.display_name}"

    # This field is immutable and it is illegal to specify a
    # non-default value (UNVERIFIED or VERIFIED) in the
    # Create() or Update() operations.
    channel.verification_status =
      Google::Monitoring::V3::NotificationChannel::VerificationStatus::VERIFICATION_STATUS_UNSPECIFIED

    updated = false

    if project_id == backup_data["project_id"]
      begin
        channel_client.update_notification_channel channel
        updated = true
      rescue e
        p "The channel was deleted.Create it below."
      end
    end

    next if updated

    old_name = channel.name
    channel.name = ""
    new_channel = channel_client.create_notification_channel project_name, channel
    channel_name_map[old_name] = new_channel.name
  end

  alert_client = Google::Cloud::Monitoring::AlertPolicy.new

  policies.each do |policy|
    p "Updating policy #{policy.display_name}"
    policy.creation_record = nil
    policy.mutation_record = nil

    policy.notification_channels.each do |channel|
      if channel_name_map[channel.name]
        policy.notification_channels << channel_name_map[channel.name]
      end
    end

    updated = false

    if project_id == backup_data["project_id"]
      begin
        alert_client.update_alert_policy policy
        updated = true
      rescue e
        p "The policy was deleted.  Create it below."
      end
    end

    next if updated

    policy.name = ""
    policy.conditions.each do |condition|
      condition.name = ""
    end

    policy = alert_client.create_alert_policy project_name, policy
    p "Updated #{policy.name}"
  end
  # [END monitoring_alert_restore_policies]
  # [END monitoring_alert_create_policy]
  # [END monitoring_alert_create_channel]
  # [END monitoring_alert_update_channel]
end

if $PROGRAM_NAME == __FILE__
  case ARGV.shift
  when "list_alert_policies"
    list_alert_policies project_id: ARGV.shift
  when "list_notification_channels"
    list_notification_channels project_id: ARGV.shift
  when "enable_alert_policies"
    enable_alert_policies project_id: ARGV.shift, enable: (ARGV.shift == "yes"), filter: ARGV.shift
  when "replace_notification_channels"
    replace_notification_channels project_id: ARGV.shift, alert_policy_id: ARGV.shift, channel_ids: ARGV.shift.to_s.split(",")
  when "backup"
    backup project_id: ARGV.shift
  when "restore"
    restore project_id: ARGV.shift
  else
    puts <<~USAGE
      Usage: bundle exec ruby alerts.rb [command] [arguments]

      Commands:
        list_alert_policies             <project_id>
        list_notification_channels      <project_id>
        enable_alert_policies           <project_id> <enable> <filter>                # enable value yes / no
        replace_notification_channels   <project_id> <alert_policy_id> <channel_ids>
        backup                          <project_id>
        restore                         <project_id>
    USAGE
  end
end
