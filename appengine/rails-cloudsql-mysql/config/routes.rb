# Copyright 2017 Google, Inc
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

# [START cat_routes]
Rails.application.routes.draw do
  resources :cats
  get "cats/index"

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root "cats#index"
end
# [END cat_routes]

=begin
# [START boilerplate]
Rails.application.routes.draw do
  resources :cats
  get 'cats/index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

end
# [END boilerplate]
=end
