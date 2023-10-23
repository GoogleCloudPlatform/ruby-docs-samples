# Copyright 2019 Google LLC.
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

require "spec_helper"
require "capybara/cuprite"

# use the cuprite (qmake) driver for the test
Capybara.current_driver = :cuprite
Capybara.server = :webrick

RSpec.configure do |config|
  config.after :suite do
    if E2E.url? and ENV["E2E_URL"].nil?
     E2E.cleanup
    end
  end
end

class E2E
  @@sample_dir = ""

  class << self
    attr_accessor :sample_dir

    def url?
      not @url.nil?
    end

    def url
      deploy
      @url
    end

    def deploy
      if url? || @url = ENV["E2E_URL"]
      	return
      end

      build_id = ENV["BUILD_ID"] || "test"

      version = "#{@sample_dir}-#{build_id}"

      # read in our credentials file
      project_id = ENV["GOOGLE_CLOUD_PROJECT"];

      # deploy this sample to gcloud
      # try 3 times in case of intermittent deploy error
      for attempt in 0..3
        exec "gcloud app deploy --version=#{version} -q --no-promote"
        break if $?.to_i == 0
      end

      # if status is not 0, we tried 3 times and failed
      if $?.to_i != 0
        puts "Failed to deploy to gcloud"
        return $?.to_i
      end

      # sleeping 1 to ensure URL is callable
      sleep 1

      # run the specs for the step, but use the remote URL
      @url = "https://#{version}-dot-#{project_id}.appspot.com"

      # return 0, no errors
      return 0
    end

    def cleanup()
      # determine build number
      version = @url.match(/https:\/\/(.+)-dot-(.+)\.appspot\.com/)
      unless version
        puts "you must pass a build ID or define ENV[\"BUILD_ID\"]"
        return 1
      end

      # run gcloud command
      exec "gcloud app versions delete #{version[1]} -q"

      # return the result of the gcloud delete command
      if $?.to_i != 0
        puts "Failed to delete e2e version"
        return $?.to_i
      end

      # return 0, no errors
      return 0
    end

    def exec(cmd)
      puts "> #{cmd}"
      puts `#{cmd}`
    end
  end
end
