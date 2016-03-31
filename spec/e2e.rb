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

require 'json'

class E2E
  class << self
    def check()
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
        self.deploy(test_dir, build_id)
      end
    end

    def deploy(test_dir, build_id = nil)
      build_id ||= rand(1000..9999)

      test_name = self.versionize(test_dir)
      version = "#{test_name}-#{build_id}"

      # read in our credentials file
      key_path = File.expand_path("../../client_secrets.json", __FILE__)
      key_file = File.read(key_path)
      key_json = JSON.parse(key_file)

      account_name = key_json['client_email'];
      project_id = key_json['project_id'] || ENV["GOOGLE_PROJECT_ID"];

      # authenticate with gcloud using our credentials file
      self.exec "gcloud config set project #{project_id}"
      self.exec "gcloud config set account #{account_name}"

      # deploy this test_dir to gcloud
      # try 3 times in case of intermittent deploy error
      app_yaml_path = File.expand_path("../../#{test_dir}/app.yaml", __FILE__)
      for attempt in 0..3
        self.exec "gcloud preview app deploy #{app_yaml_path} --version=#{version} -q --no-promote"
        break if $?.to_i == 0
      end

      # if status is not 0, we tried 3 times and failed
      if $?.to_i != 0
        self.output "Failed to deploy to gcloud"
        return $?.to_i
      end

      # sleeping 1 to ensure URL is callable
      sleep 1

      # run the specs for the step, but use the remote URL
      @url = "https://#{version}-dot-#{project_id}.appspot.com"

      # return 0, no errors
      return 0
    end

    def cleanup(test_dir, build_id = nil)
      # determine build number
      build_id ||= ENV['BUILD_ID']
      if build_id.nil?
        self.output "you must pass a build ID or define ENV[\"BUILD_ID\"]"
        return 1
      end

      # run gcloud command
      test_name = self.versionize(test_dir)
      self.exec "gcloud preview app modules delete default --version=#{test_name}-#{build_id} -q"

      # return the result of the gcloud delete command
      if $?.to_i != 0
        self.output "Failed to delete e2e version"
        return $?.to_i
      end

      # return 0, no errors
      return 0
    end

    def versionize(name)
      return name.tr('^A-Za-z0-9', '-')
    end

    def url
      self.check()
      @url
    end

    def exec(cmd)
      self.output "> #{cmd}"
      self.output `#{cmd}`
    end

    def output(line)
      puts line
    end
  end
end
