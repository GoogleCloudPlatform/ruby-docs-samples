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
require_relative "./spanner_postgresql_helper"
require_relative "../spanner_postgresql_identifier_case_sensitivity"

describe "Google Cloud Spanner Postgres examples" do
  before :each do
    cleanup_database_resources
  end

  after :each do
    cleanup_database_resources
    cleanup_instance_resources
  end

  example "spanner_postgresql_identifier_case_sensitivity" do
    database = create_spangres_singers_albums_database
    capture do
      spanner_postgresql_identifier_case_sensitivity project_id: @project_id,
                                                     instance_id: @instance_id,
                                                     database_id: @database_id
    end

    expect(captured_output).to include "Created table with case sensitive names in database #{@database_id} using PostgreSQL dialect."
    
    # Access the data without aliases
    expect(captured_output).to include "ConcertId: 1"
    expect(captured_output).to include "Location: Venue 1"
    expect(captured_output).to include "Time: 2022-03-11 00:00:00 UTC"
    
    # Access the data with aliases
    expect(captured_output).to include "ConcertId (double quoted alias): 1"
    expect(captured_output).to include "Location (double quoted alias): Venue 1"
    expect(captured_output).to include "Time (double quoted): 2022-03-11 00:00:00 UTC"
    
    expect(captured_output).to include "Inserted 1 row(s)"
  end
end
