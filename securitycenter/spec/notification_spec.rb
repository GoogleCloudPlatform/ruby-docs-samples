require "google/gax"
require "rspec/retry"
require_relative "spec_helper"
require_relative "../notification"

RSpec.configure do |config|
  # show retry status in spec process
  config.verbose_retry = true
  # show exception that triggers a retry if verbose_retry is set to true
  config.display_try_failure_messages = true

  # set retry count and retry sleep interval to 5 tries and 5 seconds
  config.default_retry_count = 5
  config.default_sleep_interval = 5
end

describe "Google Cloud Security Center Notifications Sample" do
  before do
    @securitycenter = Google::Cloud::SecurityCenter.new
    @pubsub_topic   = "projects/project-a-id/topics/notifications-sample-topic"
    @config_id      = "config-id"
    @org_id         = "1081635000895"
    @formatted_config_id = @securitycenter.notification_config_path @org_id, @config_id

    cleanup!
  end

  after do
    cleanup!
  end

  def cleanup!
    @securitycenter.delete_notification_config @formatted_config_id
  rescue Google::Gax::NotFoundError
    puts "Config #{@formatted_config_id} already deleted"
  end

  it "creates notification config" do
    expect {
      create_notification_config org_id:       @org_id,
                                 config_id:    @config_id,
                                 pubsub_topic: @pubsub_topic
    }.to output(/Created notification config #{@config_id}/).to_stdout

    config = @securitycenter.get_notification_config @formatted_config_id
    expect(config.name).to eq(@formatted_config_id)
  end

  it "updates notification config" do
    create_notification_config org_id:       @org_id,
                               config_id:    @config_id,
                               pubsub_topic: @pubsub_topic,
                               filter:       @filter
    expect {
      update_notification_config org_id:      @org_id,
                                 config_id:   @config_id,
                                 description: "Updated description",
                                 streaming_config: {filter: @filter}
    }.to output(/Updated description/).to_stdout
  end

  it "deletes notification config" do
    create_notification_config org_id:       @org_id,
                               config_id:    @config_id,
                               pubsub_topic: @pubsub_topic

    expect {
      delete_notification_config org_id:    @org_id,
                                 config_id: @config_id
    }.to output(/Deleted notification config: #{@config_id}/).to_stdout
  end

  it "gets notification config" do
    create_notification_config org_id:       @org_id,
                               config_id:    @config_id,
                               pubsub_topic: @pubsub_topic
    expect {
      get_notification_config  org_id:    @org_id,
                               config_id: @config_id
    }.to output(/#{@formatted_config_id}/).to_stdout
  end

  it "lists notification configs" do
    create_notification_config org_id:       @org_id,
                               config_id:    @config_id,
                               pubsub_topic: @pubsub_topic

    expect {
      list_notification_configs org_id: @org_id
    }.to output(/#{@formatted_config_id}/).to_stdout
  end
end
