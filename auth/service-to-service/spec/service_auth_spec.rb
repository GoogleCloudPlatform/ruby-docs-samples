# Copyright 2026 Google, Inc
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

require_relative "../service_auth"
require "rspec"
require "googleauth"
require "open3"

describe "Service to service auth sample" do
  before :all do
    @project_id = ENV["GOOGLE_CLOUD_PROJECT"]
    @credentials = ENV["GOOGLE_APPLICATION_CREDENTIALS"]
    @env_vars = @credentials ? { "CLOUDSDK_AUTH_CREDENTIAL_FILE_OVERRIDE" => @credentials } : {}

    @location = ENV["LOCATION_ID"] || "us-central1"
    @entry_point = "make_get_request_cloud"
    @target_name = "#{@entry_point}-echo"
    @runtime_version = "ruby32"

    # Initial Setup. Deploy target function
    deploy_cmd = [
      "gcloud", "functions", "deploy", @target_name,
      "--entry-point=#{@target_name}",
      "--runtime=#{@runtime_version}",
      "--no-allow-unauthenticated",
      "--project=#{@project_id}",
      "--trigger-http",
      "--source=."
    ]
    puts "Running:#{deploy_cmd.join ' '}"
    stdout, stderr, status = Open3.capture3(@env_vars, *deploy_cmd)

    # If the Cloud Functions API is disabled in the CI test project, skip the rest of the group
    unless status.success?
      if stderr.include?("PERMISSION_DENIED") && stderr.include?("Cloud Functions API")
        skip "Cloud Functions API not enabled in this project (#{@project_id}). Skipping tests."
      else
        raise "Setup: Deploy target function failed:\n#{stderr}"
      end
    end

    # Deploy relay function
    @target_url = "https://#{@location}-#{@project_id}.cloudfunctions.net/#{@target_name}"

    deploy_relay_cmd = [
      "gcloud", "functions", "deploy", @entry_point,
      "--entry-point=#{@entry_point}",
      "--runtime=#{@runtime_version}",
      "--no-allow-unauthenticated",
      "--project=#{@project_id}",
      "--trigger-http",
      "--set-env-vars=TARGET_URL=#{@target_url}",
      "--source=."
    ]

    puts "Running: #{deploy_relay_cmd.join ' '}"
    stdout, stderr, status = Open3.capture3(@env_vars, *deploy_relay_cmd)
    raise "Setup: Deploy relay function failed:\n#{stderr}" unless status.success?

    @base_url = "https://#{@location}-#{@project_id}.cloudfunctions.net/"
  end

  after :all do
    next if @base_url.nil? # We skipped setup

    # Teardown the target function
    delete_target_cmd = ["gcloud", "functions", "delete", @target_name, "--project=#{@project_id}", "--quiet"]
    puts "Running: #{delete_target_cmd.join ' '}"
    _, stderr, status = Open3.capture3(@env_vars, *delete_target_cmd)
    puts "Teardown: Delete function #{@target_name} failed: #{stderr}" unless status.success?

    # Teardown the relay function
    delete_relay_cmd = ["gcloud", "functions", "delete", @entry_point, "--project=#{@project_id}", "--quiet"]
    puts "Running: #{delete_relay_cmd.join ' '}"
    _, stderr, status = Open3.capture3(@env_vars, *delete_relay_cmd)
    puts "Teardown: Delete function #{@entry_point} failed: #{stderr}" unless status.success?
  end

  it "makes an authenticated get request to the target url" do
    url = "#{@base_url}#{@entry_point}"

    max_attempts = 5
    attempts = 0
    success = false

    while attempts < max_attempts && !success
      attempts += 1
      buffer = StringIO.new

      begin
        make_get_request buffer, url, url

        expect(buffer.string).to eq("Success!")
        success = true
      rescue StandardError, RSpec::Expectations::ExpectationNotMetError => e
        if attempts >= max_attempts
          raise "Failed after #{max_attempts} attempts. Last error: #{e.message}"
        else
          puts "make_get_request attempt #{attempts} failed: #{e.message}. Retrying in 10s..."
          sleep 10
        end
      end
    end
  end
end
