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
require "sinatra"
require "memcache"

memcached_address = ENV["MEMCACHE_PORT_11211_TCP_ADDR"] || "localhost"
memcached_port    = ENV["MEMCACHE_PORT_11211_TCP_PORT"] || 11211

memcache = MemCache.new "#{memcached_address}:#{memcached_port}"

# Set initial value of counter
memcache.set "counter", 0, 0, true

get "/" do
  value = memcache.incr "counter"

  "Counter value is #{value}"
end
# [END all]
