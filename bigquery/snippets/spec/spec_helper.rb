# Copyright 2018 Google, LLC
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

require "rspec"
require "google/cloud/bigquery"

RSpec.configure do |config|
  config.before :all do
    @bigquery = Google::Cloud::Bigquery.new
    @temp_datasets = []
  end

  config.after :each do
    @temp_datasets.each do |dataset|
      dataset.delete force: true
    end
  end

  def create_temp_dataset
    dataset = @bigquery.create_dataset "test_dataset_#{Time.now.to_i}"
    @temp_datasets << dataset
    dataset
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
end
