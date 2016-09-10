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

require_relative "../bigquery_samples"
require "rspec"
require "google/cloud"

RSpec.describe "Google Cloud BigQuery samples" do

  before do
    @project_id = ENV["GOOGLE_PROJECT_ID"]
    @gcloud     = Google::Cloud.new @project_id
    @bigquery   = @gcloud.bigquery
  end

  def delete_dataset! dataset_id
    @bigquery.dataset(dataset_id).delete if @bigquery.dataset dataset_id
  end

  def create_dataset! dataset_id
    @bigquery.create_dataset dataset_id unless @bigquery.dataset dataset_id
  end

  describe "Managing projects" do
    example "list projects"
  end

  describe "Managing Datasets" do
    example "create dataset" do
      delete_dataset! "test_dataset"
      expect(@bigquery.dataset "test_dataset").to be nil

      expect {
        create_dataset project_id: @project_id, dataset_id: "test_dataset"
      }.to output(
        "Created dataset: test_dataset\n"
      ).to_stdout

      expect(@bigquery.dataset "test_dataset").not_to be nil
    end

    example "list datasets" do
      create_dataset! "test_dataset"

      expect {
        list_datasets project_id: @project_id
      }.to output(
        /test_dataset/
      ).to_stdout
    end

    example "delete dataset" do
      create_dataset! "test_dataset"
      expect(@bigquery.dataset "test_dataset").not_to be nil

      expect {
        delete_dataset project_id: @project_id, dataset_id: "test_dataset"
      }.to output(
        "Deleted dataset: test_dataset\n"
      ).to_stdout

      expect(@bigquery.dataset "test_dataset").to be nil
    end
  end

  describe "Managing Tables" do
    example "create table"
    example "list tables"
    example "delete table"
    example "browse table"
    example "browse table with pagination"
  end

  describe "Importing data" do
    example "import data from Cloud Storage"
    example "import data from file"
    example "stream data import"
  end

  describe "Exporting data" do
    example "export data to Cloud Storage"
  end

  describe "Querying" do
    example "run query"
    example "run query as job"
  end
end
