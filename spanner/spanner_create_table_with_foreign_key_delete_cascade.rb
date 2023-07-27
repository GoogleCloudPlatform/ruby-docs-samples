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

# [START spanner_create_table_with_foreign_key_delete_cascade]
require "google/cloud/spanner"

##
# This is a snippet for showcasing how to create table with foreign key delete cascade.
#
# @param project_id  [String] The ID of the Google Cloud project.
# @param instance_id [String] The ID of the spanner instance.
# @param database_id [String] The ID of the database.
#
def spanner_create_table_with_foreign_key_delete_cascade project_id:, instance_id:, database_id:
  db_admin_client = Google::Cloud::Spanner::Admin::Database.database_admin

  database_path = db_admin_client.database_path project: project_id,
                                                instance: instance_id,
                                                database: database_id

  job = db_admin_client.update_database_ddl database: database_path, statements: [
    %{ CREATE TABLE Customers (
        CustomerId INT64 NOT NULL,
        CustomerName STRING(62) NOT NULL,
        ) PRIMARY KEY (CustomerId)},
    %{ CREATE TABLE ShoppingCarts (
        CartId INT64 NOT NULL,
        CustomerId INT64 NOT NULL,
        CustomerName STRING(62) NOT NULL,
        CONSTRAINT FKShoppingCartsCustomerId FOREIGN KEY (CustomerId)
        REFERENCES Customers (CustomerId) ON DELETE CASCADE
    ) PRIMARY KEY (CartId)}
  ]

  puts "Waiting for operation to complete..."
  job.wait_until_done!
  puts "Created Customers and ShoppingCarts table with FKShoppingCartsCustomerId \
  foreign key constraint on database #{database_id} on instance #{instance_id}"
end
# [END spanner_create_table_with_foreign_key_delete_cascade]
