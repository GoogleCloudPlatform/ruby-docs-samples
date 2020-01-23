def list_alert_policies project_id:
  # [START monitoring_alert_list_policies]
  # project_id  = "Your Google Cloud project ID"

  require "google/cloud/monitoring"
  require "google/cloud/monitoring/v3/alert_policy_service_client"

  client = Google::Cloud::Monitoring::AlertPolicy.new
  project_name = Google::Cloud::Monitoring::V3::AlertPolicyServiceClient.project_path project_id
  policies = client.list_alert_policies project_name
  policies.each do |policy|
    puts policy.display_name
  end
  # [END monitoring_alert_list_policies]
end

# Enable or disable alert policies in a project.
# @param project_id [String]
# @param enable [Boolean] Enable or disable the policies
# @param filter [String] Optional.
#   Only enable/disable alert policies that match this filter.
#   https://cloud.google.com/monitoring/api/v3/sorting-and-filtering
#
def enable_alert_policies project_id:, enable:, filter: nil
  # [START monitoring_alert_enable_policies]
  # project_id  = "Your Google Cloud project ID"
  # enable  = "Enable or disable the policies"
  # filter  = "Only enable/disable alert policies that match filter."

  require "google/cloud/monitoring"
  require "google/cloud/monitoring/v3/alert_policy_service_client"

  client = Google::Cloud::Monitoring::AlertPolicy.new
  project_name = Google::Cloud::Monitoring::V3::AlertPolicyServiceClient.project_path project_id
  policies = client.list_alert_policies project_name, filter: filter

  policies.each do |policy|
    if policy.enabled.value == enable
      puts "Policy #{policy.display_name} is already #{policy.enabled.value ? 'enabled' : 'disabled'}"
    else
      policy.enabled.value = enable
      update_mask = Google::Protobuf::FieldMask.new paths: ["enabled"]
      client.update_alert_policy policy, update_mask: update_mask
      puts "#{enable ? 'Enabled' : 'Disabled'} #{policy.display_name}"
    end
  end
  # [END monitoring_alert_enable_policies]
end

# rubocop:disable Layout/AlignHash,Layout/IndentFirstHashElement
def create_policy project_id:
  # [START monitoring_alert_create_policy]
  # project_id  = "Your Google Cloud project ID"

  require "google/cloud/monitoring"
  require "google/cloud/monitoring/v3/alert_policy_service_client"
  require "securerandom"

  policy_data = {
    "displayName": "ruby-samples-#{SecureRandom.hex 4}",
    "combiner": "OR",
    "conditions": [
      {
        "conditionThreshold": {
          "filter": "metric.label.state=\"blocked\" AND metric.type=\"agent.googleapis.com/processes/count_by_state\"  AND resource.type=\"gce_instance\"",
          "comparison": "COMPARISON_GT",
          "thresholdValue": 100,
          "duration": { "seconds": 900 },
            "trigger": {
            "percent": 0
          },
          "aggregations": [{
            "alignmentPeriod": { "seconds": 60 },
            "perSeriesAligner": "ALIGN_MEAN",
            "crossSeriesReducer": "REDUCE_MEAN",
            "groupByFields": [
              "project",
              "resource.label.instance_id",
              "resource.label.zone"
            ]
          }]
        },
        "displayName": "ruby-samples-#{SecureRandom.hex 4}"
      }
    ],
    "enabled": { value: false }
  }.to_json

  project_name = \
    Google::Cloud::Monitoring::V3::AlertPolicyServiceClient.project_path(
      project_id
    )

  client = Google::Cloud::Monitoring::AlertPolicy.new
  policy = Google::Monitoring::V3::AlertPolicy.decode_json policy_data
  policy = client.create_alert_policy project_name, policy

  puts "Policy #{policy.display_name} created."
  # [END monitoring_alert_create_policy]

  policy
end
# rubocop:enable Layout/AlignHash,Layout/IndentFirstHashElement

def list_notification_channels project_id:
  # [START monitoring_alert_list_channels]
  # project_id  = "Your Google Cloud project ID"
  require "google/cloud/monitoring"
  require "google/cloud/monitoring/v3/notification_channel_service_client"

  client = Google::Cloud::Monitoring::NotificationChannel.new
  project_name = Google::Cloud::Monitoring::V3::NotificationChannelServiceClient.project_path project_id
  channels = client.list_notification_channels project_name
  channels.each do |channel|
    puts channel.name
  end
  # [END monitoring_alert_list_channels]
end

def replace_notification_channels project_id:, alert_policy_id:, channel_ids: []
  # [START monitoring_alert_replace_channels]
  # project_id  = "Your Google Cloud project ID"
  # alert_policy_id = "Alter policy id"
  # channel_ids = "List of channel ids"

  require "google/cloud/monitoring"
  require "google/cloud/monitoring/v3/alert_policy_service_client"
  require "google/cloud/monitoring/v3/notification_channel_service_client"

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
  updated_policy = alert_client.update_alert_policy policy, update_mask: update_mask
  puts "Updated #{updated_policy.name}"
  # [END monitoring_alert_replace_channels]
end

