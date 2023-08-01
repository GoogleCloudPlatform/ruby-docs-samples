# Copyright 2023 Google, Inc
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
require_relative "../spanner_create_sequence"
require_relative "../spanner_alter_sequence"
require_relative "../spanner_drop_sequence"
require_relative "../spanner_postgresql_create_sequence"
require_relative "../spanner_postgresql_alter_sequence"
require_relative "../spanner_postgresql_drop_sequence"

describe "Google Cloud Spanner Sequence examples" do
  before :all do
    @seq_database_id = @database_id+"seq"
    create_test_database @seq_database_id
  end

  after :all do
    test_database = @instance.database @seq_database_id
    test_database&.drop
  end

  example "spanner_create_sequence" do
    capture do
        spanner_create_sequence project_id: @project_id,
                               instance_id: @instance_id,
                               database_id: @seq_database_id
    end

    expect(captured_output).to include 
    "Created Seq sequence and Customers table, where the key column CustomerId uses the sequence as a default value"
  end

  example "spanner_alter_sequence" do
    spanner_create_sequence project_id: @project_id,
                            instance_id: @instance_id,
                            database_id: @seq_database_id

    capture do
      spanner_alter_sequence project_id: @project_id,
                             instance_id: @instance_id,
                             database_id: @seq_database_id
    end

    expect(captured_output).to include 
    "Altered Seq sequence to skip an inclusive range between 1000 and 5000000"

    spanner_drop_sequence project_id: @project_id,
                            instance_id: @instance_id,
                            database_id: @seq_database_id
  end

  example "spanner_alter_sequence" do
    spanner_create_sequence project_id: @project_id,
                            instance_id: @instance_id,
                            database_id: @seq_database_id

    capture do
      spanner_drop_sequence project_id: @project_id,
                             instance_id: @instance_id,
                             database_id: @seq_database_id
    end

    expect(captured_output).to include 
    "Altered Customers table to drop DEFAULT from CustomerId column and dropped the Seq sequence"
  end
end

describe "Google Cloud Spanner Sequence examples for postgresql" do
    before :all do
      create_spangres_singers_albums_database
    end
  
    after :all do
      cleanup_database_resources
    end
  
    example "spanner_postgresql_create_sequence" do
        capture do
            spanner_postgresql_create_sequence project_id: @project_id,
                                   instance_id: @instance_id,
                                   database_id: @database_id
        end
    
        expect(captured_output).to include 
        "Created Seq sequence and Customers table, where the key column CustomerId uses the sequence as a default value"
      end
    
      example "spanner_postgresql_alter_sequence" do
        spanner_postgresql_create_sequence project_id: @project_id,
                                instance_id: @instance_id,
                                database_id: @database_id
    
        capture do
          spanner_postgresql_alter_sequence project_id: @project_id,
                                 instance_id: @instance_id,
                                 database_id: @database_id
        end
    
        expect(captured_output).to include 
        "Altered Seq sequence to skip an inclusive range between 1000 and 5000000"
    
        spanner_postgresql_drop_sequence project_id: @project_id,
                                instance_id: @instance_id,
                                database_id: @database_id
      end
    
      example "spanner_postgresql_alter_sequence" do
        spanner_postgresql_create_sequence project_id: @project_id,
                                instance_id: @instance_id,
                                database_id: @database_id
    
        capture do
          spanner_postgresql_drop_sequence project_id: @project_id,
                                 instance_id: @instance_id,
                                 database_id: @database_id
        end
    
        expect(captured_output).to include 
        "Altered Customers table to drop DEFAULT from CustomerId column and dropped the Seq sequence"
      end
  end