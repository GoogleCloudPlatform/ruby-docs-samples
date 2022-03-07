# Copyright 2019, Google LLC.
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

# [START getting_started_session_app]
require "sinatra"

require_relative "firestore_session"

use Rack::Session::FirestoreSession

set :greetings, ["Hello World", "Hallo Welt", "Ciao Mondo", "Salut le Monde", "Hola Mundo"]

get "/" do
  session[:greeting] ||= settings.greetings.sample
  session[:views] ||= 0
  session[:views] += 1
  "<h1>#{session[:views]} views for \"#{session[:greeting]}\"</h1>"
end
# [END getting_started_session_app]
