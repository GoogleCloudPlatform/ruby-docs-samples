# Copyright 2021 Google LLC
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

def run_command command, arguments, project_id
  sample_method = method command
  parameters = {}

  sample_method.parameters.each do |paramater|
    next if paramater.last == :project_id
    parameters[paramater.last] = arguments.shift
  end

  sample_method.call(project_id: project_id, **parameters)
end
