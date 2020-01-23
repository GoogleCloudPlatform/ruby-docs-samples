# Copyright 2020 Google, Inc
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

require "json"
require "securerandom"
require "google/cloud/monitoring"
require "google/cloud/monitoring/v3/alert_policy_service_client"
require "google/cloud/monitoring/v3/notification_channel_service_client"
require "rspec"
require_relative "../alerts"

describe "Google Cloud Monitoring Alert API samples" do
  before do
    skip "GOOGLE_CLOUD_PROJECT not defined" unless ENV["GOOGLE_CLOUD_PROJECT"]

    @project_id  = ENV["GOOGLE_CLOUD_PROJECT"]
    @project_path = \
      Google::Cloud::Monitoring::V3::AlertPolicyServiceClient.project_path(
        @project_id
      )

    @policy_client = Google::Cloud::Monitoring::AlertPolicy.new
    # Create alert policy
    @policy = create_policy project_id: @project_id

    @notification_client = Google::Cloud::Monitoring::NotificationChannel.new
    # Create a notification channel.
    @notification_channel = create_channel project_id: @project_id
  end

  after do
    @policy_client&.delete_alert_policy @policy.name
    @notification_client&.delete_notification_channel @notification_channel.name
    File.delete "backup.json" if File.exists? "backup.json"
  end

  # Capture and return STDOUT output by block
  def capture
    real_stdout = $stdout
    $stdout = StringIO.new
    yield
    $stdout.string
  ensure
    $stdout = real_stdout
  end

  example "list alert policies" do
    output = capture do
      list_alert_policies project_id: @project_id
    end

    expect(output).to include @policy.display_name
  end

  example "create alert policy" do
    output = capture do
      create_policy project_id: @project_id
    end

    expect(output).to include "Policy ruby-samples"
  end

  example "enable alert policies" do
    output = capture do
      enable_alert_policies project_id: @project_id, enable: true
    end

    expect(output).to include "Enabled #{@policy.display_name}"

    output = capture do
      enable_alert_policies project_id: @project_id, enable: true
    end

    expect(output).to include "Policy #{@policy.display_name} is already enabled"

    output = capture do
      enable_alert_policies project_id: @project_id, enable: false
    end

    expect(output).to include "Disabled #{@policy.display_name}"
  end

  example "create channel" do
    output = capture do
      create_channel project_id: @project_id
    end

    expect(output).to include "Notification channel Email joe created"
  end

  example "update channel" do
    channel_id = @notification_channel.name.split("/").last
    output = capture do
      update_channel project_id: @project_id, channel_id: channel_id
    end

    expect(output).to include "Channel #{channel_id} updated"
  end

  example "list notification channels" do
    output = capture do
      list_notification_channels project_id: @project_id
    end

    expect(output).to include @notification_channel.name
  end

  example "backup" do
    output = capture do
      backup project_id: @project_id
    end

    expect(output).to include "Backed up alert policies and notification channels to 'backup.json'"
  end

  example "restore" do
    backup project_id: @project_id

    output = capture do
      restore project_id: @project_id
    end

    expect(output).to include "Updating channel #{@notification_channel.display_name}"
    expect(output).to include "Updating policy #{@policy.display_name}"
  end
end
