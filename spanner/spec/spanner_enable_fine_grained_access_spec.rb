# Copyright 2022 Google, Inc
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

require_relative "./spec_helper"
require "google/apis/iam_v1"
require_relative "../spanner_enable_fine_grained_access"

describe "Google Cloud Spanner Database roles" do
  before :each do
    @client = Google::Apis::IamV1::IamService.new
    scopes =  ["https://www.googleapis.com/auth/cloud-platform"]
    @client.authorization = Google::Auth.get_application_default(scopes)
    
    @service_account = create_service_account
    cleanup_database_resources
  end

  after :each do
    cleanup_service_account
    cleanup_database_resources
    cleanup_instance_resources
  end

  example "Enable fine grained access" do
    create_singers_albums_database
    capture do
      spanner_enable_fine_grained_access project_id: @project_id,
                                         instance_id: @instance_id,
                                         database_id: @database_id,
                                         iam_member: "serviceAccount:#{@service_account.email}", 
                                         database_role: "new_parent", 
                                         title: "Test condition"
    end

    expect(captured_output).to include "Enabled fine-grained access in IAM"
  end


  def create_service_account
    request = Google::Apis::IamV1::CreateServiceAccountRequest.new
    request.account_id = "test-sample-1234"
    @client.create_service_account "projects/#{@project_id}", request
  end

  def cleanup_service_account
    @client.delete_project_service_account  @service_account.name
  end
end
