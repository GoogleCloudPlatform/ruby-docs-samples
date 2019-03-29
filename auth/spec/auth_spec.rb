# Copyright 2017 Google, Inc
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

require_relative "../auth"
require "rspec"
require "google/cloud/storage"

describe "Google Cloud Storage buckets sample" do
  before :all do
    @bucket_name = ENV["GOOGLE_CLOUD_STORAGE_BUCKET"]
    @credentials = ENV["GOOGLE_APPLICATION_CREDENTIALS"]
    @storage     = Google::Cloud::Storage.new
    @project_id  = @storage.project
  end

  before do
    @storage.create_bucket @bucket_name unless @storage.bucket @bucket_name
  end

  it "implicit auth to list buckets" do
    expect {
      implicit project_id: @project_id
    }.to output(
      /#{@bucket_name}/
    ).to_stdout
  end

  it "explicit auth to list buckets" do
    expect {
      explicit project_id: @project_id, key_file: @credentials
    }.to output(
      /#{@bucket_name}/
    ).to_stdout
  end

  it "explicit auth in compute engine to list buckets" do
    env_object = double

    expect(Google::Cloud).to receive(:env).and_return env_object
    expect(env_object).to receive(:project_id).and_return @project_id
    expect(Google::Auth::GCECredentials).to receive(:new).and_return @credentials

    expect {
      explicit_compute_engine
    }.to output(
      /#{@bucket_name}/
    ).to_stdout
  end
end
