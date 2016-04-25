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

# [START all]
require "digest/sha2"
require "sinatra"
require "sequel"

DB = Sequel.mysql2 host: ENV["MYSQL_HOST"],
                   user: ENV["MYSQL_USER"],
                   password: ENV["MYSQL_PASSWORD"],
                   database: ENV["MYSQL_DATABASE"]

get "/" do
  # Save visit in database
  DB[:visits].insert(
    user_ip:   Digest::SHA256.hexdigest(request.ip),
    timestamp: Time.now
  )

  response.write "Last 10 visits:\n"

  DB[:visits].order(Sequel.desc(:timestamp)).limit(10).each do |visit|
    response.write "Time: #{visit[:timestamp]} Addr: #{visit[:user_ip]}\n"
  end

  content_type "text/plain"
  status 200
end
# [END all]
