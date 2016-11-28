# Copyright 2016, Google, Inc.
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Spec Helpers
#
# spec/helpers/ contains numerous helpers for the specs used in this repository
#
# To activate these helpers in your spec file:
#
#   require_relative "../../spec/helpers"
#
#   require "storage_helper"

require "rspec"

$LOAD_PATH.unshift File.expand_path("helpers", __dir__)
