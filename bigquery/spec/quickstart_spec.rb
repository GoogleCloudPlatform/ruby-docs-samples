# Copyright 2016 Google, Inc
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

require_relative "../quickstart"
require "google/cloud"

describe "Quickstart" do
  # Initialize dataset_name
  DATASET_NAME = 'dataset_name'

  # Setup 'before' RSpec hook
  before :all do
    @gcloud = Google::Cloud.new ENV['GOOGLE_PROJECT_ID']
    @bigquery = @gcloud.bigquery
    @dataset = @bigquery.create_dataset DATASET_NAME
  end

  # Setup 'after' RSpec hook
  RSpec.configure do |config|
    config.after do
      cleanup!
    end
  end

  # Cleanup!
  def cleanup!
    # Delete dataset
    @dataset.delete
  end

  # Test Quickstart sample
  it 'creates a new dataset in BigQuery' do
    # Setup expectations for Google::Cloud
    expect(Google::Cloud).to receive(:new).with("YOUR_PROJECT_ID").and_return(@gcloud)

    # Setup expectations for @gcloud
    expect(@gcloud).to receive(:bigquery).and_return(@bigquery)

    # Setup expectations for @bigquery
    expect(@bigquery).to receive(:create_dataset).with("my_new_dataset").and_return(@dataset)

    # Check output
    expect{ run_quickstart }.to output(/#{DATASET_NAME}/).to_stdout
  end
end

