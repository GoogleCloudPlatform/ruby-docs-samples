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

ENV["RAILS_ENV"] ||= "test"
ENV["GOOGLE_CLOUD_PROJECT"] = ENV["FIRESTORE_PROJECT_ID"]

require File.expand_path("../../config/environment", __FILE__)

require "capybara/rspec"
require "capybara/rails"
require "book_extensions"

Book.send :extend, BookExtensions

RSpec.configure do |config|
  # Retry setup
  # show retry status in spec process
  config.verbose_retry = true
  # show exception that triggers a retry if verbose_retry is set to true
  config.display_try_failure_messages = true

  # set retry count and retry sleep interval to 10 seconds
  config.default_retry_count = 3
  config.default_sleep_interval = 3

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.before :all do |example|
    Book.delete_all
  end
end
