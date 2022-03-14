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

require "google/cloud/spanner"
require_relative "../spanner_postgresql_create_database"
require_relative "../spanner_postgresql_create_table"

def create_spangres_singers_albums_database
  capture do
    postgresql_create_database project_id:  @project_id,
                               instance_id: @instance.instance_id,
                               database_id: @database_id
    
    @test_database = @instance.database @database_id
  end

  @test_database
end

def create_spangres_singers_table
  capture do
    spanner_postgresql_create_table project_id:  @project_id,
                                    instance_id: @instance.instance_id,
                                    database_id: @database_id
  end
end

def add_data_to_spangres_singers_table
  spanner = Google::Cloud::Spanner.new project: @project_id
  client  = spanner.client @instance.instance_id, @database_id
  client.commit do |c|
    c.insert "Singers", [
      { SingerId: 1, FirstName: "Ann", LastName: "Louis" }
    ]
  end
end
