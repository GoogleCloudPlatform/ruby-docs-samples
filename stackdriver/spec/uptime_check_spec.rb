# Copyright 2018 Google, Inc
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

# bundle exec rspec

require_relative "../uptime_check"
require "google/cloud/monitoring/v3"
require "rspec"

describe "Stackdriver uptime check" do
  before :all do
    @project_id = ENV["GOOGLE_CLOUD_PROJECT"]
    raise "Set the environment variable GOOGLE_CLOUD_PROJECT." if @project_id.nil?
    # Stackdriver projects are not 1-1 with Google cloud projects.  All the
    # ruby test Google cloud projects use the same Stackdriver project.
    @project_id = "cloud-samples-ruby-test-1" if /cloud-samples-ruby-test-\d/.match(@project_id)

    # Delete all uptime checks before running tests.
    client = Google::Cloud::Monitoring::V3::UptimeCheck.new
    project_name = Google::Cloud::Monitoring::V3::UptimeCheckServiceClient.project_path @project_id
    configs = client.list_uptime_check_configs project_name
    configs.each { |config| delete_uptime_check_config config.name }

    @configs = [create_uptime_check_config(project_id: @project_id),
                create_uptime_check_config(project_id: @project_id)]
  end

  after :all do
    @configs.each { |config| delete_uptime_check_config config.name }
  end

  it "list_ips" do
    expect { list_ips }.to output(/Singapore/).to_stdout
  end

  it "list_uptime_checks" do
    expect { list_uptime_check_configs @project_id }.to output(Regexp.new(@configs[0].name)).to_stdout
  end

  it "update_uptime_checks" do
    update_uptime_check_config config_name: @configs[0].name, new_display_name: "Chicago"
    expect { get_uptime_check_config @configs[0].name }.to output(/Chicago/).to_stdout
    update_uptime_check_config config_name: @configs[1].name, new_http_check_path: "https://example.appspot.com/"
    expect { get_uptime_check_config @configs[1].name }.to output(/example.appspot.com/).to_stdout
  end
end