# rubocop:disable Layout/AlignHash,Layout/IndentFirstHashElement
def create_channel project_id:
  # [START monitoring_alert_create_policy]
  # project_id  = "Your Google Cloud project ID"

  require "google/cloud/monitoring"
  require "google/cloud/monitoring/v3/notification_channel_service_client"
  require "securerandom"

  channel_data = {
    "type": "email",
    "displayName": "Email joe",
    "description": "test_notification_channel.json",
    "labels": {
        "email_address": "joe@example.com"
    },
    "userLabels": {
        "office": "california_westcoast_usa",
        "division": "fulfillment",
        "role": "operations",
        "level": "5"
    },
    "enabled": { "value": true }
  }.to_json

  project_name = \
    Google::Cloud::Monitoring::V3::NotificationChannelServiceClient.project_path(
      project_id
    )

  client = Google::Cloud::Monitoring::NotificationChannel.new
  channel = Google::Monitoring::V3::NotificationChannel.decode_json channel_data
  channel = client.create_notification_channel project_name, channel

  puts "Notification channel #{channel.display_name} created."
  # [END monitoring_alert_create_policy]

  channel
end
# rubocop:enable Layout/AlignHash,Layout/IndentFirstHashElement

def update_channel project_id:, channel_id:
  # [START monitoring_alert_update_channel]
  # project_id  = "Your Google Cloud project ID"
  # channel_id  = "Notification channel ID"

  require "google/cloud/monitoring"
  require "google/cloud/monitoring/v3/notification_channel_service_client"

  client = Google::Cloud::Monitoring::NotificationChannel.new
  channel_name = Google::Cloud::Monitoring::V3::NotificationChannelServiceClient.notification_channel_path(
    project_id, channel_id
  )
  channel = client.get_notification_channel channel_name

  if channel
    channel.display_name = "ruby-samples-#{SecureRandom.hex 4}"
    update_mask = Google::Protobuf::FieldMask.new paths: ["display_name"]
    channel = client.update_notification_channel channel, update_mask: update_mask
    puts "Channel #{channel_id} updated."
  else
    puts "Channel #{channel_id} not found."
  end

  # [END monitoring_alert_update_channel]
end

def backup project_id:
  # [START monitoring_alert_backup_policies]
  # project_id  = "Your Google Cloud project ID"

  require "json"
  require "google/cloud/monitoring"
  require "google/cloud/monitoring/v3/alert_policy_service_client"

  alert_client = Google::Cloud::Monitoring::AlertPolicy.new
  channel_client = Google::Cloud::Monitoring::NotificationChannel.new
  project_name = Google::Cloud::Monitoring::V3::AlertPolicyServiceClient.project_path project_id

  policies = alert_client.list_alert_policies(project_name).map(&:to_json)
  channels = channel_client.list_notification_channels(project_name).map(&:to_json)
  record = { project_id: project_id, policies: policies, channels: channels }

  File.write "backup.json", JSON.pretty_generate(record)
  puts "Backed up alert policies and notification channels to 'backup.json'."
  # [END monitoring_alert_backup_policies]
end

def restore project_id:
  # [START monitoring_alert_restore_policies]
  # project_id  = "Your Google Cloud project ID"

  require "json"
  require "google/cloud/monitoring"
  require "google/cloud/monitoring/v3/alert_policy_service_client"
  require "google/cloud/monitoring/v3/notification_channel_service_client"

  project_name = Google::Cloud::Monitoring::V3::AlertPolicyServiceClient.project_path project_id

  puts "Loading alert policies and notification channels from backup.json."
  backup_data = JSON.parse File.read("backup.json")

  # Convert json policies data to AlertPolicies.
  policies = backup_data["policies"].map do |policy|
    Google::Monitoring::V3::AlertPolicy.decode_json policy
  end

  # Convert json channel data to NotificationChannels
  channels = backup_data["channels"].map do |channel|
    Google::Monitoring::V3::NotificationChannel.decode_json channel
  end

  # Restore the channels.
  channel_client = Google::Cloud::Monitoring::NotificationChannel.new
  channel_name_map = {}

  channels.each do |channel|
    puts "Updating channel #{channel.display_name}"

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
        puts "The channel was deleted.Create it below."
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
    puts "Updating policy #{policy.display_name}"
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
      rescue StandardError => e
        puts "The policy was deleted. Create it below."
      end
    end

    next if updated

    policy.name = ""
    policy.conditions.each do |condition|
      condition.name = ""
    end

    policy = alert_client.create_alert_policy project_name, policy
    puts "Updated #{policy.name}"
  end
  # [END monitoring_alert_restore_policies]
end

if $PROGRAM_NAME == __FILE__
  case ARGV.shift
  when "create_policy"
    create_policy project_id: ARGV.shift
  when "list_alert_policies"
    list_alert_policies project_id: ARGV.shift
  when "create_channel"
    create_channel project_id: ARGV.shift
  when "update_channel"
    update_channel project_id: ARGV.shift, channel_id: ARGV.shift
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
        create_policy                   <project_id>
        list_alert_policies             <project_id>
        enable_alert_policies           <project_id> <enable> <filter>                # enable value yes / no
        create_channel                  <project_id>
        update_channel                  <project_id> <channel_ids>
        list_notification_channels      <project_id>
        replace_notification_channels   <project_id> <alert_policy_id> <channel_ids>
        backup                          <project_id>
        restore                         <project_id>
    USAGE
  end
end
