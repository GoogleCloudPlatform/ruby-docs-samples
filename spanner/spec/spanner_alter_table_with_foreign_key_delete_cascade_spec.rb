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
require_relative "../spanner_alter_table_with_foreign_key_delete_cascade"
require_relative "../spanner_create_table_with_foreign_key_delete_cascade"

describe "Google Cloud Spanner Foreign key cascade examples" do
  before :each do
    @fkdc_database_id = @database_id + "fkdc"
    @fkdc_database = create_test_database @fkdc_database_id
    spanner_create_table_with_foreign_key_delete_cascade project_id: @project_id,
                                                           instance_id: @instance_id,
                                                           database_id: @fkdc_database_id
  end

  after :each do
    test_database = @instance.database @fkdc_database_id
    test_database&.drop
  end

  example "spanner_alter_table_with_foreign_key_delete_cascade" do
    capture do
      spanner_alter_table_with_foreign_key_delete_cascade project_id: @project_id,
                                                          instance_id: @instance_id,
                                                          database_id: @fkdc_database_id
    end

    expect(captured_output).to include 
    "Altered ShoppingCarts table with FKShoppingCartsCustomerName " +
    "foreign key constraint on database #{@fkdc_database_id} on instance #{@instance_id}"
  end
end
