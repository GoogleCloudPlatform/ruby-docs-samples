# frozen_string_literal: true

# Copyright 2018 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


# [START bigtable_quickstart]
# Import google bigtable client lib
require "google/cloud/bigtable"

# Your Google Cloud Platform project ID
project_id = "YOUR_PROJECT_ID"

# Instantiates a client
bigtable = Google::Cloud::Bigtable.new project_id: project_id

# Your Cloud Bigtable instance ID
instance_id = "my-bigtable-instance"

# Your Cloud Bigtable table ID
table_id = "my-table"

# Get table client
table = bigtable.table instance_id, table_id

# Read and print row
p table.read_row "user0000001"
# [END bigtable_quickstart]
