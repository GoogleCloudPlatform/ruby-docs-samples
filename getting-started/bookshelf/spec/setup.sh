#! /bin/bash
# Copyright 2015 Google Inc.
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

# download cloud-datastore-emulator testing tool
wget -q https://storage.googleapis.com/gcd/tools/cloud-datastore-emulator-1.1.1.zip -O cloud-datastore-emulator.zip
unzip -o cloud-datastore-emulator.zip

# start cloud-datastore-emulator test server
cloud-datastore-emulator/cloud_datastore_emulator create gcd-test-dataset-directory
cloud-datastore-emulator/cloud_datastore_emulator start --testing ./gcd-test-dataset-directory/ &

# compile assets directory
RAILS_ENV=test bundle exec rake --rakefile=Rakefile assets:precompile
