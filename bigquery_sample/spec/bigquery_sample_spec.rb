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

RSpec.describe "Google Cloud BigQuery samples" do

  example "list projects"
  example "list datasets"
  example "list tables"
  example "create table"
  example "delete table"
  example "browse table"
  example "browse table with pagination"
  example "import data from Cloud Storage"
  example "import data from file"
  example "export data to Cloud Storage"
  example "run query"
  example "run query as job"

end
