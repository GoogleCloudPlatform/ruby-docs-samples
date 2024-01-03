# Copyright 2015, Google, Inc.
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "json"

class E2E
  class << self

    def run?
      # Only run end-to-end tests when E2E environment variable is set to TRUE
      ENV["E2E"] == "true"
    end

    def check
      if @url.nil?
        test_dir = ENV["TEST_DIR"]

        if test_dir.nil?
          # we are missing arguments to deploy to e2e
          raise "cannot run e2e tests - missing required test_dir"
        end

        if @attempted
          # we've tried to run the tests and failed
          raise "cannot run e2e tests - deployment failed"
        end

        @attempted = true
        build_id = ENV["BUILD_ID"]
        deploy test_dir, build_id
      end
    end

    def deploy test_dir, build_id = nil
      build_id ||= rand 1000..9999

      test_name = versionize test_dir
      version = "#{test_name}-#{build_id}"

      # read in our credentials file
      key_path = File.expand_path ENV["GOOGLE_APPLICATION_CREDENTIALS"], __FILE__
      key_file = File.read key_path
      key_json = JSON.parse key_file

      account_name = key_json["client_email"]
      project_id = ENV["E2E_GOOGLE_CLOUD_PROJECT"]

      # authenticate with gcloud using our credentials file
      exec "gcloud config set project #{project_id}"
      exec "gcloud config set account #{account_name}"

      # deploy this test_dir to gcloud
      # try 3 times in case of intermittent deploy error
      app_yaml_path = File.expand_path "../../#{test_dir}/app.yaml", __FILE__
      (0..3).each do |_attempt|
        exec "gcloud app deploy #{app_yaml_path} --version=#{version} -q --no-promote"
        break if $CHILD_STATUS.to_i.zero?
      end

      # if status is not 0, we tried 3 times and failed
      if $CHILD_STATUS.to_i != 0
        output "Failed to deploy to gcloud"
        return $CHILD_STATUS.to_i
      end

      # sleeping 10 to ensure URL is callable
      sleep 10

      # run the specs for the step, but use the remote URL
      @url = "https://#{version}-dot-#{project_id}.appspot.com"

      # return 0, no errors
      0
    end

    def cleanup test_dir, build_id = nil
      return nil unless ENV["E2E"]
      # determine build number
      build_id ||= ENV["BUILD_ID"]
      if build_id.nil?
        output "you must pass a build ID or define ENV[\"BUILD_ID\"]"
        return 1
      end

      # run gcloud command
      exec "gcloud app versions list --format=\"value(version.id)\" --filter=\"version.id~#{build_id}$\" | xargs -r gcloud app versions delete --quiet"

      # return the result of the gcloud delete command
      if $CHILD_STATUS.to_i != 0
        output "Failed to delete e2e version"
        return $CHILD_STATUS.to_i
      end

      # return 0, no errors
      0
    end

    def versionize name
      version_name = name.tr "^A-Za-z0-9", ""
      name_length  = 7

      random_char = ('a'..'z').to_a.shuffle[0,4].join
      "#{version_name[-name_length, name_length]}#{random_char}" || version_name
    end

    def url
      return unless run?
      check
      @url
    end

    def exec cmd
      output "> #{cmd}"
      output `#{cmd}`
    end

    def output line
      puts line
    end
  end
end
